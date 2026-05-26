/// User list status tone for card chips (UI maps to [Color]).
enum UserDataStatusTone {
  active,
  inactive,
  other,
}

/// Pure user-data logic (no widgets / Redux).
abstract final class UserDataLogic {
  UserDataLogic._();

  static bool isSuperAdminLevel(String raw) =>
      raw.trim().toUpperCase() == 'SUPERADMIN';

  static String displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    return value.trim();
  }

  static UserDataStatusTone userStatusTone(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('active') || normalized.contains('aktif')) {
      return UserDataStatusTone.active;
    }
    if (normalized.contains('inactive') ||
        normalized.contains('nonaktif') ||
        normalized.contains('disable')) {
      return UserDataStatusTone.inactive;
    }
    return UserDataStatusTone.other;
  }
}
