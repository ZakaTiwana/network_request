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
    var dCount = 0;
    var upCount = 0;
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
        downloadProgress: (bytes, totalBytes, percent) {
          dCount += 1;
          print(
              "[uploadPicture - $dCount] downloadProgress - bytes: $bytes, totalBytes: $totalBytes, percent: $percent");
        },
        uploadProgress: (bytes, totalBytes, percent) {
          upCount += 1;
          print(
              "[uploadPicture - $upCount] uploadProgress - bytes: $bytes, totalBytes: $totalBytes, percent: $percent");
        },
      ),
    );
  }

  Future<void> downloadPicture() async {
    var dCount = 0;
    var upCount = 0;
    return call(
      Request(
        method: Method.GET,
        path: '/pic/test.png',
        decode: (json) => json,
        downloadProgress: (bytes, totalBytes, percent) {
          dCount += 1;
          print(
              "[downloadPicture - $dCount] downloadProgress - bytes: $bytes, totalBytes: $totalBytes, percent: $percent");
        },
        uploadProgress: (bytes, totalBytes, percent) {
          upCount += 1;
          print(
              "[downloadPicture - $upCount] uploadProgress - bytes: $bytes, totalBytes: $totalBytes, percent: $percent");
        },
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
