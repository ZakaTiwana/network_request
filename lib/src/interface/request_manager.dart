import '../model/request.dart';

abstract class NetworkRequestInterface {
  /// Should add default headers used by all Request.
  /// Should return an empty [Map] if don't
  /// want to add any default headers
  Map<String, String> get defaultHeader;

  /// Should add headers like 'Bearer Token' to all Requests.
  /// Should return an empty [Map] if don't
  /// want to add any authorization headers
  Map<String, String> get authorizationHeader;

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

  /// Should encode the body of the request.
  String encodeBody(dynamic requestBody);

  /// Should decode the response from a Request
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
  Future<bool> tryToReauthenticate();

  /// Should gives a formatted string
  /// that can be logged
  void log(String logString);

  /// Should print logs if `true`
  bool enableLog = true;

  /// Should print cURL command to log
  /// if `true`
  bool enableCurlLog = true;
}
