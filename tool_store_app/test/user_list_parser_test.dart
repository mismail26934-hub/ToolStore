import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tool_store_app/model/parsers/user_list_parser.dart';

void main() {
  group('parseUserListResponse', () {
    test('parses legacy JSON array', () {
      final body = jsonEncode([
        {'id_users': '1', 'username': 'alice'},
      ]);
      final result = parseUserListResponse(body);
      expect(result.total, isNull);
      expect(result.items.single.idUsers, '1');
      expect(result.items.single.username, 'alice');
    });

    test('parses paginated envelope with users key', () {
      final result = parseUserListResponse({
        'total_users': 100,
        'users': [
          {'id_users': '2', 'level': 'ADMIN'},
        ],
      });
      expect(result.total, 100);
      expect(result.items.single.level, 'ADMIN');
    });
  });

  group('parseSuperiorListResponse', () {
    test('parses superiors key in envelope', () {
      final result = parseSuperiorListResponse({
        'recordsTotal': 3,
        'superiors': [
          {'id_users': '9', 'nama_superior': 'Lead'},
        ],
      });
      expect(result.total, 3);
      expect(result.items.single.namaSuperior, 'Lead');
    });

    test('parses legacy array for superiors', () {
      final result = parseSuperiorListResponse([
        {'id_users': '7', 'nama_superior': 'S1'},
      ]);
      expect(result.total, isNull);
      expect(result.items.single.idUsers, '7');
    });
  });
}
