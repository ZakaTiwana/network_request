import 'package:network_request/network_request.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'network_manger/test_manager.dart';

void main() {
  group('[All log tests]', _allLogTests);
}

void _allLogTests() {
  NetworkRequest sut() {
    return TestNetworkManager();
  }

  test('Log Formatted Json test - on 1000 characters', () {
    final network = sut();
    Map<String, dynamic> json = {
      'test': '1' * (500 - 8 - 6),
      'test2': '2' * (500 - 8 - 7)
    };
    final result = network.logFormattedJson(json);
    expect(false, result.contains('\n...\n'));
  });

  test('Log Formatted Json test - on 2000 characters', () {
    final network = sut();
    Map<String, dynamic> json = {
      'test': '1' * (1000 - 8 - 6),
      'test2': '2' * (1000 - 8 - 7)
    };
    final result = network.logFormattedJson(json);
    expect(false, result.contains('\n...\n'));
  });

  test('Log Formatted Json test - on 2001 characters', () {
    final network = sut();
    Map<String, dynamic> json = {
      'test': '1' * (1000 - 8 - 6),
      'test2': '2' * (1000 - 8 - 6)
    };
    final result = network.logFormattedJson(json);
    expect(true, result.contains('\n...\n'));
  });

  test('Log Formatted Json test - on > 2001 characters', () {
    final network = sut();
    Map<String, dynamic> json = {'test': '1' * 3021, 'test2': '2' * 1300};
    final result = network.logFormattedJson(json);
    expect(true, result.contains('\n...\n'));
  });
}
