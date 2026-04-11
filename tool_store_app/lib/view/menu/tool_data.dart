import 'package:flutter/material.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_appbars.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_lists.dart';

class ToolData extends StatefulWidget {
  const ToolData({super.key});

  @override
  State<ToolData> createState() => _ToolDataState();
}

class _ToolDataState extends State<ToolData> {
  int _itemCount = 5;

  void _addItem() {
    setState(() {
      _itemCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[300],
      body: CustomScrollView(
        slivers: [
          SliverAppbars(
            title: 'Large App Bar',
            onPressTailing: () {
              _addItem();
            },
            onPressLeading: () {
              _addItem();
            },
            textColor: Colors.black,
          ),
          SliverLists(
            itemCount: _itemCount,
            onPressTailing: () {},
            onPressLeading: () {},
            textColor: Colors.black,
          ),
        ],
      ),
    );
  }
}
