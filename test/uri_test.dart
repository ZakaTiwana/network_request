import 'package:network_request/network_request.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'main.dart';

void main() {
  group('[All version tests]', _allVersionTests);
  group('[All https tests]', _allHttpsTest);
}

void _allVersionTests() {
  test('All version tests - no version', () {
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

void _allHttpsTest() {
  test('All https tests - is http', () {
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
