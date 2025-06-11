import 'dart:convert' as converter;

import 'request_method.dart';
import 'type_def.dart';

// R is result of the Request
class Request<R> {
  const Request({
    required this.method,
    required this.path,
    required this.decode,
    this.version,
    this.query,
    this.headers,
    this.body,
    this.files,
    this.encoding = converter.utf8,
    this.isRefreshRequest = false,
    this.downloadProgress,
    this.uploadProgress,
  });
  final Method method;

  /// Path to enpoint without domain
  ///
  ///     path: '/path/to/endpoint';
  final String path;

  /// If set, it will prefix version to
  /// the enpoint version string e.g `/v1/path/to/endpoint`
  ///
  /// where number is taken from [version]
  ///
  /// [version] should be `> 0`
  final int? version;

  final Query? query;

  /// Headers specific to a request
  final Map<String, String>? headers;

  /// Should be `Map<String, dynamic>` is case of json.
  ///
  /// Should be `Map<String, String>` in case of form url-encoded
  ///
  /// Should be `String` is case of plain/text.
  ///
  /// Should be `Map<String, String>` is case of multipart/form-data body.
  final dynamic body;

  /// Should decode `dynamic` data
  /// to [R]
  ///
  /// data is a json object decoded by [converter.jsonDecode]
  /// if it fails data is returns as `string`
  ///
  /// For example
  ///
  /// ```
  ///   // [Model.fromJson] is a factory method that return `Model`
  ///   // from a `Map<String, dynamic>` or `List` object.
  ///   // see [converter.jsonDecode] for more details
  ///   decode: (json) => Model.fromJson(json)
  ///
  ///   // For `void` (empty) reponse use
  ///   decode: (_) {}
  ///
  ///   // For `string` just return the parameter
  ///   decode: (json) =>  json
  /// ```
  final Decode<R> decode;

  /// Should contain list of files to upload
  final List<dynamic>? files;
  final converter.Encoding encoding;

  /// If its a retry request
  /// then set to `true`
  final bool isRefreshRequest;

  /// Callback to get the progress of the download
  /// [totalBytes] will only be available if response
  /// has `Content-Length` header
  final Progress? downloadProgress;

  /// Callback to get the progress of the upload
  final Progress? uploadProgress;
}
