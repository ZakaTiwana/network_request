import 'dart:convert' as converter;
import 'dart:async';

import 'request_method.dart';
import 'type_def.dart';

/// Request model to make network calls with [R] as result
class Request<R> {
  /// Request model to make network calls with [R] as result
  ///
  /// Required Parameters:
  ///
  /// * [method] is the HTTP method to use
  ///
  /// * [path] is the path to the endpoint without domain
  ///
  /// * [decode] is the function to decode the response, VoidCallback for empty response
  ///
  /// Optional Parameters:
  ///
  /// * [version] is the version of the endpoint
  ///
  /// * [query] is the query parameters to the endpoint
  ///
  /// * [headers] is the headers to the endpoint this will override the default headers
  ///
  /// * [body] is the body to the endpoint
  ///
  /// * [files] is the files to the endpoint
  ///
  /// * [encoding] is the encoding to the endpoint

  const Request({
    required this.method,
    required String path,
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
    this.abortTrigger,
  }) : _path = path;

  final Method method;

  /// Path to enpoint without domain
  ///
  ///     path: '/path/to/endpoint';
  final String _path;

  /// Path to enpoint without domain
  ///
  ///     path: '/path/to/endpoint';
  String get path {
    var computedPath = _path;
    if (!computedPath.startsWith('/')) computedPath = '/$computedPath';
    if (version != null && version! > 0) {
      computedPath = 'v$version$computedPath';
    }
    return computedPath;
  }

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
  ///
  /// [totalBytes] will only be available if response
  /// has `Content-Length` header
  final Progress? downloadProgress;

  /// Callback to get the progress of the upload
  final Progress? uploadProgress;

  /// When completed, attempts to abort the in-flight HTTP request (if the
  /// underlying client supports abortion; e.g. `IOClient`, `BrowserClient`,
  /// `RetryClient`). See `package:http` aborting docs. https://pub.dev/packages/http#aborting-requests
  final Future<void>? abortTrigger;
}
