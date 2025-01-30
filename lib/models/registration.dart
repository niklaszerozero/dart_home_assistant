class RegistrationResponse {
  final String? cloudhookUrl;
  final String? remoteUiUrl;
  final String? secret;
  final String webhookId;

  RegistrationResponse.fromMap(Map<String, dynamic> map)
      : this.cloudhookUrl = map['cloudhook_url'],
        this.remoteUiUrl = map['remote_ui_url'],
        this.secret = map['secret'],
        this.webhookId = map['webhook_id'] ?? "";
}
