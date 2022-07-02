import 'dart:convert' as converter;

import 'request_method.dart';
import 'type_def.dart';

// R is result of the Request
class Request<R> {
  const Request({
    required this.method,
    required this.path,
    required this.decode,
    this.query,
    this.headers,
    this.body,
    this.files,
    this.encoding = converter.utf8,
  });
  final Method method;

  /// path to enpoint without domain
  ///
  ///     example = '/path/to/endpoint';
  final String path;

  final Query? query;

  /// header specific to a request
  final Map<String, String>? headers;

  /// Should be `Map<String, dynamic>` is case of json.
  ///
  /// Should be `Map<String, String>` in case of form url-encoded
  ///
  /// Should be `String` is case of plain/text.
  ///
  /// Should be `Map<String, String>` is case of multipart/form-data body.
  final dynamic body;

  final Decode<R> decode;

  /// Should contain list of files to upload
  final List<dynamic>? files;
  final converter.Encoding encoding;
}
