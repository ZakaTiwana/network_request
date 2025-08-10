import 'dart:io';

import 'package:network_request/network_request.dart';
import 'package:network_request/src/model/captured_response.dart';

class JsonPlaceholderManager extends NetworkRequest {
  @override
  Future<Map<String, String>> get authorizationHeader async => {
        HttpHeaders.authorizationHeader: 'Bearer 1234567890',
      };

  @override

  // Thanks @ jsonplaceholder
  String get baseUrl => 'jsonplaceholder.typicode.com';

  @override
  Future<Map<String, String>> get defaultHeader async => {
        'Content-type': 'application/json',
      };

  @override
  void log(String logString) {
    print(logString);
  }

  @override
  Future<bool> tryToReauthenticate({dynamic client}) async {
    return false;
  }

  @override
  Exception? errorDecoder(CapturedResponse response) {
    return null;
  }
}
