import '../model/request.dart';

/// Exception thrown when response from
/// API is not with in `successfulResponsesStatusCode`
/// which default to 200-299
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
class DecodingError<R> implements Exception {
  final Request<R> request;
  final StackTrace stackTrace;
  final Object error;
  const DecodingError(this.request, this.stackTrace, this.error);

  @override
  String toString() {
    return '''Decoding Error, while using `decode` of ${Request<R>} got error: $error
Click on the top most StackTrace to see what is causing the decoding to fail
StackTrace:
$stackTrace
''';
  }
}
