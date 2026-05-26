import 'package:tool_store_app/controller/api_url/post_list.dart';

List<PostList> mergeFormsPreview(
  List<PostList> existing,
  List<PostList> incoming,
) {
  if (incoming.isEmpty) return existing;
  final ids = existing.map((f) => f.idForm.trim()).toSet();
  final merged = List<PostList>.from(existing);
  for (final form in incoming) {
    final id = form.idForm.trim();
    if (id.isEmpty || !ids.contains(id)) {
      merged.add(form);
      if (id.isNotEmpty) ids.add(id);
    }
  }
  return merged;
}

List<PostList> mergeUsersPreview(
  List<PostList> existing,
  List<PostList> incoming,
) {
  if (incoming.isEmpty) return existing;
  final ids = existing.map((u) => u.idUsers.trim()).toSet();
  final merged = List<PostList>.from(existing);
  for (final user in incoming) {
    final id = user.idUsers.trim();
    if (id.isEmpty || !ids.contains(id)) {
      merged.add(user);
      if (id.isNotEmpty) ids.add(id);
    }
  }
  return merged;
}
