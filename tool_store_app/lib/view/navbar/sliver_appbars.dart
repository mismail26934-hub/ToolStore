import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SliverAppbars extends StatefulWidget {
  const SliverAppbars({
    super.key,
    required this.title,
    this.onPressed,
    required this.textColor,
  });

  final String title;
  final void Function()? onPressed;
  final Color textColor;

  @override
  State<SliverAppbars> createState() => _SliverAppbarsState();
}

class _SliverAppbarsState extends State<SliverAppbars> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar.medium(
      expandedHeight: 200,
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
      actions: [IconButton(onPressed: widget.onPressed, icon: Icon(Icons.add))],
    );
  }
}
