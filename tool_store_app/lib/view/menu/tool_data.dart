import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
          SliverAppBar.medium(
            centerTitle: true,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shadowColor: Colors.white,
            surfaceTintColor: Colors.white,
            leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
            title: Text(
              '',
              style: GoogleFonts.robotoFlex().copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              stretchModes: [StretchMode.fadeTitle],
              title: Text(
                'Large App Bar',
                style: GoogleFonts.robotoFlex().copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  _addItem();
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
          SliverList.builder(
            itemCount: _itemCount,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(title: Text('Item $index'));
            },
          ),
        ],
      ),
    );
  }
}
