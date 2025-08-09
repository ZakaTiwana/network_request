import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

import 'json_placeholder/json_placeholder_network_manager.dart';
import 'package:network_request/network_request.dart';
import 'json_placeholder/model/post.dart';
import 'json_placeholder/requests/comment.dart';
import 'json_placeholder/requests/post.dart';
import 'json_placeholder/requests/todo.dart';
import 'mock_api/mock_api_manager.dart';
import 'mock_api/models/mock_user.dart';
import 'mock_api/request/mock_auth.dart';
import 'mock_api/request/mock_user.dart';

void main() {
  exampleJp();
  // exampleAbort();
  // exampleStreamAbort();
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

void exampleMockRefrshFlow() async {
  var network = MockAPIManger();
  // This will trigger tryToReauthenticate
  await network.unAuthUser();
}

// JsonPlaceholderManager
void exampleJp() async {
  var network = JsonPlaceholderManager();
  try {
    await network.getAllPostWithDecodeError();
  } catch (_) {}
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

// Demonstrates aborting an in-flight request using `abortTrigger`.
void exampleAbort() async {
  final network = JsonPlaceholderManager();
  final abort = Completer<void>();

  // Abort shortly after starting.
  Future<void>.delayed(const Duration(milliseconds: 100))
      .then((_) => abort.complete());

  try {
    // Using a simple GET list to demonstrate abort
    await network.call(
      Request<void>(
        method: Method.GET,
        path: '/posts',
        decode: (_) {},
        abortTrigger: abort.future,
      ),
    );
  } on http.RequestAbortedException {
    print('Request was aborted successfully.');
  }
}

// Demonstrates aborting while streaming a large response using downloadProgress
void exampleStreamAbort() async {
  final network = JsonPlaceholderManager();
  final abort = Completer<void>();

  // Fallback: ensure we abort after a second if the progress condition doesn't trigger
  Future<void>.delayed(const Duration(seconds: 1)).then((_) {
    if (!abort.isCompleted) abort.complete();
  });

  try {
    await network.call(
      Request<void>(
        method: Method.GET,
        // A larger endpoint: we'll abort during streaming
        path: '/photos',
        decode: (_) {},
        abortTrigger: abort.future,
        downloadProgress: (bytes, totalBytes, percent) {
          final reachedThreshold = (totalBytes > 0 && percent >= 0.05) ||
              (totalBytes == 0 && bytes > 200 * 1024);
          print(
              'bytes: $bytes, bytes in kb: ${bytes / 1024.0} kb, percent: $percent');
          if (reachedThreshold && !abort.isCompleted) {
            abort.complete();
          }
        },
      ),
    );
  } on http.RequestAbortedException {
    print('Streaming request was aborted while downloading.');
  }
}
