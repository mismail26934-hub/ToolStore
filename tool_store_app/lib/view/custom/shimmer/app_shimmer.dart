import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tool_store_app/theme/app_theme.dart';

/// Shimmer palette aligned with [ToolStoreTheme].
class AppShimmerColors {
  const AppShimmerColors({required this.base, required this.highlight});

  final Color base;
  final Color highlight;

  factory AppShimmerColors.of(BuildContext context) {
    if (context.isDarkMode) {
      return const AppShimmerColors(
        base: Color(0xFF2D3344),
        highlight: Color(0xFF3D4558),
      );
    }
    return AppShimmerColors(
      base: Colors.grey.shade300,
      highlight: Colors.grey.shade100,
    );
  }
}

/// Solid fill used inside skeleton bones (shimmer animates over this).
Color shimmerBoneColor(BuildContext context) =>
    context.isDarkMode ? const Color(0xFF252836) : const Color(0xFFE5E7EB);

/// Wraps [child] skeleton layout with shimmer animation.
class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppShimmerColors.of(context);
    return Shimmer.fromColors(
      baseColor: colors.base,
      highlightColor: colors.highlight,
      child: child,
    );
  }
}

/// [SliverList] of shimmer-wrapped skeleton items.
class ShimmerListSliver extends StatelessWidget {
  const ShimmerListSliver({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => AppShimmer(child: itemBuilder(context, index)),
        childCount: itemCount,
      ),
    );
  }
}

/// Centered full-area shimmer (access check, form preload).
class ShimmerCentered extends StatelessWidget {
  const ShimmerCentered({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppShimmer(child: child),
      ),
    );
  }
}
