import 'package:home_assistant/home_assistant.dart';

void main() {
  // initialize client
  final baseUri = Uri.parse('http://homeassistant.local:8123');
  final bearerToken = 'token';
  final RestClient client = RestClient(baseUri, bearerToken);

  performActions(client);
}

Future<void> performActions(RestClient client) async {
  // show a welcome message
  final welcomeMessage = await renderWelcomeMessage(client);
  print(welcomeMessage);

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
