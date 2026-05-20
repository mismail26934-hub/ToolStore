import 'package:flutter/material.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/var/var.dart';

class SliverAppbars extends StatefulWidget {
  const SliverAppbars({
    super.key,
    required this.title,
    required this.onPressTailing,
    required this.iconTailing,
    required this.onPressLeading,
    required this.iconLeading,
  });

  final String title;
  final void Function()? onPressTailing, onPressLeading;
  final Icon iconTailing, iconLeading;

  @override
  State<SliverAppbars> createState() => _SliverAppbarsState();
}

class _SliverAppbarsState extends State<SliverAppbars> {
  static const _buttonRadius = 16.0;

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
      backgroundColor: clrOrange,
      foregroundColor: Colors.white,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: AppTheme.dashboardHeaderBottomRadius,
      ),
      leadingWidth: 72,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16, top: 5, bottom: 5),
        child: Material(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(_buttonRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(_buttonRadius),
            onTap: widget.onPressLeading,
            child: IconButton(
              onPressed: widget.onPressLeading,
              icon: widget.iconLeading,
              color: Colors.white,
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
          child: Material(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(_buttonRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(_buttonRadius),
              onTap: widget.onPressTailing,
              child: IconButton(
                onPressed: widget.onPressTailing,
                icon: widget.iconTailing,
                color: Colors.white,
              ),
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
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.fadeTitle, StretchMode.blurBackground],
        background: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppTheme.dashboardHeaderGradient,
            borderRadius: AppTheme.dashboardHeaderBottomRadius,
          ),
        ),
      ),
    );
  }
}
