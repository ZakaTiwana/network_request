import 'package:network_request/network_request.dart';
import 'package:test/test.dart';

import '../../network_manger/test_manager.dart';

void allVersionTests() {
  NetworkRequest sut() {
    return TestNetworkManager();
  }

  test('All version tests - no version', () {
    final network = sut();
    final result = network.url(
      Request(
        method: Method.GET,
        path: '/path/to/endpint',
        decode: (_) {},
      ),
    );
    expect(true, result.path == '/path/to/endpint');
  });

  test('All version tests - v1 prefixed', () {
    final network = sut();
    final result = network.url(
      Request(
          method: Method.GET,
          path: '/path/to/endpint',
          decode: (_) {},
          version: 1),
    );
    expect(true, result.path == '/v1/path/to/endpint');
  });

  test('All version tests -  no version when 0 passed', () {
    final network = sut();
    final result = network.url(
      Request(
        method: Method.GET,
        path: '/path/to/endpint',
        decode: (_) {},
        version: 0,
      ),
    );
    expect(true, result.path == '/path/to/endpint');
  });

  test('All version tests -  no version when < 0 passed', () {
    final network = sut();
    final result = network.url(
      Request(
        method: Method.GET,
        path: '/path/to/endpint',
        decode: (_) {},
        version: -1,
      ),
    );
    expect(true, result.path == '/path/to/endpint');
  });
}
