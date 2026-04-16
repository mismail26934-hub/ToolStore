import 'package:flutter/material.dart';

class MenuItem extends StatefulWidget {
  const MenuItem({
    super.key,
    required this.iconMenu,
    required this.title,
    required this.onTap,
    required this.textColor,
  });

  final String title;
  final void Function()? onTap;
  final Color textColor;
  final IconData iconMenu;

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(widget.iconMenu, color: widget.textColor),
      title: Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
      onTap: widget.onTap,
    );
  }
}
