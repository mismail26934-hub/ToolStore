import 'package:flutter/material.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/custom/shimmer/app_shimmer.dart';

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: shimmerBoneColor(context),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Matches tool list [ExpansionTile] card (~tool_data.dart).
class FormCardSkeleton extends StatelessWidget {
  const FormCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bone = shimmerBoneColor(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: bone,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.cardBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: bone,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: double.infinity, height: 14, borderRadius: 6),
                    const SizedBox(height: 8),
                    ShimmerBox(width: 140, height: 11, borderRadius: 6),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ShimmerBox(width: double.infinity, height: 48, borderRadius: 16),
          const SizedBox(height: 10),
          Row(
            children: [
              ShimmerBox(width: 72, height: 22, borderRadius: 999),
              const SizedBox(width: 8),
              ShimmerBox(width: 88, height: 22, borderRadius: 999),
            ],
          ),
        ],
      ),
    );
  }
}

/// Matches user list card (~user_data.dart).
class UserRowSkeleton extends StatelessWidget {
  const UserRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bone = shimmerBoneColor(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bone,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 40, height: 40, borderRadius: 12),
              const SizedBox(width: 12),
              Expanded(child: ShimmerBox(width: double.infinity, height: 16, borderRadius: 6)),
              ShimmerBox(width: 36, height: 36, borderRadius: 10),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ShimmerBox(width: 100, height: 24, borderRadius: 999),
              const SizedBox(width: 8),
              ShimmerBox(width: 72, height: 24, borderRadius: 999),
            ],
          ),
          const SizedBox(height: 8),
          ShimmerBox(width: 180, height: 12, borderRadius: 6),
        ],
      ),
    );
  }
}

/// Matches dashboard milestone card.
class DashboardCardSkeleton extends StatelessWidget {
  const DashboardCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bone = shimmerBoneColor(context);
    return Container(
      decoration: BoxDecoration(
        color: bone,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.cardBorder.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 48, height: 3, borderRadius: 999),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 40, height: 40, borderRadius: 13),
              const Spacer(),
              ShimmerBox(width: 36, height: 26, borderRadius: 999),
            ],
          ),
          const SizedBox(height: 10),
          ShimmerBox(width: double.infinity, height: 14, borderRadius: 6),
          const SizedBox(height: 6),
          ShimmerBox(width: double.infinity, height: 11, borderRadius: 6),
          const Spacer(),
          ShimmerBox(width: 72, height: 10, borderRadius: 6),
        ],
      ),
    );
  }
}

/// Form page preload (user/tool form).
class FormPageSkeleton extends StatelessWidget {
  const FormPageSkeleton({super.key, this.sectionCount = 2});

  final int sectionCount;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Column(
        children: List.generate(
          sectionCount,
          (_) => const FormSectionSkeleton(),
        ),
      ),
    );
  }
}

class FormSectionSkeleton extends StatelessWidget {
  const FormSectionSkeleton({super.key, this.fieldCount = 4});

  final int fieldCount;

  @override
  Widget build(BuildContext context) {
    final bone = shimmerBoneColor(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bone,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 34, height: 34, borderRadius: 10),
              const SizedBox(width: 10),
              ShimmerBox(width: 140, height: 16, borderRadius: 6),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(
            fieldCount,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: i < fieldCount - 1 ? 10 : 0),
              child: ShimmerBox(width: double.infinity, height: 48, borderRadius: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single form field placeholder.
class FieldSkeleton extends StatelessWidget {
  const FieldSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 100, height: 12, borderRadius: 6),
          const SizedBox(height: 6),
          ShimmerBox(width: double.infinity, height: 48, borderRadius: 14),
        ],
      ),
    );
  }
}

/// PO / SO / Rcv lines below an existing section header.
class DetailLinesSkeleton extends StatelessWidget {
  const DetailLinesSkeleton({super.key, this.lineCount = 2});

  final int lineCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        children: List.generate(
          lineCount,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: i < lineCount - 1 ? 8 : 0),
            child: ShimmerBox(width: double.infinity, height: 56, borderRadius: 14),
          ),
        ),
      ),
    );
  }
}

/// Tool row inside expanded form card.
class ToolItemSkeleton extends StatelessWidget {
  const ToolItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bone = shimmerBoneColor(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bone,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.cardBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 160, height: 14, borderRadius: 6),
          const SizedBox(height: 10),
          ShimmerBox(width: double.infinity, height: 12, borderRadius: 6),
          const SizedBox(height: 8),
          ShimmerBox(width: 200, height: 12, borderRadius: 6),
        ],
      ),
    );
  }
}

/// Splash / access gate loading strip.
class SplashLoadingStripSkeleton extends StatelessWidget {
  const SplashLoadingStripSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShimmerBox(width: 28, height: 28, borderRadius: 14),
        const SizedBox(width: 12),
        Expanded(
          child: ShimmerBox(width: double.infinity, height: 14, borderRadius: 6),
        ),
      ],
    );
  }
}
