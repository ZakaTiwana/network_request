import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:network_request/network_request.dart';

import '../mock_api_manager.dart';
import '../models/mock_user.dart';

extension ExMockAPIManager on MockAPIManger {
  Future<MockAPIUser> fetchUser(int id) {
    return call(
      Request(
        method: Method.GET,
        path: '/user/$id',
        decode: (json) => MockAPIUser.fromJson(json),
      ),
    );
  }

  Future<void> addUser(MockAPIUser user) {
    return call(
      Request(
        method: Method.POST,
        path: '/user',
        body: user.toMap(),
        decode: (_) {},
      ),
    );
  }

  Future<void> addUserFromUrlEncoded(MockAPIUser user) {
    return call(
      Request(
        method: Method.POST,
        path: '/user',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        },
        body: user.toMapOnlyString(),
        decode: (_) {},
      ),
    );
  }

  Future<String> uploadPicture(int id) async {
    return call(
      Request(
        method: Method.POST,
        path: '/user/$id/pic',
        headers: {
          HttpHeaders.contentTypeHeader: 'multipart/form-data',
        },
        body: {
          'test': 'test form data',
        },
        files: [
          await http.MultipartFile.fromPath(
              'file', '${Directory.current.path}/assets/test.png'),
        ],
        decode: (json) => json,
      ),
    );
  }

  Future<void> getError(int id) {
    return call<void>(
      Request(
        method: Method.GET,
        path: '/user/error/$id',
        decode: (_) {},
      ),
    );
  }
}
