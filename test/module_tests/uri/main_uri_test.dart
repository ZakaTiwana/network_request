import 'package:test/test.dart' show group;
import 'http_test.dart';
import 'version_test.dart';

void main() {
  group('[All version tests]', allVersionTests);
  group('[All https tests]', allHttpsTest);
}
