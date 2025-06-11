import 'dart:convert';
import 'dart:io';

import 'package:network_request/network_request.dart';
import 'package:network_request/src/model/captured_response.dart';

import 'models/mock_api_error.dart';

class MockAPIManger extends NetworkRequest {
  @override
  Future<Map<String, String>> get authorizationHeader async => {};

  @override
  String get baseUrl => 'localhost:8080';

  @override
  Future<Map<String, String>> get defaultHeader async => {
        HttpHeaders.contentTypeHeader: 'application/json',
      };

  @override
  Exception? errorDecoder(CapturedResponse response) {
    try {
      return MockAPIError.fromJson(jsonDecode(response.body));
    } catch (_) {
      return null;
    }
  }

  @override
  void log(String logString) {
    print(logString);
  }

  @override
  Future<bool> tryToReauthenticate({dynamic client}) async {
    return false;
  }

  @override
  bool get isRequestHttps => false;
}
