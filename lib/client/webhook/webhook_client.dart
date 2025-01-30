import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sodium/sodium.dart';

import '../../models/server_configuration.dart';
import '../../models/template.dart';
import '../client.dart';

export 'webhook_exception.dart';

class WebhookClient implements Client {
  static Uri constructUri(Uri baseUri, String webhookId) => Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.port,
      path: '/api/webhook/$webhookId');

  final Uri _baseUri;

  final SecureKey? _key;
  final Sodium? _sodium;

  const WebhookClient(this._baseUri)
      : this._key = null,
        this._sodium = null;

  const WebhookClient.encrypted(this._baseUri, SecureKey key, Sodium sodium)
      : this._key = key,
        this._sodium = sodium;

  Future<void> updateDeviceLocation({
    String? locationName,
    double? latitude,
    double? longitude,
    int? gpsAccuracy,
    int? battery,
    int? speed,
    int? altitude,
    int? course,
    int? verticalAccuracy,
  }) {
    // build data
    Map<String, dynamic> data = {};
    if (locationName != null) data['location_name'] = locationName;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (gpsAccuracy != null) data['gps_accuracy'] = gpsAccuracy;
    if (battery != null) data['battery'] = battery;
    if (speed != null) data['speed'] = speed;
    if (altitude != null) data['altitude'] = altitude;
    if (course != null) data['course'] = course;
    if (verticalAccuracy != null) data['vertical_accuracy'] = verticalAccuracy;

    // send message
    return _sendMessage('update_location', data);
  }

  @override
  Future<ServerConfiguration> getConfig() async {
    final result = await _sendMessage('get_config');
    final map = jsonDecode(result);
    return ServerConfiguration.fromMap(map);
  }

  @override
  Future<void> callService(String domain, String service,
      [Map<String, dynamic>? serviceData]) {
    // build data
    Map<String, dynamic> data = {
      'domain': domain,
      'interfaces': service,
    };
    if (serviceData != null) data['service_data'] = serviceData;

    // send message
    return _sendMessage('call_service', data);
  }

  @override
  Future<void> fireEvent(String eventType, Map<String, dynamic>? eventData) {
    // build data
    Map<String, dynamic> data = {
      'event_type': eventType,
    };
    if (eventData != null) data['event_data'] = eventData;

    // send message
    return _sendMessage('fire_event', data);
  }

  @override
  Future<String> renderTemplate(Template template) async {
    final result = await renderTemplates({'0': template});
    return result['0'] ?? '';
  }

  @override
  Future<Map<String, String>> renderTemplates(
      Map<String, Template> templates) async {
    Map<String, dynamic> data = {};
    for (var entry in templates.entries) {
      data[entry.key] = entry.value.toMap();
    }
    final body = await _sendMessage('render_template', data);
    return jsonDecode(body);
  }

  // TODO update_registration
  // TODO get_zones
  // TODO enable_encryption
  // TODO stream_camera
  // TODO conversation_process

  // TODO register_sensor
  // TODO update_sensor_states

  // TODO Push Notifications

  Future<String> _sendMessage(String type, [Map<String, dynamic>? data]) async {
    return _sendMessageTo(_baseUri, type, data);
  }

  Future<String> _sendMessageTo(Uri uri, String type,
      [Map<String, dynamic>? data]) async {
    // build data
    Map<String, dynamic> bodyRaw = {'type': type};
    if (data != null && data.isNotEmpty) {
      bodyRaw['data'] = data;
    }

    // encrypt data if necessary
    if (_key != null && _sodium != null) {
      final nonce =
          _sodium.randombytes.buf(_sodium.crypto.secretBox.nonceBytes);
      final message = utf8.encode(jsonEncode(bodyRaw));
      final encryptedData = _sodium.crypto.secretBox
          .easy(message: message, nonce: nonce, key: _key);
      bodyRaw = {
        'type': 'encrypted',
        'encrypted': true,
        'encrypted_data': encryptedData,
      };
    }

    // perform request
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(bodyRaw);
    final response = await http.post(uri, headers: headers, body: body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WebhookException(response.statusCode);
    }
    return response.body;
  }
}

class FallbackWebhookClient extends WebhookClient {
  final Uri? _cloudhookUri;
  final Uri? _cloudUri;

  const FallbackWebhookClient(Uri? cloudhookUri, Uri? cloudUri, Uri customUri)
      : this._cloudhookUri = cloudhookUri,
        this._cloudUri = cloudUri,
        super(customUri);

  const FallbackWebhookClient.encrypted(
    Uri? cloudhookUri,
    Uri? cloudUri,
    Uri customUri,
    SecureKey key,
    Sodium sodium,
  )   : this._cloudhookUri = cloudhookUri,
        this._cloudUri = cloudUri,
        super.encrypted(customUri, key, sodium);

  @override
  Future<String> _sendMessage(String type, [Map<String, dynamic>? data]) async {
    List<Uri> uris = _buildUriList();
    for (var uri in uris) {
      try {
        return await _sendMessageTo(uri, type, data);
      } catch (e) {
        print('Error fetching from $uri: $e');
      }
    }
    throw ServerUnreachableException(_baseUri);
  }

  List<Uri> _buildUriList() {
    List<Uri> uris = [];
    if (_cloudhookUri != null) {
      uris.add(_cloudhookUri);
    }
    if (_cloudUri != null) {
      uris.add(_cloudUri);
    }
    uris.add(_baseUri);
    return uris;
  }
}
