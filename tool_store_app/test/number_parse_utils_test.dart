import 'package:flutter_test/flutter_test.dart';
import 'package:tool_store_app/model/parsers/number_parse_utils.dart';

void main() {
  group('tryParseLocaleDouble', () {
    test('parses Indonesian thousands separators', () {
      expect(tryParseLocaleDouble('1.874.520'), 1874520);
    });

    test('parses plain numeric strings', () {
      expect(tryParseLocaleDouble('1874520'), 1874520);
      expect(tryParseLocaleDouble('42.5'), 42.5);
    });

    test('parses Indonesian decimal comma', () {
      expect(tryParseLocaleDouble('1.874.520,50'), 1874520.5);
    });
  });

  group('formatPartValueLabel', () {
    test('formats Indonesian part value without crashing', () {
      expect(formatPartValueLabel('1.874.520'), '1.874.520');
    });

    test('returns dash for empty values', () {
      expect(formatPartValueLabel(''), '—');
    });
  });
}
