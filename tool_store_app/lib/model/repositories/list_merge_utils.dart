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

/// Replaces tool rows for [idForm] with [incoming] (server + client scoped).
List<PostList> mergeToolsForForm({
  required List<PostList> existing,
  required List<PostList> incoming,
  required String idForm,
}) {
  final id = idForm.trim();
  if (id.isEmpty) return incoming;
  final kept = existing.where((t) => t.idForm.trim() != id).toList();
  final scoped = incoming.where((t) => t.idForm.trim() == id).toList();
  return [...kept, ...scoped];
}

Set<String> toolDetailIdsForForm(List<PostList> tools, String idForm) {
  final id = idForm.trim();
  if (id.isEmpty) return const {};
  return tools
      .where((t) => t.idForm.trim() == id)
      .map((t) => t.idFormDetail.trim())
      .where((s) => s.isNotEmpty)
      .toSet();
}

/// Replaces child rows (PO/SO/Rcv) linked to [toolDetailIds].
List<PostList> mergeChildRowsForToolDetails({
  required List<PostList> existing,
  required List<PostList> incoming,
  required Set<String> toolDetailIds,
  required String Function(PostList) childDetailId,
}) {
  if (toolDetailIds.isEmpty) return existing;
  final kept = existing
      .where((row) => !toolDetailIds.contains(childDetailId(row).trim()))
      .toList();
  final scoped = incoming
      .where((row) => toolDetailIds.contains(childDetailId(row).trim()))
      .toList();
  return [...kept, ...scoped];
}
