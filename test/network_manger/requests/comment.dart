import 'package:network_request/network_request.dart';

import '../../utils.dart';
import '../model/comment.dart';
import '../test_manager.dart';

extension ExJpCommentNetworkManager on TestNetworkManager {
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
