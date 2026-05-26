import 'package:flutter/material.dart';

/// Pinned sliver header for list search bars (user list, tool list).
class PinnedSearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  PinnedSearchHeaderDelegate({
    required this.child,
    required this.backgroundColor,
  });

  final Widget child;
  final Color backgroundColor;

  @override
  double get minExtent => 68;

  @override
  double get maxExtent => 68;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant PinnedSearchHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
