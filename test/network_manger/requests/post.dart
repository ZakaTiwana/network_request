import 'package:network_request/network_request.dart';
import 'package:http/http.dart' as http;

import '../model/post.dart';
import '../test_manager.dart';

extension ExJpPostNetworkManager on TestNetworkManager {
  Future<Post> addPost(Post post, {http.Client? client}) {
    return call(
      Request<Post>(
        method: Method.POST,
        path: '/posts',
        body: post.toMap(),
        decode: (json) => Post.fromJson(json),
      ),
      presistClient: client,
    );
  }

  Future<void> deletePost(int id, {http.Client? client}) {
    return call(
      Request<void>(
        method: Method.DELETE,
        path: '/posts/$id',
        decode: (_) {},
      ),
      presistClient: client,
    );
  }
}
