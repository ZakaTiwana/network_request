import 'package:network_request/network_request.dart';

import '../mock_api_manager.dart';

extension ExMockAuthAPIManager on MockAPIManger {
  Future<String> unAuthUser() {
    return call(
      Request(
        method: Method.PATCH,
        path: '/auth/unauth',
        decode: (json) => json,
      ),
    );
  }
}
