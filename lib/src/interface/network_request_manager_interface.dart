import '../model/request.dart';

abstract class NetworkRequestInterface {
  /// Should add default headers used by all Request.
  /// Should return an empty [Map] if don't
  /// want to add any default headers
  Future<Map<String, String>> get defaultHeader;

  /// Should add headers like 'Bearer Token' to all Requests.
  /// Should return an empty [Map] if don't
  /// want to add any authorization headers
  Future<Map<String, String>> get authorizationHeader;

  /// Should have a list of response
  /// status that should trigger [tryToReauthenticate]
  List<int> get unauthorizedStatusCode;

  /// Should have a list of response
  /// status that should trigger the happy flow
  List<int> get successfulResponsesStatusCode;

  /// Should generate the base domain, for all Requests
  ///
  /// Note: should not include `http`, `https` etc.
  /// only the domain name.
  ///
  /// For Example
  ///
  ///     String get baseUrl => 'google.com';
  String get baseUrl;

  /// Should genrate the url for a request
  Uri url(Request request);

  /// Should return a `https` [Uri] object from function [url]
  /// if `true`
  ///
  /// else should return `http` [Uri] object
  bool isRequestHttps = false;

  /// Should encode the body of the request.
  String encodeBody(dynamic requestBody);

  /// Should decode the response from a Request
  /// to somthing that [Request.decode] can handel
  dynamic decodeBody(String responseBody);

  /// Should implement a decoder.
  /// To decode the Error object in
  /// response from the network call.
  ///
  /// If decoding fails then should return `null`.
  /// It should not throw an Exception
  Exception? errorDecoder(dynamic data);

  /// Should handel all the call
  /// to API for all Requests
  Future<R> call<R>(Request<R> request);

  /// should try to re-authenticate
  /// like in case of jwt, can add
  /// refresh token logic here.
  ///
  /// should return `true` in case of successful
  /// re-authtication, else return `false`
  ///
  /// Note: can pass a Network `Client` like `RetryClient`
  /// from `http` package. If a correct [client] passed
  /// then should use it to make the network call and should not
  /// close it. As the same client will be used or closed later
  /// by [call] method
  Future<bool> tryToReauthenticate({dynamic client});

  /// Should gives a formatted string
  /// that can be logged
  void log(String logString);

  /// Should print logs if `true`
  bool enableLog = false;

  /// Should print cURL command to log
  /// if `true`
  bool enableCurlLog = false;

  /// Should format [json] as `String`.
  /// Should use it when creating logs
  String logFormattedJson(dynamic json);

  /// Should trim json string
  /// in logs to make them compact
  bool trimJsonLogs = false;
}
