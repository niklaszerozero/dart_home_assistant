import '../models/server_configuration.dart';
import '../models/template.dart';

export 'native_app/native_app_client.dart';
export 'rest/rest_client.dart';
export 'services/services.dart';
export 'webhook/webhook_client.dart';

class ServerUnreachableException implements Exception {
  final Uri uri;

  const ServerUnreachableException(this.uri);

  @override
  String toString() {
    return uri.toString();
  }
}

abstract class Client {
  /// Returns the current configuration.
  Future<ServerConfiguration> getConfig();

  /// Calls a service within a specific domain. Will return when the service has been executed.
  Future<void> callService(String domain, String service,
      [Map<String, dynamic>? serviceData]);

  /// Fires an event with eventType.
  Future<void> fireEvent(String eventType, Map<String, dynamic>? eventData);

  /// Render a Home Assistant template.
  Future<String> renderTemplate(Template template);

  /// Renders multiple Home Assistant templates.
  Future<Map<String, String>> renderTemplates(Map<String, Template> templates);
}
