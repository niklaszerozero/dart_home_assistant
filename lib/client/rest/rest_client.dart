import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/server_configuration.dart';
import '../../models/template.dart';
import '../client.dart';

export 'rest_exception.dart';

class RestClient implements Client {
  final Uri _baseUri;
  final Map<String, String> _headers;

  RestClient(this._baseUri, String bearerToken)
      : _headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken'
        };

  // TODO GET /api/

  // /api/config
  @override
  Future<ServerConfiguration> getConfig() async {
    final uri = _buildUri('/api/config');
    final response = await http.get(uri, headers: _headers);
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
    final uri = _buildUri('/api/services/$domain/$service');
    final body = serviceData != null ? jsonEncode(serviceData) : '{}';
    final response = await http.post(uri, headers: _headers, body: body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _buildException(response.statusCode);
    }
  }

  @override
  Future<void> fireEvent(
      String eventType, Map<String, dynamic>? eventData) async {
    final uri = _buildUri('/api/events/$eventType');
    final body = eventData != null ? jsonEncode(eventData) : null;
    final response = await http.post(uri, headers: _headers, body: body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _buildException(response.statusCode);
    }
  }

  @override
  Future<String> renderTemplate(Template template) async {
    final uri = _buildUri('/api/template');
    final body = jsonEncode(template.toMap());
    final response = await http.post(uri, headers: _headers, body: body);
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

  Uri _buildUri(String path) {
    return Uri(
        scheme: _baseUri.scheme,
        host: _baseUri.host,
        port: _baseUri.port,
        path: path);
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
}
