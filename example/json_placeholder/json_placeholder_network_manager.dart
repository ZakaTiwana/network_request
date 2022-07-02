import 'package:network_request/network_request.dart';

class JsonPlaceholderManager extends NetworkRequest {
  @override
  Map<String, String> get authorizationHeader => {};

  @override

  // Thanks @ jsonplaceholder
  String get baseUrl => 'jsonplaceholder.typicode.com';

  @override
  Map<String, String> get defaultHeader => {
        'Content-type': 'application/json',
      };

  @override
  void log(String logString) {
    print(logString);
  }

  @override
  Future<bool> tryToReauthenticate() async {
    return false;
  }

  @override
  Exception? errorDecoder(dynamic data) {
    return null;
  }
}
