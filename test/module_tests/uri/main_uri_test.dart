import 'package:test/test.dart' show group;
import 'https_tests.dart';
import 'version_tests.dart';

void main() {
  group('[All version tests]', allVersionTests);
  group('[All https tests]', allHttpsTest);
}
