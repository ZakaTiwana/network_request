import 'package:network_request/network_request.dart';
import 'package:network_request/src/model/captured_response.dart';

export 'requests/comment.dart';
export 'requests/post.dart';
export 'requests/todo.dart';

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
  Future<bool> tryToReauthenticate({
    required Request request,
    dynamic client,
  }) async {
    return false;
  }

  @override
  Exception? errorDecoder(CapturedResponse response) {
    return null;
  }
}
