import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tool_store_app/view/var/var.dart';

class SliverAppbars extends StatefulWidget {
  const SliverAppbars({
    super.key,
    required this.title,
    required this.onPressTailing,
    required this.iconTailing,
    required this.onPressLeading,
    required this.iconLeading,
    required this.textColor,
  });

  final String title;
  final void Function()? onPressTailing, onPressLeading;
  final Color textColor;
  final Icon iconTailing, iconLeading;

  @override
  State<SliverAppbars> createState() => _SliverAppbarsState();
}

class _SliverAppbarsState extends State<SliverAppbars> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar.medium(
      expandedHeight: (MediaQuery.sizeOf(context).width < mobileWidth)
          ? 80
          : 10,
      centerTitle: true,
      pinned: true,
      stretch: true,
      backgroundColor: clrOrange,
      foregroundColor: clrBlack,
      shadowColor: clrWhite,
      surfaceTintColor: clrWhite,
      title: Text(
        '',
        style: GoogleFonts.robotoFlex().copyWith(fontWeight: FontWeight.bold),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        stretchModes: [StretchMode.fadeTitle],
        title: Text(titleApp, style: Theme.of(context).textTheme.titleLarge),
      ),
      actions: [
        IconButton(onPressed: widget.onPressTailing, icon: widget.iconTailing),
      ],
    );
  }
}
