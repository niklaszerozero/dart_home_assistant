import 'dart:convert';
import 'dart:ffi';

import 'package:sodium/sodium.dart';

import '../../models/native_app.dart';
import '../../models/server_configuration.dart';
import '../../models/template.dart';
import '../../util/mappable.dart';
import '../client.dart';

class NativeAppClient implements Client, Mappable {
  bool _preferInternal = false;

  Uri? _cloudhookUri;
  Uri? _cloudUri;
  Uri _externalUri;
  Uri? _internalUri;

  final AppInformation _app;
  final DeviceInformation _device;
  final bool _supportsEncryption;
  final Map<String, dynamic>? _appData;

  String? _webhookId = null;

  Sodium? _sodium;
  SecureKey? _encryptionKey;

  late RestClient _restClient;
  late WebhookClient? _webhookClient;

  NativeAppClient(this._externalUri, this._app, this._device, [this._appData])
      : this._supportsEncryption = false {
    _restClient = _buildRestClient();
    _webhookClient = _buildWebhookClient();
  }

  NativeAppClient.encrypted(
      this._externalUri, String pathToLibsodium, this._app, this._device,
      [this._appData])
      : this._supportsEncryption = true {
    _restClient = _buildRestClient();
    _webhookClient = _buildWebhookClient();
    // initialise encryption
    _initializeEncryption(pathToLibsodium);
  }

  NativeAppClient.fromMap(Map<String, dynamic> map, [String? pathToLibsodium])
      : this._cloudhookUri = map.containsKey('cloudhook_url')
            ? Uri.parse(map['cloudhook_url'])
            : null,
        this._cloudUri =
            map.containsKey('cloud_url') ? Uri.parse(map['cloud_url']) : null,
        this._externalUri = Uri.parse(map['external_url']),
        this._internalUri = map.containsKey('internal_url')
            ? Uri.parse(map['internal_url'])
            : null,
        this._app = AppInformation.fromMap(map),
        this._device = DeviceInformation.fromMap(map),
        this._supportsEncryption = map['supports_encryption'],
        this._appData = map.containsKey('app_data') ? map['app_data'] : null {
    _restClient = _buildRestClient();
    _webhookClient = _buildWebhookClient();
    // initialise encryption
    if (pathToLibsodium != null) {
      _initializeEncryption(pathToLibsodium, map['encryption_secret']);
    }
  }

  set preferInternal(bool preferInternal) {
    _preferInternal = preferInternal;
    _restClient = _buildRestClient();
    _webhookClient = _buildWebhookClient();
  }

  set secret(String secret) {
    if (_sodium == null) {
      throw Exception('sodium is not initialized');
    }
    final keyBytes = base64.decode(secret);
    if (keyBytes.length != _sodium!.crypto.secretBox.keyBytes) {
      throw Exception(
          'Invalid key length: Expected ${_sodium!.crypto.secretBox.keyBytes} bytes, got ${keyBytes.length}');
    }
    _encryptionKey = _sodium!.secureCopy(keyBytes);
    _webhookClient = _buildWebhookClient();
  }

  Future<void> registerDevice() async {
    final response = await _restClient.registerDevice(
        deviceId: _device.id,
        appId: _app.id,
        appName: _app.name,
        appVersion: _app.version,
        deviceName: _device.name,
        manufacturer: _device.manufacturer,
        model: _device.model,
        osName: _device.osName,
        osVersion: _device.osVersion,
        supportsEncryption: _supportsEncryption,
        appData: _appData);
    _cloudhookUri = response.cloudhookUrl != null
        ? Uri.parse(response.cloudhookUrl!)
        : null;
    _cloudUri =
        response.remoteUiUrl != null ? Uri.parse(response.remoteUiUrl!) : null;
    if (response.secret != null) {
      secret = response.secret!;
    }
    _webhookId = response.webhookId;

    // update webhook client
    _webhookClient = _buildWebhookClient();
  }

  @override
  Future<ServerConfiguration> getConfig() {
    if (_webhookClient != null) {
      return _webhookClient!.getConfig();
    }
    return _restClient.getConfig();
  }

  @override
  Future<void> callService(String domain, String service,
      [Map<String, dynamic>? serviceData]) {
    return _decideClient().callService(domain, service, serviceData);
  }

  @override
  Future<void> fireEvent(String eventType, Map<String, dynamic>? eventData) {
    return _decideClient().fireEvent(eventType, eventData);
  }

  @override
  Future<String> renderTemplate(Template template) {
    return _decideClient().renderTemplate(template);
  }

  @override
  Future<Map<String, String>> renderTemplates(Map<String, Template> templates) {
    return _decideClient().renderTemplates(templates);
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = {};
    if (_cloudhookUri != null) {
      result['cloudhook_url'] = _cloudhookUri.toString();
    }
    if (_cloudUri != null) {
      result['cloud_url'] = _cloudUri.toString();
    }
    result['external_url'] = _externalUri.toString();
    if (_internalUri != null) {
      result['internal_url'] = _internalUri.toString();
    }
    result = {
      ...result,
      ..._app.toMap(),
      ..._device.toMap(),
      'supports_encryption': _supportsEncryption
    };
    if (_encryptionKey != null) {
      result['encryption_secret'] =
          base64.encode(_encryptionKey!.extractBytes());
    }
    if (_appData != null) {
      result['app_data'] = _appData;
    }
    return result;
  }

  Future<void> _initializeEncryption(String path, [String? secret]) async {
    // initialize sodium
    _sodium = await SodiumInit.init(() => DynamicLibrary.open(path));

    // initialize secret
    if (secret != null) {
      this.secret = secret;
    }

    // create encrypted webhook client
    _webhookClient = _buildWebhookClient();
  }

  Client _decideClient() {
    if (_webhookClient != null) {
      return _webhookClient!;
    }
    return _restClient;
  }

  RestClient _buildRestClient([bool? overrideUseInternal]) {
    Uri customUri;
    final useInternal =
        overrideUseInternal != null ? overrideUseInternal : _preferInternal;
    if (useInternal && _internalUri != null) {
      customUri = _internalUri!;
    } else {
      customUri = _externalUri;
    }

    return FallbackRestClient(_cloudUri, customUri);
  }

  WebhookClient? _buildWebhookClient([bool? overrideUseInternal]) {
    // there is a webhook id specified, use fallback client witch tries cloudhook -> cloud -> external/internal
    if (_webhookId != null) {
      // build cloud uri
      final cloudUri = _cloudUri != null
          ? WebhookClient.constructUri(_cloudUri!, _webhookId!)
          : null;

      // build custom uri (internal or external)
      Uri customUri;
      final useInternal =
          overrideUseInternal != null ? overrideUseInternal : _preferInternal;
      if (useInternal && _internalUri != null) {
        customUri = WebhookClient.constructUri(_internalUri!, _webhookId!);
      } else {
        customUri = WebhookClient.constructUri(_externalUri, _webhookId!);
      }

      // build client
      if (_supportsEncryption) {
        return FallbackWebhookClient(_cloudhookUri, cloudUri, customUri);
      } else {
        return FallbackWebhookClient.encrypted(
            _cloudhookUri, cloudUri, customUri, _encryptionKey!, _sodium!);
      }
    }

    // there is at least a cloudhook uri use this without fallbacks
    if (_cloudhookUri != null) {
      if (_supportsEncryption) {
        return WebhookClient(_cloudhookUri!);
      } else {
        return WebhookClient.encrypted(
            _cloudhookUri!, _encryptionKey!, _sodium!);
      }
    }

    // there is no possible uri, therefore there is no client
    return null;
  }
}
