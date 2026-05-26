import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tool_store_app/model/parsers/form_list_parser.dart';

void main() {
  group('parseFormListResponse', () {
    test('parses legacy JSON array', () {
      final body = jsonEncode([
        {'id_form': '1', 'form_no': 'F-001'},
        {'id_form': '2', 'form_no': 'F-002'},
      ]);
      final result = parseFormListResponse(body);
      expect(result.total, isNull);
      expect(result.items, hasLength(2));
      expect(result.items.first.idForm, '1');
      expect(result.items.first.formNo, 'F-001');
    });

    test('parses paginated envelope with forms key', () {
      final body = {
        'total': 42,
        'forms': [
          {'id_form': '10', 'form_milestone': 'Draft'},
        ],
      };
      final result = parseFormListResponse(body);
      expect(result.total, 42);
      expect(result.items, hasLength(1));
      expect(result.items.first.idForm, '10');
      expect(result.items.first.formMilestone, 'Draft');
    });

    test('parses string total from envelope', () {
      final body = {
        'total_count': '5',
        'data': [
          {'id_form': '3'},
        ],
      };
      final result = parseFormListResponse(body);
      expect(result.total, 5);
      expect(result.items, hasLength(1));
    });

    test('returns empty items when map has total but no list key', () {
      final result = parseFormListResponse({'total': 0});
      expect(result.total, 0);
      expect(result.items, isEmpty);
    });

    test('throws on unexpected type', () {
      expect(() => parseFormListResponse(123), throwsFormatException);
    });
  });
}
