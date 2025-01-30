class WebhookException implements Exception {
  final int statusCode;

  const WebhookException(this.statusCode);

  @override
  String toString() {
    return '$statusCode';
  }
}
