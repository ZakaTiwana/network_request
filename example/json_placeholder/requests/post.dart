import 'package:network_request/network_request.dart';
import 'package:http/http.dart' as http;

import '../../../test/utils.dart';
import '../json_placeholder_network_manager.dart';
import '../model/post.dart';

extension ExJpPostNetworkManager on JsonPlaceholderManager {
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

  Future<List<Post>> getAllPost() {
    return call(
      Request<List<Post>>(
        method: Method.GET,
        path: '/posts',
        decode: (json) =>
            tryToListParseJson(json, (e) => Post.fromJson(e)) ?? [],
      ),
    );
  }

  Future<List<PostWithDecodeError>> getAllPostWithDecodeError() {
    return call(
      Request<List<PostWithDecodeError>>(
        method: Method.GET,
        path: '/posts',
        decode: (json) =>
            (json as List).map((e) => PostWithDecodeError.fromJson(e)).toList(),
      ),
    );
  }
}
