import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/registration.dart';
import '../../models/server_configuration.dart';
import '../../models/template.dart';
import '../client.dart';

export 'rest_exception.dart';

class RestClient implements Client {
  final Uri _baseUri;
  late final Map<String, String> _headers;

  RestClient(this._baseUri, [String? bearerToken]) {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }
    _headers = headers;
  }

  // TODO GET /api/

  // /api/config
  @override
  Future<ServerConfiguration> getConfig() async {
    final response = await _get('/api/config', headers: _headers);
    // if the request was not successfully (status code 2XX), throw RestException
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _buildException(response.statusCode);
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return ServerConfiguration.fromMap(body);
  }

  // TODO GET /api/events
  // TODO GET /api/services
  // TODO GET /api/history/period/<timestamp>
  // TODO GET /api/logbook/<timestamp>
  // TODO GET /api/states
  // TODO GET /api/states/<entity_id>
  // TODO GET /api/error_log
  // TODO GET /api/camera_proxy/<camera entity_id>
  // TODO GET /api/calendars
  // TODO GET /api/calendars/<calendar entity_id>

  // TODO POST /api/states/<entity_id>

  @override
  Future<void> callService(String domain, String service,
      [Map<String, dynamic>? serviceData]) async {
    final body = serviceData != null ? jsonEncode(serviceData) : '{}';
    final response = await _post('/api/services/$domain/$service',
        headers: _headers, body: body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _buildException(response.statusCode);
    }
  }

  @override
  Future<void> fireEvent(
      String eventType, Map<String, dynamic>? eventData) async {
    final body = eventData != null ? jsonEncode(eventData) : null;
    final response =
        await _post('/api/events/$eventType', headers: _headers, body: body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _buildException(response.statusCode);
    }
  }

  @override
  Future<String> renderTemplate(Template template) async {
    final body = jsonEncode(template.toMap());
    final response =
        await _post('/api/template', headers: _headers, body: body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _buildException(response.statusCode);
    }
    return response.body;
  }

  @override
  Future<Map<String, String>> renderTemplates(
      Map<String, Template> templates) async {
    final futures = templates.entries.map((it) async {
      final result = await renderTemplate(it.value);
      return MapEntry(it.key, result);
    });
    final result = await Future.wait(futures);
    return Map.fromEntries(result);
  }

  // TODO POST /api/config/core/check_config
  // TODO POST /api/intent/handle

  Future<RegistrationResponse> registerDevice(
      {required String deviceId,
      required String appId,
      required String appName,
      required String appVersion,
      required String deviceName,
      required String manufacturer,
      required String model,
      required String osName,
      required String osVersion,
      required bool supportsEncryption,
      Map<String, dynamic>? appData}) async {
    Map<String, dynamic> bodyRaw = {
      'device_id': deviceId,
      'app_id': appId,
      'app_name': appName,
      'app_version': appVersion,
      'device_name': deviceName,
      'manufacturer': manufacturer,
      'model': model,
      'os_name': osName,
      'os_version': osVersion,
      'supports_encryption': supportsEncryption,
    };
    if (appData != null && appData.isNotEmpty) {
      bodyRaw['app_data'] = appData;
    }

    // perform request
    final body = jsonEncode(bodyRaw);
    final response = await _post('/api/mobile_app/registrations',
        headers: _headers, body: body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _buildException(response.statusCode);
    }
    final responseJson = jsonDecode(response.body);
    return RegistrationResponse.fromMap(responseJson);
  }

  Uri _buildUri(Uri base, String path) {
    return Uri(
        scheme: base.scheme, host: base.host, port: base.port, path: path);
  }

  RestException _buildException(int statusCode) {
    switch (statusCode) {
      case 400:
        return RestException(400, 'Bad Request');
      case 401:
        return RestException(401, 'Unauthorized');
      case 404:
        return RestException(404, 'Not Found');
      case 405:
        return RestException(405, 'Method Not Allowed');
      default:
        return RestException(statusCode, '');
    }
  }

  Future<http.Response> _get(String path, {Map<String, String>? headers}) {
    return http.get(_buildUri(_baseUri, path), headers: _headers);
  }

  Future<http.Response> _post(String path,
      {Map<String, String>? headers, Object? body}) {
    return http.post(_buildUri(_baseUri, path), headers: _headers, body: body);
  }
}

class FallbackRestClient extends RestClient {
  Uri? _cloudUri;

  FallbackRestClient(Uri? cloudUri, Uri customUri, [String? bearerToken])
      : _cloudUri = cloudUri,
        super(customUri, bearerToken);

  @override
  Future<http.Response> _get(String path,
      {Map<String, String>? headers}) async {
    final uris = _buildUriList();
    for (var uri in uris) {
      final apiUri = _buildUri(uri, path);
      try {
        return await http.get(apiUri, headers: headers);
      } catch (e) {
        print('Error getting from $apiUri: $e');
      }
    }
    throw ServerUnreachableException(_baseUri);
  }

  @override
  Future<http.Response> _post(String path,
      {Map<String, String>? headers, Object? body}) async {
    final uris = _buildUriList();
    for (var uri in uris) {
      final apiUri = _buildUri(uri, path);
      try {
        return await http.post(apiUri, headers: headers, body: body);
      } catch (e) {
        print('Error posting to $apiUri: $e');
      }
    }
    throw ServerUnreachableException(_baseUri);
  }

  List<Uri> _buildUriList() {
    List<Uri> uris = [];
    if (_cloudUri != null) {
      uris.add(_cloudUri!);
    }
    uris.add(_baseUri);
    return uris;
  }
}
