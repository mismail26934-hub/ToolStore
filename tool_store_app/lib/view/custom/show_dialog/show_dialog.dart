import 'package:flutter/material.dart';
import 'package:tool_store_app/view/var/var.dart';

class ShowDialogBox {
  static void show({
    required BuildContext context,
    required String title,
    required String contentTitle,
    required String textNo,
    required String textYes,
    required void Function()? onPressedNo,
    required void Function()? onPressedYes,
    required Color textColorNo,
    required Color textColorYes,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false, // User harus pilih salah satu tombol
      builder: (context) => AlertDialog(
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        content: Text(
          contentTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        actions: [
          TextButton(
            onPressed: onPressedNo,
            child: Text(textNo, style: TextStyle(color: textColorNo)),
          ),
          TextButton(
            onPressed: onPressedYes,
            child: Text(textYes, style: TextStyle(color: textColorYes)),
          ),
        ],
      ),
    );
  }
}
