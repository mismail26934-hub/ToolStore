import 'package:flutter/material.dart';

class SliverLists extends StatefulWidget {
  const SliverLists({
    super.key,
    required this.itemCount,
    required this.onPressTailing,
    required this.onPressLeading,
    required this.textColor,
  });

  final int itemCount;
  final void Function()? onPressTailing, onPressLeading;
  final Color textColor;

  @override
  State<SliverLists> createState() => _SliverListsState();
}

class _SliverListsState extends State<SliverLists> {
  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: widget.itemCount,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(title: Text('Items : $index'));
      },
    );
  }
}
