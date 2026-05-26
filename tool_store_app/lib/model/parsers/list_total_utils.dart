/// Reads total count from paginated API envelope maps.
int? readTotalFromMap(Map<String, dynamic> m) {
  for (final key in [
    'total',
    'total_users',
    'total_count',
    'recordsTotal',
    'count',
  ]) {
    if (!m.containsKey(key)) continue;
    final v = m[key];
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
  }
  return null;
}
