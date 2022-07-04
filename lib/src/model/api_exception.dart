/// Exception thrown when response from
/// API is not with in `200 to 299`
class APIException implements Exception {
  final int statusCode;
  final String responseBody;
  const APIException(this.statusCode, this.responseBody);

  @override
  String toString() {
    return responseBody;
  }
}

/// Exception thrown if unable to decode
/// API response
class DecodingError implements Exception {
  final String message;
  const DecodingError(this.message);

  @override
  String toString() {
    return message;
  }
}
