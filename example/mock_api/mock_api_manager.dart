import 'dart:convert';
import 'dart:io';

import 'package:network_request/network_request.dart';

import 'models/mock_api_error.dart';

class MockAPIManger extends NetworkRequest {
  @override
  Map<String, String> get authorizationHeader => {};

  @override
  String get baseUrl => 'localhost:8080';

  @override
  Map<String, String> get defaultHeader => {
        HttpHeaders.contentTypeHeader: 'application/json',
      };

  @override
  Exception? errorDecoder(dynamic data) {
    try {
      return MockAPIError.fromJson(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }

  @override
  void log(String logString) {
    print(logString);
  }

  @override
  Future<bool> tryToReauthenticate() async {
    return false;
  }
}
