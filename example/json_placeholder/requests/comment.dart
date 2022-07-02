import 'package:network_request/network_request.dart';

import '../json_placeholder_network_manager.dart';
import '../model/comment.dart';
import '../../utils.dart';

extension ExJpCommentNetworkManager on JsonPlaceholderManager {
  Future<List<Comment>> getCommentOfPost(int id) {
    return call(
      Request<List<Comment>>(
        method: Method.GET,
        path: '/comments',
        query: {
          'post': id.toString(),
        },
        decode: (json) =>
            tryToListParseJson(json, (e) => Comment.fromJson(e)) ?? [],
      ),
    );
  }
}
