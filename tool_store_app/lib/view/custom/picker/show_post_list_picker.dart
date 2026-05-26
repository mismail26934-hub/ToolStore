import 'package:flutter/material.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/view/custom/picker/post_list_picker_dialog.dart';
import 'package:tool_store_app/view/custom/picker/post_list_picker_presets.dart';

/// Opens superior picker (user form).
Future<void> showSuperiorPickerDialog({
  required BuildContext context,
  List<PostList> initialSuperiors = const [],
  required ValueChanged<PostList> onSelected,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (ctx) => PostListPickerDialog(
      config: PostListPickerPresets.superior(ctx),
      initialItems: initialSuperiors,
      onSelected: (item) {
        Navigator.pop(ctx);
        onSelected(item);
      },
    ),
  );
}

/// Opens user-by-level picker (tool form).
Future<void> showToolUserPickerDialog({
  required BuildContext context,
  required String userLevel,
  required List<PostList> initialUsers,
  required String dialogTitle,
  required ValueChanged<PostList> onSelected,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (ctx) => PostListPickerDialog(
      config: PostListPickerPresets.toolUser(
        ctx,
        title: dialogTitle,
        levelFilter: userLevel,
      ),
      initialItems: initialUsers,
      onSelected: (item) {
        Navigator.pop(ctx);
        onSelected(item);
      },
    ),
  );
}
