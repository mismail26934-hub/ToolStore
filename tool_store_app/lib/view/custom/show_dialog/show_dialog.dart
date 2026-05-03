import 'package:flutter/material.dart';

/// Receives the dialog [BuildContext] so [Navigator.pop] targets the modal route.
typedef ShowDialogButtonHandler = void Function(BuildContext dialogContext);

class ShowDialogBox {
  static void show({
    required BuildContext context,
    required String title,
    required String contentTitle,
    required String textNo,
    required String textYes,
    required ShowDialogButtonHandler onPressedNo,
    required ShowDialogButtonHandler onPressedYes,
    required Color textColorNo,
    required Color textColorYes,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          title,
          style: Theme.of(dialogContext).textTheme.titleMedium,
        ),
        content: Text(
          contentTitle,
          style: Theme.of(dialogContext).textTheme.titleSmall,
        ),
        actions: [
          TextButton(
            onPressed: () => onPressedNo(dialogContext),
            child: Text(textNo, style: TextStyle(color: textColorNo)),
          ),
          TextButton(
            onPressed: () => onPressedYes(dialogContext),
            child: Text(textYes, style: TextStyle(color: textColorYes)),
          ),
        ],
      ),
    );
  }
}
