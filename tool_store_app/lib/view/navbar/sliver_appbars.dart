import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tool_store_app/view/var/var.dart';

class SliverAppbars extends StatefulWidget {
  const SliverAppbars({
    super.key,
    required this.title,
    required this.onPressTailing,
    required this.onPressLeading,
    required this.textColor,
  });

  final String title;
  final void Function()? onPressTailing, onPressLeading;
  final Color textColor;

  @override
  State<SliverAppbars> createState() => _SliverAppbarsState();
}

class _SliverAppbarsState extends State<SliverAppbars> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar.medium(
      expandedHeight: (MediaQuery.sizeOf(context).width < mobileWidth)
          ? 100
          : 10,
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
        style: GoogleFonts.robotoFlex().copyWith(fontWeight: FontWeight.bold),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        stretchModes: [StretchMode.fadeTitle],
        title: Text(
          'Large App Bar',
          style: GoogleFonts.robotoFlex().copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        IconButton(onPressed: widget.onPressTailing, icon: Icon(Icons.add)),
      ],
    );
  }
}
