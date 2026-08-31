import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:network_request/network_request.dart';
import 'package:network_request/src/model/captured_response.dart';
import 'package:test/test.dart';

import 'model/todo.dart';

class _MockNetworkManager extends NetworkRequest {
  _MockNetworkManager(this._client) {
    enableLog = false;
    enableCurlLog = false;
  }

  final http.Client _client;
  final logs = <String>[];

  @override
  http.Client initalizeClient() => _client;

  @override
  String get baseUrl => 'example.com';

  @override
  Future<Map<String, String>> get authorizationHeader async => {};

  @override
  Future<Map<String, String>> get defaultHeader async => {
        'Content-type': 'application/json',
      };

  @override
  void log(String logString) {
    logs.add(logString);
  }

  @override
  Future<bool> tryToReauthenticate({
    required Request request,
    dynamic client,
  }) async =>
      false;

  @override
  Exception? errorDecoder(CapturedResponse response) => null;
}

class _CustomErrorNetworkManager extends _MockNetworkManager {
  _CustomErrorNetworkManager(super.client);

  @override
  Exception? errorDecoder(CapturedResponse response) {
    return Exception('custom api error');
  }
}

void main() {
  test('GET request succeeds with http 1.6 MockClient', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/todos/1');
      return http.Response(
        jsonEncode({
          'userId': 1,
          'id': 1,
          'title': 'delectus aut autem',
          'completed': false,
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final network = _MockNetworkManager(client);
    final todo = await network.call(
      Request<Todo>(
        method: Method.GET,
        path: '/todos/1',
        decode: (json) => Todo.fromJson(json as Map<String, dynamic>),
      ),
    );

    expect(todo.id, 1);
    expect(todo.title, 'delectus aut autem');
    expect(todo.completed, isFalse);
  });

  test('JSON body does not append charset after http 1.6.0', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response('{"ok": true}', 201,
          headers: {'content-type': 'application/json'});
    });

    final network = _MockNetworkManager(client);
    await network.call(
      Request<void>(
        method: Method.POST,
        path: '/posts',
        body: {'title': 'foo', 'body': 'bar'},
        decode: (_) {},
      ),
    );

    expect(captured.headers['content-type'], 'application/json');
    expect(captured.body, jsonEncode({'title': 'foo', 'body': 'bar'}));
  });

  test('non-success status throws APIException', () async {
    final client = MockClient((request) async {
      return http.Response('{"error": "nope"}', 400,
          headers: {'content-type': 'application/json'});
    });

    final network = _MockNetworkManager(client);
    expect(
      network.call(
        Request<void>(
          method: Method.GET,
          path: '/fail',
          decode: (_) {},
        ),
      ),
      throwsA(isA<APIException>()),
    );
  });

  test('APIException error log does not mention a decode key mismatch',
      () async {
    final client = MockClient((request) async {
      return http.Response('{"error": "nope"}', 400,
          headers: {'content-type': 'application/json'});
    });

    final network = _MockNetworkManager(client)..enableLog = true;
    await expectLater(
      network.call(
        Request<void>(
          method: Method.GET,
          path: '/fail',
          decode: (_) {},
        ),
      ),
      throwsA(isA<APIException>()),
    );

    expect(network.logs, isNotEmpty);
    expect(
      network.logs.join('\n'),
      isNot(contains('keys/types may not match')),
    );
    expect(
      network.logs.join('\n'),
      isNot(contains('key value mismatch')),
    );
  });

  test('custom errorDecoder log does not mention a decode key mismatch',
      () async {
    final client = MockClient((request) async {
      return http.Response('{"error": "nope"}', 403,
          headers: {'content-type': 'application/json'});
    });

    final network = _CustomErrorNetworkManager(client)..enableLog = true;
    await expectLater(
      network.call(
        Request<void>(
          method: Method.GET,
          path: '/fail',
          decode: (_) {},
        ),
      ),
      throwsA(isA<Exception>()),
    );

    final log = network.logs.join('\n');
    expect(log, contains('custom api error'));
    expect(log, isNot(contains('keys/types may not match')));
    expect(log, isNot(contains('key value mismatch')));
    expect(log, contains('Body:'));
  });

  test('DecodingError log explains a model key/type mismatch', () async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({'unexpected': true}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final network = _MockNetworkManager(client)..enableLog = true;
    await expectLater(
      network.call(
        Request<Todo>(
          method: Method.GET,
          path: '/todos/1',
          decode: (json) => Todo.fromJson(json as Map<String, dynamic>),
        ),
      ),
      throwsA(isA<DecodingError<Todo>>()),
    );

    final log = network.logs.join('\n');
    expect(
      log,
      contains(
        'Decode failed. Compare the raw response below with your decode function (keys/types may not match).',
      ),
    );
    expect(log, contains('unexpected'));
  });
}
