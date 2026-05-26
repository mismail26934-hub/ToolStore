import 'package:flutter_test/flutter_test.dart';
import 'package:tool_store_app/view/menu/user/user_data_logic.dart';

void main() {
  group('UserDataLogic.isSuperAdminLevel', () {
    test('accepts SUPERADMIN case-insensitively', () {
      expect(UserDataLogic.isSuperAdminLevel('superadmin'), isTrue);
      expect(UserDataLogic.isSuperAdminLevel('TOOL_KEEPER'), isFalse);
    });
  });

  group('UserDataLogic.displayValue', () {
    test('returns dash for empty values', () {
      expect(UserDataLogic.displayValue(null), '-');
      expect(UserDataLogic.displayValue('  '), '-');
      expect(UserDataLogic.displayValue('  alice '), 'alice');
    });
  });

  group('UserDataLogic.userStatusTone', () {
    test('classifies active and inactive labels', () {
      expect(UserDataLogic.userStatusTone('Active'), UserDataStatusTone.active);
      expect(UserDataLogic.userStatusTone('aktif'), UserDataStatusTone.active);
      // Legacy: "Inactive" contains "active" → active tone.
      expect(
        UserDataLogic.userStatusTone('Inactive'),
        UserDataStatusTone.active,
      );
      // "Nonaktif" contains "aktif" → active (same as legacy UI).
      expect(
        UserDataLogic.userStatusTone('Nonaktif'),
        UserDataStatusTone.active,
      );
      expect(
        UserDataLogic.userStatusTone('disabled'),
        UserDataStatusTone.inactive,
      );
      expect(UserDataLogic.userStatusTone('pending'), UserDataStatusTone.other);
    });
  });
}
