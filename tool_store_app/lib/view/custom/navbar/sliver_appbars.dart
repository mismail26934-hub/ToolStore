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
      centerTitle: true,
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
      title: Text(
        widget.title.trim().isEmpty ? titleApp : widget.title.trim(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: clrOrange,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.fadeTitle, StretchMode.blurBackground],
        background: LayoutBuilder(
          builder: (context, constraints) {
            final range = (expandedHeight - collapsedHeight).abs();
            final collapseProgress =
                ((constraints.biggest.height - collapsedHeight) /
                        (range == 0 ? 1 : range))
                    .clamp(0.0, 1.0);
            final chipOpacity = Curves.easeOut.transform(collapseProgress);
            final chipSlideOffset = (1 - collapseProgress) * 16;

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    clrOrange.withOpacity(0.08 + (0.06 * collapseProgress)),
                    clrOrange.withOpacity(0.03 + (0.02 * collapseProgress)),
                    clrOrange.withOpacity(0.08 + (0.06 * collapseProgress)),
                  ],
                ),
              ),
            );
          },
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
