import 'package:home_assistant/home_assistant.dart';

void main() {
  // initialize client
  final baseUri = Uri.parse('http://homeassistant.local:8123');
  final app = AppInformation("id", "name", "version");
  final device = DeviceInformation(
      "id", "name", "manufacturer", "model", "osName", "osVersion");
  final NativeAppClient client = NativeAppClient(baseUri, app, device);

  performActions(client);
}

Future<void> performActions(NativeAppClient client) async {
  // show a welcome message
  final welcomeMessage = await renderWelcomeMessage(client);
  print(welcomeMessage);

  // register device
  await client.registerDevice();

  // toggle lights
  await toggleCeilingLight(client);

  // call a generic service
  await toggleCustomDomain(client);
}

Future<String> renderWelcomeMessage(Client client) {
  return client.renderTemplate(
      Template('Welcome {{ name }}! It is {{ now() }}!', {'name': 'John Doe'}));
}

Future<void> toggleCeilingLight(Client client) {
  return client.light.toggle(
    Target.entity('light.ceiling'),
    transition: 150,
  );
}

Future<void> toggleCustomDomain(Client client) {
  return client.callService('homeassistant', 'toggle', {
    'entity_id': 'custom.entity',
  });
}
