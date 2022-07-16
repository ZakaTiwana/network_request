import 'package:network_request/network_request.dart';

class TestNetworkManager extends NetworkRequest {
  @override
  Future<Map<String, String>> get authorizationHeader async => {};

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
  Exception? errorDecoder(dynamic data) {
    return null;
  }
}
