class APIException implements Exception {
  final int statusCode;
  final String responseBody;
  const APIException(this.statusCode, this.responseBody);

  @override
  String toString() {
    return responseBody;
  }
}

class DecodingError implements Exception {
  final String message;
  const DecodingError(this.message);

  @override
  String toString() {
    return message;
  }
}
