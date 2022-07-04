import 'dart:convert' as converter;
import 'dart:io';

import 'package:http/retry.dart';

import 'model/request.dart';
import 'interface/request_manager.dart';
import 'package:http/http.dart' as http;

import 'model/api_exception.dart';

/// Use this call to a REST API
/// Extend this manager and add functions
/// for an individual API call which should
/// use [call] method to send the Request
abstract class NetworkRequest implements NetworkRequestInterface {
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

  /// By default uses a retry client.
  ///
  /// Override to add your custom [http.Client]
  http.Client initalizeClient() => RetryClient(http.Client());

  final Map<String, String> headers = {};

  /// By default only [HttpStatus.unauthorized] is
  /// considered. Override to add other status codes.
  List<int> get unautherizedStatusCode => [HttpStatus.unauthorized];

  /// Add request specfic headers used
  /// by [request]. This will override
  /// the headers from [defaultHeader]
  void _addRequestHeader(Request request) {
    final reqHeader = request.headers;
    if (reqHeader == null) return;
    headers.addAll(reqHeader);
  }

  @override

  /// Uses [request] to generate a request
  /// of a network call. If [presistClient] is not provided
  /// then genreate a [http.Client] by [initalizeClient]
  /// and when call is completed then closes the [http.Client].
  ///
  /// if [presistClient] is provided then uses it to
  /// make the call and does not close the [http.Client]
  ///
  /// Throws [ArgumentError] if `request.body` or `request.files` does not conform
  /// to correct type. for multipart/form-data request `request.files` should be [List] of [http.MultipartFile]
  ///
  /// Throws [DecodingError] if `request.decode` was not able to decode data from [decodeBody]
  ///
  /// If response status code does not lie in `200 to < 300` then first
  /// try to throw error decoded from [errorDecoder] And if not successful then
  /// throws [APIException]
  Future<R> call<R>(Request<R> request, {http.Client? presistClient}) async {
    headers.clear();
    headers.addAll(await defaultHeader);
    _addRequestHeader(request);
    headers.addAll(await authorizationHeader);

    bool isMultiPart = headers[HttpHeaders.contentTypeHeader]
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
      httpRequest = http.MultipartRequest(
        request.method.name,
        url(request),
      );
    } else {
      httpRequest = http.Request(request.method.name, url(request));
    }

    httpRequest.headers.addAll(headers);
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
      final response =
          await http.Response.fromStream(await client.send(httpRequest));

      if (!(response.statusCode >= 200 && response.statusCode < 300)) {
        // error from network
        if (unautherizedStatusCode.contains(response.statusCode)) {
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
  Uri url(Request request) => Uri.http(
        baseUrl,
        request.path,
        request.query,
      );

  /// Genrate a string that can be logged
  String _logString(http.BaseRequest request, http.BaseResponse response,
      Map<String, dynamic>? requestBody, dynamic responseBody) {
    StringBuffer sb = StringBuffer('\n======== Network Call Start ========\n');
    sb.writeln('Method: ${request.method}, url: ${request.url}');
    sb.writeln('Header: ${request.headers}');
    sb.writeln('Body: $requestBody');
    sb.writeln('------------ Response ------------');
    sb.writeln('Status Code: ${response.statusCode}');
    sb.writeln('Body: $responseBody');
    sb.write('======== Network Call End ========');
    return sb.toString();
  }

  String _logErrorString(http.BaseRequest request, int? statusCode,
      Map<String, dynamic>? requestBody, Object error) {
    StringBuffer sb = StringBuffer('\n======== Network Call Start ========\n');
    sb.writeln('Method: ${request.method}, url: ${request.url}');
    sb.writeln('Header: ${request.headers}');
    sb.writeln('Body: $requestBody');
    sb.writeln('------------ Response ------------');
    sb.writeln('Status Code: $statusCode');
    sb.writeln('Error: $error');
    sb.write('======== Network Call End ========');
    return sb.toString();
  }

  /// Generates a cURL string for debugging.
  ///
  /// File in form data will only show the filename.
  String _curlString(http.BaseRequest httpRequest, Request request) {
    String result = '';
    result += "curl --request  ${httpRequest.method} '${httpRequest.url}' \\\n";
    if (httpRequest.headers.isNotEmpty) {
      httpRequest.headers.forEach((key, value) {
        result += "--header '$key: $value' \\\n";
      });
    }
    final contentType = headers[HttpHeaders.contentTypeHeader]?.toLowerCase();
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

  /// Handel encoding based upon `Content-Type` in headers.
  /// Able to handel form url-encoded, text plan and defaults to json
  ///
  /// throws [StateError] if `Content-Type` header is not set
  ///
  /// Override to add custom encoding
  String encodeBody(dynamic requestBody,
      {converter.Encoding encoding = converter.utf8}) {
    final contentType = headers[HttpHeaders.contentTypeHeader]?.toLowerCase();
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
