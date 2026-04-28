import 'package:flutter/material.dart';
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
    final isMobile = MediaQuery.sizeOf(context).width < mobileWidth;
    final toolbarHeight =
        Theme.of(context).appBarTheme.toolbarHeight ?? kToolbarHeight;
    final collapsedHeight = toolbarHeight < 72 ? 72.0 : toolbarHeight;
    final expandedHeight = (isMobile ? 120.0 : 108.0) < collapsedHeight
        ? collapsedHeight + 16
        : (isMobile ? 120.0 : 108.0);

    return SliverAppBar(
      toolbarHeight: toolbarHeight,
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      centerTitle: false,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: clrWhite,
      foregroundColor: widget.textColor,
      shadowColor: Colors.black12,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 72,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16, top: 5, bottom: 5),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: clrOrange.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: clrOrange.withOpacity(0.18)),
          ),
          child: IconButton(
            onPressed: widget.onPressLeading,
            icon: widget.iconLeading,
            color: clrOrange,
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: clrOrange,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: clrOrange.withOpacity(0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: IconButton(
              onPressed: widget.onPressTailing,
              icon: widget.iconTailing,
              color: clrWhite,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsetsDirectional.only(
          start: 24,
          end: 24,
          bottom: 8,
        ),
        stretchModes: const [StretchMode.fadeTitle, StretchMode.blurBackground],
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                clrOrange.withOpacity(0.14),
                clrOrange.withOpacity(0.05),
                clrOrange.withOpacity(0.14),
              ],
            ),
          ),
          // child: SafeArea(
          //   bottom: false,
          //   child: Padding(
          //     padding: EdgeInsets.fromLTRB(24, isMobile ? 74 : 68, 24, 16),
          //     child: Align(
          //       alignment: Alignment.topLeft,
          //       child: Container(
          //         padding: const EdgeInsets.symmetric(
          //           horizontal: 12,
          //           vertical: 6,
          //         ),
          //         decoration: BoxDecoration(
          //           color: Colors.white.withOpacity(0.82),
          //           borderRadius: BorderRadius.circular(999),
          //           border: Border.all(color: clrOrange.withOpacity(0.16)),
          //         ),
          //         child: Center(
          //           child: Text(
          //             'Data Tool',
          //             style: Theme.of(context).textTheme.labelMedium?.copyWith(
          //               color: clrOrange,
          //               fontWeight: FontWeight.w700,
          //               letterSpacing: 0.2,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ),
        title: Center(
          child: Text(
            widget.title.trim().isEmpty ? titleApp : widget.title.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: clrOrange,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.grey.shade200,
        ),
      ),
    );
  }
}
