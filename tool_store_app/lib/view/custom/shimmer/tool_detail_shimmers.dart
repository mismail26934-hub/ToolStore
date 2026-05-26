import 'package:flutter/material.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/custom/shimmer/app_shimmer.dart';
import 'package:tool_store_app/view/custom/shimmer/detail_section_vm.dart';
import 'package:tool_store_app/view/custom/shimmer/skeletons.dart';

/// Shimmer placeholder while PO / SO / Rcv detail rows load.
class DetailSectionLoadingShimmer extends StatelessWidget {
  const DetailSectionLoadingShimmer({super.key, this.lineCount = 2});

  final int lineCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(child: DetailLinesSkeleton(lineCount: lineCount));
  }
}

/// Legacy empty row under section headers (blank line, preserves layout).
class DetailSectionEmptyPlaceholder extends StatelessWidget {
  const DetailSectionEmptyPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: context.textSecondary),
      ),
    );
  }
}

/// Loading, empty, or list content for a [DetailSectionVm] (PO, SO, Rcv, etc.).
class DetailSectionBody extends StatelessWidget {
  const DetailSectionBody({
    super.key,
    required this.viewModel,
    required this.itemBuilder,
    this.loadingLineCount = 2,
    this.emptyPlaceholder,
  });

  final DetailSectionVm viewModel;
  final Widget Function(BuildContext context, PostList item) itemBuilder;
  final int loadingLineCount;
  final Widget? emptyPlaceholder;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    if (vm.isLoading && vm.items.isEmpty) {
      return DetailSectionLoadingShimmer(lineCount: loadingLineCount);
    }
    if (vm.items.isEmpty) {
      return emptyPlaceholder ?? const DetailSectionEmptyPlaceholder();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in vm.items) itemBuilder(context, item),
      ],
    );
  }
}

/// Shimmer for tool rows inside an expanded form card.
class ToolListLoadingShimmer extends StatelessWidget {
  const ToolListLoadingShimmer({super.key, this.skeletonCount = 2});

  final int skeletonCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        children: List.generate(
          skeletonCount,
          (_) => const ToolItemSkeleton(),
        ),
      ),
    );
  }
}

/// Empty tool list inside an expanded form card.
class ToolListEmptyPlaceholder extends StatelessWidget {
  const ToolListEmptyPlaceholder({
    super.key,
    this.message = 'No tool details for this request yet.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.mutedSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.cardBorder),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 34,
            color: context.iconMuted,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

typedef ToolListItemBuilder = Widget Function(
  BuildContext context,
  int index,
  PostList item,
);

/// Loading, empty, or [ListView] for tool detail rows on a form card.
class ToolListSectionBody extends StatelessWidget {
  const ToolListSectionBody({
    super.key,
    required this.viewModel,
    required this.itemBuilder,
    this.skeletonCount = 2,
    this.emptyPlaceholder,
  });

  final DetailSectionVm viewModel;
  final ToolListItemBuilder itemBuilder;
  final int skeletonCount;
  final Widget? emptyPlaceholder;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    if (vm.isLoading && vm.items.isEmpty) {
      return ToolListLoadingShimmer(skeletonCount: skeletonCount);
    }
    if (vm.items.isEmpty) {
      return emptyPlaceholder ?? const ToolListEmptyPlaceholder();
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vm.items.length,
      itemBuilder: (context, index) =>
          itemBuilder(context, index, vm.items[index]),
    );
  }
}

/// Initial tool form list shimmer ([SliverList] of [FormCardSkeleton]).
class FormCardListLoadingSliver extends StatelessWidget {
  const FormCardListLoadingSliver({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ShimmerListSliver(
      itemCount: itemCount,
      itemBuilder: (context, index) => const FormCardSkeleton(),
    );
  }
}
