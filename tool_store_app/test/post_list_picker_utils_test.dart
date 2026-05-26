import 'package:flutter_test/flutter_test.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/view/custom/picker/post_list_picker_utils.dart';

PostList _superior({
  String id = '1',
  String namaSuperior = 'Sup A',
  String namaUser = '',
  String username = 'supa',
}) {
  return PostList.fromJson({
    'id_users': id,
    'nama_superior': namaSuperior,
    'nama_user': namaUser,
    'username': username,
  });
}

void main() {
  group('superiorPickerTitle', () {
    test('prefers nama_superior then nama_user then username', () {
      expect(
        superiorPickerTitle(_superior(namaSuperior: 'Lead', namaUser: 'User')),
        'Lead',
      );
      expect(
        superiorPickerTitle(
          _superior(namaSuperior: '', namaUser: 'User', username: 'u1'),
        ),
        'User',
      );
      expect(
        superiorPickerTitle(
          _superior(namaSuperior: '', namaUser: '', username: 'u1'),
        ),
        'u1',
      );
    });
  });

  group('dedupeSuperiorRows', () {
    test('removes duplicate keys', () {
      final list = [
        _superior(id: '1', namaSuperior: 'A'),
        _superior(id: '1', namaSuperior: 'A'),
      ];
      expect(dedupeSuperiorRows(list), hasLength(1));
    });
  });

  group('filterUsersByLevel', () {
    test('filters by level case-insensitively', () {
      final users = [
        PostList.fromJson({'id_users': '1', 'level': 'ADMIN'}),
        PostList.fromJson({'id_users': '2', 'level': 'USER'}),
      ];
      final filtered = filterUsersByLevel(users, 'admin');
      expect(filtered, hasLength(1));
      expect(filtered.first.idUsers, '1');
    });
  });
}
