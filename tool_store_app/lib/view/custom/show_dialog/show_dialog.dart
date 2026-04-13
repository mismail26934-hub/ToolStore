import 'package:flutter/material.dart';

class ShowDialogBox {
  static void show({
    required BuildContext context,
    required String title,
    required String contentTitle,
    required String textNo,
    required String textYes,
    required void Function()? onPressedNo,
    required void Function()? onPressedYes,
    Color textColorNo = Colors.grey,
    Color textColorYes = Colors.red,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false, // User harus pilih salah satu tombol
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(contentTitle),
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
