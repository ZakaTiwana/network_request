import 'dart:async';
import 'dart:convert' as converter;
import 'dart:io';

import 'package:http/retry.dart';
import 'package:network_request/src/multipart_request_with_progress.dart';
import 'package:collection/collection.dart' show CanonicalizedMap;

import 'model/request.dart';
import 'interface/network_request_manager_interface.dart';
import 'package:http/http.dart' as http;

import 'model/api_exception.dart';
import 'request_with_progress.dart';

/// Extend this manager and add the required override. Then add methods
/// to hit API endpoints through [call] method.
abstract class NetworkRequest implements NetworkRequestInterface {
  @override

  /// Does not trims String in logs if `false`
  ///
  /// Override to disable
  bool trimJsonLogs = true;

  @override

  /// Does not call [log] if `false`
  ///
  /// Override to disable
  bool enableLog = true;

  @override

  /// Does not log cURL commannd if `false`
  ///
  /// Override to disable
  bool enableCurlLog = true;

  @override

  /// Returns a `http` [Uri] object from function [url]
  ///
  /// Override to return a `https` [Uri] object
  bool isRequestHttps = true;

  /// By default uses a retry client.
  ///
  /// Override to add your custom [http.Client]
  http.Client initalizeClient() => RetryClient(http.Client());

  /// Don't override.
  /// Can lead to unexpected behaviours; its used internally
  /// In future release will make it private.
  final Map<String, String> _headers = {};

  @override

  /// By default only [HttpStatus.unauthorized] trigger's
  /// [tryToReauthenticate].
  ///
  /// Override to add other status codes.
  List<int> get unauthorizedStatusCode => [HttpStatus.unauthorized];

  /// By default its [200...299]
  ///
  /// Override to add other status codes.
  @override
  List<int> get successfulResponsesStatusCode =>
      List.generate(100, (index) => 200 + index);

  /// Add request specfic headers used
  /// by [request]. This will override
  /// the headers from [defaultHeader]
  void _addRequestHeader(Request request, CanonicalizedMap canonicalizedMap) {
    final reqHeader = request.headers;
    if (reqHeader == null) return;
    canonicalizedMap.addAll(reqHeader);
  }

  @override

  /// Uses [request] to generate a request
  /// of a network call. If [presistClient] is not provided
  /// then genreates a [http.Client] by [initalizeClient]
  /// and when the API call is completed it closes the [http.Client].
  ///
  /// if [presistClient] is provided then uses it to
  /// make the API call and does not close the [http.Client]
  ///
  /// Throws [ArgumentError] if `request.body` or `request.files` does not conform
  /// to correct type. for multipart/form-data request `request.files` should be [List] of [http.MultipartFile]
  ///
  /// Throws [DecodingError] if `request.decode` was not able to decode data from [decodeBody]
  ///
  /// If response status code does not lie in [successfulResponsesStatusCode] (which defaults to 200...299) then first
  /// try to throw error decoded from [errorDecoder] And if that i not successful then
  /// throws [APIException]
  Future<R> call<R>(Request<R> request, {http.Client? presistClient}) async {
    var canonicalizedMap =
        CanonicalizedMap<String, String, String>((key) => key.toLowerCase());
    _headers.clear();
    canonicalizedMap.addAll(await defaultHeader);
    _addRequestHeader(request, canonicalizedMap);
    canonicalizedMap.addAll(await authorizationHeader);
    _headers.addAll(canonicalizedMap.toMapOfCanonicalKeys());
    canonicalizedMap.clear();

    bool isMultiPart = _headers[HttpHeaders.contentTypeHeader]
            ?.toLowerCase()
            .contains('multipart/form-data') ==
        true;
    if (!isMultiPart && request.files?.isNotEmpty == true) {
      throw StateError(
        'if `request.files` is not empty then need to set content-type header to "${HttpHeaders.contentTypeHeader}: multipart/form-data"',
      );
    }
    final http.BaseRequest httpRequest;
    if (isMultiPart) {
      if (request.uploadProgress != null) {
        httpRequest = MultipartRequestWithProgress(
          request.method.name,
          url(request),
          request.uploadProgress!,
        );
      } else {
        httpRequest = http.MultipartRequest(
          request.method.name,
          url(request),
        );
      }
    } else {
      httpRequest = RequestWithProgress(
        request.method.name,
        url(request),
        request.uploadProgress,
      );
    }

    httpRequest.headers.addAll(_headers);
    final body = request.body;
    if (body != null) {
      if (isMultiPart && httpRequest is http.MultipartRequest) {
        try {
          httpRequest.fields.addAll(Map<String, String>.from(body));
        } catch (_) {
          throw ArgumentError.value(
            body,
            'request.body',
            'need to conform to Map<String, String>',
          );
        }
      } else if (httpRequest is http.Request) {
        httpRequest.body = encodeBody(body);
      } else {
        throw StateError('Unhandeled Client type');
      }
    }
    final reqFiles = request.files;
    if (reqFiles != null && httpRequest is http.MultipartRequest) {
      final List<http.MultipartFile> files;
      try {
        files = List<http.MultipartFile>.from(reqFiles);
      } catch (_) {
        throw ArgumentError.value(
          body,
          'request.files',
          'need to conform to List<MultipartFile>',
        );
      }
      httpRequest.files.addAll(files);
    }
    final client = presistClient ?? initalizeClient();
    if (enableLog & enableCurlLog) {
      log(_curlString(httpRequest, request));
    }
    try {
      final streamedResponse = await client.send(httpRequest);

      http.Response response;
      if (request.downloadProgress != null) {
        int bytesRecieved = 0;
        List<int> bytes = [];
        final totalBytes = streamedResponse.contentLength ?? 0;
        await for (var data in streamedResponse.stream) {
          bytes.addAll(data);
          bytesRecieved += data.length;
          request.downloadProgress!(
              bytesRecieved, totalBytes, bytesRecieved / totalBytes);
        }
        response = http.Response.bytes(
          bytes,
          streamedResponse.statusCode,
          request: streamedResponse.request,
          headers: streamedResponse.headers,
          isRedirect: streamedResponse.isRedirect,
          persistentConnection: streamedResponse.persistentConnection,
          reasonPhrase: streamedResponse.reasonPhrase,
        );
      } else {
        response = await http.Response.fromStream(streamedResponse);
      }

      final unsuccessfulResponse =
          successfulResponsesStatusCode.contains(response.statusCode) == false;

      if (unsuccessfulResponse) {
        // error from network
        if (request.isRefreshRequest) {
          throw APIException(
              response.statusCode, 'Error from network in Refresh Request');
        }
        if (unauthorizedStatusCode.contains(response.statusCode)) {
          try {
            if (await tryToReauthenticate(client: client)) {
              return await call(request, presistClient: client);
            }
          } catch (_) {}
        }
        final error = errorDecoder(response.body);
        if (error != null) throw error;
        throw APIException(response.statusCode, response.body);
      }

      final responseBody = decodeBody(response.body);
      if (enableLog) log(_logString(httpRequest, response, body, responseBody));
      try {
        return request.decode(responseBody);
      } catch (error) {
        throw DecodingError(
            'Decoding Error, while using `decode` of ${Request<R>}: $error');
      }
    } catch (error) {
      if (enableLog) {
        log(_logErrorString(httpRequest,
            error is APIException ? error.statusCode : null, body, error));
      }
      rethrow;
    } finally {
      if (presistClient == null) client.close();
    }
  }

  @override

  /// Default to a `http` URL
  ///
  /// Override to generate `https` URL
  Uri url(Request request) {
    var path = request.path;
    if (!path.startsWith('/')) path = '/$path';
    var version = request.version;
    if (version != null && version > 0) path = 'v$version$path';

    if (isRequestHttps) {
      return Uri.https(
        baseUrl,
        path,
        request.query,
      );
    } else {
      return Uri.http(
        baseUrl,
        path,
        request.query,
      );
    }
  }

  /// Genrate a string that can be logged
  String _logString(http.BaseRequest request, http.BaseResponse response,
      Map<String, dynamic>? requestBody, dynamic responseBody) {
    StringBuffer sb = StringBuffer('\n======== Network Call Start ========\n');
    sb.writeln('Method: ${request.method}, url: ${request.url}');
    sb.writeln('Header: ${logFormattedJson(request.headers)}');
    sb.writeln('Body: ${logFormattedJson(requestBody)}');
    sb.writeln('------------ Response ------------');
    sb.writeln('Status Code: ${response.statusCode}');
    sb.writeln('Body: ${logFormattedJson(responseBody)}');
    sb.write('======== Network Call End ========');
    return sb.toString();
  }

  /// Generate Erroo log string
  String _logErrorString(http.BaseRequest request, int? statusCode,
      Map<String, dynamic>? requestBody, Object error) {
    StringBuffer sb = StringBuffer('\n======== Network Call Start ========\n');
    sb.writeln('Method: ${request.method}, url: ${request.url}');
    sb.writeln('Header: ${logFormattedJson(request.headers)}');
    sb.writeln('Body: ${logFormattedJson(requestBody)}');
    sb.writeln('------------ Response ------------');
    sb.writeln('Status Code: $statusCode');
    sb.writeln('Error: ${logFormattedJson(error)}');
    sb.write('======== Network Call End ========');
    return sb.toString();
  }

  /// Generates a cURL string for debugging.
  ///
  /// File in 'multipart/form-data' will only show the filename.
  String _curlString(http.BaseRequest httpRequest, Request request) {
    String result = '';
    result += "curl --request  ${httpRequest.method} '${httpRequest.url}' \\\n";
    if (httpRequest.headers.isNotEmpty) {
      httpRequest.headers.forEach((key, value) {
        result += "--header '$key: $value' \\\n";
      });
    }
    final contentType = _headers[HttpHeaders.contentTypeHeader]?.toLowerCase();
    if (contentType == null) {
      // remove extra '/' & '/n' from last header
      result = result.substring(0, result.length - 2);
      return result;
    }
    final body = request.body;
    List<http.MultipartFile> files = [];
    try {
      files = List<http.MultipartFile>.from(request.files ?? []);
    } catch (_) {}

    final isMultipart = contentType.contains('multipart/form-data');
    final isFormUrlEncoded =
        contentType.contains('application/x-www-form-urlencoded');
    final isPlain = contentType.contains('text/plain');
    final isJson = contentType.contains('application/json');

    if (isJson && body is Map<String, dynamic> && body.isNotEmpty) {
      result += "--data-raw '${converter.jsonEncode(body)}'";
      return result;
    } else if (isPlain && body is String) {
      result += "--data-raw '$body'";
      return result;
    } else if (isFormUrlEncoded &&
        body is Map<String, String> &&
        body.isNotEmpty) {
      body.forEach((key, value) {
        result += "--data-urlencode '$key=$value' \\\n";
      });
      // remove extra '/' & '/n' from last header
      result = result.substring(0, result.length - 2);
      return result;
    } else if (isMultipart &&
        ((body is Map<String, String> && body.isNotEmpty) ||
            files.isNotEmpty)) {
      if (body is Map<String, String> && body.isNotEmpty) {
        body.forEach((key, value) {
          result += "--form '$key=\"$value\"' \\\n";
        });
      }
      if (files.isNotEmpty) {
        for (var file in files) {
          result += "--form '${file.field}=@<add-path>/${file.filename}' \\\n";
        }
        result = result.substring(0, result.length - 2);
        return result;
      }
    }
    // remove extra '/' & '/n' from last header
    result = result.substring(0, result.length - 2);
    return result;
  }

  @override

  /// Uses [converter.JsonEncoder] to formate the
  /// [json] for logs.
  ///
  /// If fails then return the `json.toString()`
  String logFormattedJson(json) {
    try {
      var encoded = converter.JsonEncoder.withIndent(' ').convert(json);
      if (!trimJsonLogs) return encoded;

      // trims log if greator than 2000
      if (encoded.length > 2000) {
        int toTrim = encoded.length - (2000 - 1);
        int middle = encoded.length ~/ 2;
        int trimMiddle = toTrim ~/ 2;
        encoded = encoded.replaceRange(
            middle - trimMiddle, middle + trimMiddle, '\n...\n');
      }
      return encoded;
    } catch (e) {
      return json.toString();
    }
  }

  @override

  /// By default json decoding is used.
  /// If empty then return `void`.
  /// if fails then return the [responseBody] string itself
  ///
  /// override to add custom decoding
  dynamic decodeBody(String responseBody) {
    // empty response
    if (responseBody.isEmpty) return;
    try {
      return converter.jsonDecode(responseBody);
    } catch (e) {
      return responseBody;
    }
  }

  @override

  /// Handle encoding based upon `Content-Type` in headers.
  /// Able to handle `x-www-form-urlencoded`, `multipart/form-data`, `text plan` and defaults to `json`
  ///
  /// throws [StateError] if `Content-Type` header is not set
  ///
  /// Override to add custom encoding
  String encodeBody(dynamic requestBody,
      {converter.Encoding encoding = converter.utf8}) {
    final contentType = _headers[HttpHeaders.contentTypeHeader]?.toLowerCase();
    if (contentType == null) {
      throw StateError(
          "Header, ${HttpHeaders.contentTypeHeader} cannot be null");
    }
    final isFormUrlEncoded =
        contentType.contains('application/x-www-form-urlencoded');
    final isPlain = contentType.contains('text/plain');

    if (isFormUrlEncoded) {
      final Map<String, String> body;
      try {
        body = Map<String, String>.from(requestBody);
      } catch (_) {
        throw ArgumentError.value(
          requestBody,
          'requestBody',
          'need to be conform to Map<String, String>',
        );
      }
      return _mapToQuery(body, encoding: encoding);
    } else if (isPlain) {
      final String body;
      try {
        body = requestBody as String;
      } catch (_) {
        throw ArgumentError.value(
          requestBody,
          'requestBody',
          'need to be conform to String',
        );
      }
      return body;
    }
    return converter.jsonEncode(requestBody);
  }

  /// Converts a [Map] from parameter names to values to a URL query string.
  ///
  ///     mapToQuery({"foo": "bar", "baz": "bang"});
  ///     //=> "foo=bar&baz=bang"
  ///
  /// Copied from http package
  String _mapToQuery(Map<String, String> map, {converter.Encoding? encoding}) {
    var pairs = <List<String>>[];
    map.forEach((key, value) => pairs.add([
          Uri.encodeQueryComponent(key, encoding: encoding ?? converter.utf8),
          Uri.encodeQueryComponent(value, encoding: encoding ?? converter.utf8)
        ]));
    return pairs.map((pair) => '${pair[0]}=${pair[1]}').join('&');
  }
}
