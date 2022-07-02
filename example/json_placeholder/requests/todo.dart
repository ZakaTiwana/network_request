import '../model/todo.dart';
import '../json_placeholder_network_manager.dart';
import 'package:network_request/network_request.dart';

import '../../utils.dart';

extension ExJpTodoNetworkManager on JsonPlaceholderManager {
  Future<Todo> getTodo(int id) {
    return call(
      Request<Todo>(
        method: Method.GET,
        path: '/todos/$id',
        decode: (json) => Todo.fromJson(json),
      ),
    );
  }

  Future<List<Todo>> getAllTodos() {
    return call(
      Request<List<Todo>>(
        method: Method.GET,
        path: 'todos',
        decode: (json) =>
            tryToListParseJson(json, (e) => Todo.fromJson(e)) ?? [],
      ),
    );
  }
}
