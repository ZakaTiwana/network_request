import 'dart:typed_data';

import 'package:http/http.dart' as http show Response;

/// Captures the details of a response
class CapturedResponse {
  /// The HTTP status code for this response.
  final int statusCode;

  /// The reason phrase associated with the status code.
  final String? reasonPhrase;

  /// Headers recevied in response.
  final Map<String, String> headers;

  /// The [rawBody] encoded in `String` by the character set in header or
  /// By default use `utf8` for json and for rest `latin1`
  ///
  /// Hint: If you expect a json string you can use `jsonDecode`
  /// to convert it into a json decodable object
  final String body;

  /// the raw body of the response
  final Uint8List rawBody;

  const CapturedResponse({
    required this.headers,
    required this.statusCode,
    required this.body,
    required this.rawBody,
    this.reasonPhrase,
  });

  factory CapturedResponse.fromHttpResponse(http.Response response) =>
      CapturedResponse(
        headers: response.headers,
        statusCode: response.statusCode,
        body: response.body,
        rawBody: response.bodyBytes,
      );
}
