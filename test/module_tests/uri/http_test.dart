import 'package:network_request/network_request.dart';
import 'package:test/test.dart';

import '../../network_manger/test_manager.dart';

void allHttpsTest() {
  NetworkRequest sut() {
    return TestNetworkManager();
  }

  test('All https tests - is http', () {
    final network = sut();
    network.isRequestHttps = false;
    final result = network.url(
      Request(
        method: Method.GET,
        path: '/path/to/endpint',
        decode: (_) {},
      ),
    );
    expect(true, result.scheme == 'http');
  });

  test('All https tests - is https', () {
    final network = sut();
    network.isRequestHttps = true;
    final result = network.url(
      Request(
        method: Method.GET,
        path: '/path/to/endpint',
        decode: (_) {},
      ),
    );
    expect(true, result.scheme == 'https');
  });
}
