import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

import 'json_placeholder/json_placeholder_network_manager.dart';
import 'json_placeholder/model/post.dart';
import 'json_placeholder/requests/comment.dart';
import 'json_placeholder/requests/post.dart';
import 'json_placeholder/requests/todo.dart';
import 'mock_api/mock_api_manager.dart';
import 'mock_api/models/mock_user.dart';
import 'mock_api/request/mock_user.dart';

void main() {
  exampleJp();
}

// MockAPIManger

void exampleMockAPIFormData() async {
  var network = MockAPIManger();
  await network.uploadPicture(1);
  await network.downloadPicture();
}

void exampleMockAPIUrlFormEncoded() {
  var network = MockAPIManger();
  network.addUserFromUrlEncoded(
    MockAPIUser(
      id: 1001,
      name: 'Mock',
      profilePic: null,
    ),
  );
}

void exampleMockAPI() {
  var network = MockAPIManger();
  network.fetchUser(1);
  network.addUser(MockAPIUser(id: 1001, name: 'Mock', profilePic: null));
  network.getError(1);
}

// JsonPlaceholderManager
void exampleJp() {
  var network = JsonPlaceholderManager();
  network.getTodo(1);
  network.getCommentOfPost(1);
}

void presistExampleJp() async {
  final network = JsonPlaceholderManager();
  final presistClient = RetryClient(http.Client());

  final futures = <Future>[];
  futures.addAll([
    network.addPost(
      Post(
        id: -1,
        userId: 1,
        title: 'Example',
        body: 'Example body',
      ),
      client: presistClient,
    ),
    network.deletePost(1, client: presistClient)
  ]);
  await Future.wait(futures);
  presistClient.close();
}
