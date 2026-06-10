/// Parses numeric strings from API/user input, including Indonesian formatting
/// (e.g. `1.874.520` or `1.874.520,50`).
double? tryParseLocaleDouble(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;

  final direct = double.tryParse(s);
  if (direct != null) return direct;

  if (s.contains(',')) {
    final normalized = s.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  if (s.contains('.')) {
    return double.tryParse(s.replaceAll('.', ''));
  }

  return null;
}

/// Formats integers with Indonesian thousand separators (no intl locale data).
String formatIndonesianInteger(num value) {
  final rounded = value.round();
  final negative = rounded < 0;
  final digits = rounded.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }
  final formatted = buffer.toString();
  return negative ? '-$formatted' : formatted;
}

String formatPartValueLabel(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '—';

  final parsed = tryParseLocaleDouble(trimmed);
  if (parsed == null) return trimmed;

  return formatIndonesianInteger(parsed);
}
