class RestException implements Exception {
  final int statusCode;
  final String message;

  const RestException(this.statusCode, this.message);

  @override
  String toString() {
    return '$statusCode: $message';
  }
}
