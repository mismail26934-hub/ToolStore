import 'package:tool_store_app/controller/api_url/post_list.dart';

/// Display label for superior picker rows.
String superiorPickerTitle(PostList s) {
  if (s.namaSuperior.trim().isNotEmpty) return s.namaSuperior.trim();
  if (s.namaUser.trim().isNotEmpty) return s.namaUser.trim();
  return s.username;
}

/// Display label for user picker rows (tool form fields).
String userPickerTitle(PostList u) {
  final n = u.namaUser.trim();
  if (n.isNotEmpty) return n;
  final un = u.username.trim();
  if (un.isNotEmpty) return un;
  return u.idUsers.trim();
}

List<PostList> dedupeSuperiorRows(List<PostList> list) {
  final seen = <String>{};
  final out = <PostList>[];
  for (final s in list) {
    final id = s.idUsers.trim();
    final key = id.isNotEmpty
        ? id
        : '${s.namaUser.trim()}|${s.namaSuperior.trim()}|${s.username.trim()}';
    if (key.replaceAll('|', '').trim().isEmpty) continue;
    if (seen.contains(key)) continue;
    seen.add(key);
    out.add(s);
  }
  return out;
}

List<PostList> filterSuperiorRows(List<PostList> list, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return list;
  return list.where((s) {
    final namaUser = s.namaUser.toLowerCase();
    final namaSup = s.namaSuperior.toLowerCase();
    final user = s.username.toLowerCase();
    return namaUser.contains(q) || namaSup.contains(q) || user.contains(q);
  }).toList();
}

List<PostList> applySuperiorPickerFieldFilter(
  List<PostList> list,
  String searchField,
  String query,
) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return list;
  switch (searchField) {
    case 'username':
      return list.where((s) => s.username.toLowerCase().contains(q)).toList();
    case 'name':
      return list
          .where(
            (s) =>
                s.namaUser.toLowerCase().contains(q) ||
                s.namaSuperior.toLowerCase().contains(q),
          )
          .toList();
    default:
      return filterSuperiorRows(list, query);
  }
}

List<PostList> sortSuperiorsForPicker(List<PostList> list) {
  final sorted = List<PostList>.from(list)
    ..sort(
      (a, b) => superiorPickerTitle(
        a,
      ).toLowerCase().compareTo(superiorPickerTitle(b).toLowerCase()),
    );
  return sorted;
}

List<PostList> mergePickerSuperiors(
  List<PostList> existing,
  List<PostList> incoming,
) {
  if (incoming.isEmpty) return existing;
  final keys = <String>{};
  for (final s in existing) {
    final id = s.idUsers.trim();
    keys.add(
      id.isNotEmpty
          ? id
          : '${s.namaUser.trim()}|${s.namaSuperior.trim()}|${s.username.trim()}',
    );
  }
  final merged = List<PostList>.from(existing);
  for (final s in incoming) {
    final id = s.idUsers.trim();
    final key = id.isNotEmpty
        ? id
        : '${s.namaUser.trim()}|${s.namaSuperior.trim()}|${s.username.trim()}';
    if (key.replaceAll('|', '').trim().isEmpty || keys.contains(key)) continue;
    merged.add(s);
    keys.add(key);
  }
  return merged;
}

List<PostList> dedupeUsersById(List<PostList> list) {
  final seen = <String>{};
  final out = <PostList>[];
  for (final u in list) {
    final id = u.idUsers.trim();
    if (id.isEmpty) continue;
    if (seen.contains(id)) continue;
    seen.add(id);
    out.add(u);
  }
  return out;
}

List<PostList> filterUserPickerRows(List<PostList> list, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return list;
  return list.where((u) {
    return u.namaUser.toLowerCase().contains(q) ||
        u.username.toLowerCase().contains(q) ||
        u.idUsers.toLowerCase().contains(q);
  }).toList();
}

List<PostList> applyUserPickerFieldFilter(
  List<PostList> list,
  String searchField,
  String query,
) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return list;
  switch (searchField) {
    case 'username':
      return list.where((u) => u.username.toLowerCase().contains(q)).toList();
    case 'name':
      return list.where((u) => u.namaUser.toLowerCase().contains(q)).toList();
    case 'phone':
      return list.where((u) => u.noTelp.toLowerCase().contains(q)).toList();
    case 'level':
      return list.where((u) => u.level.toLowerCase().contains(q)).toList();
    case 'status':
      return list.where((u) => u.status.toLowerCase().contains(q)).toList();
    default:
      return filterUserPickerRows(list, query);
  }
}

List<PostList> sortUsersForPicker(List<PostList> list) {
  final sorted = List<PostList>.from(list)
    ..sort(
      (a, b) => userPickerTitle(
        a,
      ).toLowerCase().compareTo(userPickerTitle(b).toLowerCase()),
    );
  return sorted;
}

List<PostList> mergePickerUsers(
  List<PostList> existing,
  List<PostList> incoming,
) {
  if (incoming.isEmpty) return existing;
  final ids = existing.map((u) => u.idUsers.trim()).toSet();
  final merged = List<PostList>.from(existing);
  for (final user in incoming) {
    final id = user.idUsers.trim();
    if (id.isEmpty || ids.contains(id)) continue;
    merged.add(user);
    ids.add(id);
  }
  return merged;
}

List<PostList> filterUsersByLevel(List<PostList> list, String level) {
  final target = level.trim().toUpperCase();
  if (target.isEmpty) return list;
  return list
      .where((u) => u.level.trim().toUpperCase() == target)
      .toList();
}

String? superiorPickerSubtitle(PostList s) {
  final title = superiorPickerTitle(s);
  final sub = s.namaUser.trim();
  if (sub.isNotEmpty && sub != title) return sub;
  return null;
}

String? superiorPickerUsernameLine(PostList s) {
  if (s.username.isEmpty) return null;
  return '@${s.username}';
}

bool userPickerShowUsernameLine(PostList u) {
  final title = userPickerTitle(u);
  final un = u.username.trim();
  return un.isNotEmpty && un.toLowerCase() != title.toLowerCase();
}

String userPickerUsernameLine(PostList u) => '@${u.username.trim()}';
