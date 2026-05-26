import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/l10n/app_strings.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/var/var.dart';

/// Redux [StoreConnector] equality for order timeline rebuilds.
class OrderTimelineViewModel {
  const OrderTimelineViewModel({
    required this.orangeCompleted,
    this.redStepIndex,
    this.partialStepIndex,
    this.partialProgress,
    this.partialCountLabel,
  });

  /// Number of leading steps (0–7) shown as completed (orange) when [redStepIndex] is null.
  final int orangeCompleted;

  /// When set, this step is shown in red (rejection / hold) instead of orange.
  final int? redStepIndex;

  /// Step index (0–6) shown as partially complete (e.g. WH / Tool partial received).
  final int? partialStepIndex;

  /// Fill ratio 0.0–1.0 for [partialStepIndex] (lines received / total lines).
  final double? partialProgress;

  /// Optional label e.g. "2/5" for partial step subtitle.
  final String? partialCountLabel;

  @override
  bool operator ==(Object other) =>
      other is OrderTimelineViewModel &&
      other.orangeCompleted == orangeCompleted &&
      other.redStepIndex == redStepIndex &&
      other.partialStepIndex == partialStepIndex &&
      other.partialProgress == partialProgress &&
      other.partialCountLabel == partialCountLabel;

  @override
  int get hashCode => Object.hash(
    orangeCompleted,
    redStepIndex,
    partialStepIndex,
    partialProgress,
    partialCountLabel,
  );
}

/// Pure logic for order workflow timeline (milestone → step counts / partial receive).
abstract final class OrderTimelineLogic {
  OrderTimelineLogic._();

  static const int stepCount = 7;

  static const List<String> nextMilestoneLabels = [
    '1. CHECK BY TOOL STORE',
    '2. SUPERIOR APPROVED',
    '3. REVIEWED BY SERVICE ADMIN',
    '4. APPROVED BY SERVICE DEPT HEAD',
    '5. PROCESSING ORDER',
    '6. RECEIVED BY WH/GA',
    '7. RECEIVED TOOL STORE',
  ];

  static bool isApprovedValue(String value) {
    final normalized = value.trim().toUpperCase();
    return normalized == 'APPROVED' ||
        normalized == 'APPROVE' ||
        normalized == 'Y' ||
        normalized == 'YES';
  }

  /// Milestone text normalized for comparisons (case, dots, runs of spaces).
  static String normFormMilestone(String raw) {
    return raw
        .trim()
        .toUpperCase()
        .replaceAll('.', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Highest completed step count (0–7) from milestone string alone.
  static int filledStepsFromMilestoneNorm(String n) {
    if (n.isEmpty || n == 'DRAFT') return 0;
    if (n == 'RECEIVED TOOL STORE' || n == 'RECEIVED BY TOOL STORE') {
      return 7;
    }
    if (n == 'PARTIAL RECEIVED TOOL STORE' ||
        n == 'PARTIAL RECEIVED BY TOOL STORE') {
      return 6;
    }
    if (n == 'RECEIVED BY WH/GA') {
      return 6;
    }
    if (n == 'PARTIAL RECEIVED BY WH/GA') {
      return 5;
    }
    if (n == 'ORDER PROCESSED' || n == 'PROCESSING ORDER') return 5;
    if (n == 'APPROVED BY SERVICE DEPT HEAD') return 4;
    if (n == 'REVIEWED BY SERVICE ADMIN' || n == 'CONTINUE') return 3;
    if (n == 'SUPERIOR APPROVED') return 2;
    if (n == 'CHECK BY TOOL STORE') return 1;
    return 0;
  }

  /// Timeline segment fill and per-step styling for the order workflow.
  static OrderTimelineViewModel compute(
    Store<AppState> store,
    PostList forms,
  ) {
    if (forms.idForm.trim().isEmpty) {
      return const OrderTimelineViewModel(orangeCompleted: 0);
    }

    final mUpper = forms.formMilestone.trim().toUpperCase();
    final n = normFormMilestone(forms.formMilestone);

    if (mUpper == 'REJECTED BY SUPERIOR' || n == 'REJECTED BY SUPERIOR') {
      return const OrderTimelineViewModel(orangeCompleted: 1, redStepIndex: 1);
    }
    if (n == 'REJECTED BY SERVICE DEPT HEAD') {
      return const OrderTimelineViewModel(orangeCompleted: 3, redStepIndex: 3);
    }
    if (mUpper == 'HOLD BY SERVICE ADMIN' || n == 'HOLD BY SERVICE ADMIN') {
      return const OrderTimelineViewModel(orangeCompleted: 2, redStepIndex: 2);
    }

    var filled = filledStepsFromMilestoneNorm(n);

    if (isApprovedValue(forms.formSuperiorAprd)) {
      filled = max(filled, 2);
    }
    if (forms.formSadminComment.trim().isNotEmpty) {
      filled = max(filled, 3);
    }
    if (isApprovedValue(forms.formSheadAprd)) {
      filled = max(filled, 4);
    }

    final tools = store.state.formsDetailState.formsDetail
        .where((t) => t.idForm.trim() == forms.idForm.trim())
        .toList();
    int? partialStepIndex;
    double? partialProgress;
    String? partialCountLabel;

    if (filled >= 5 && tools.isNotEmpty) {
      final detailIds = tools
          .map((e) => e.idFormDetail.trim())
          .where((s) => s.isNotEmpty)
          .toSet();
      if (detailIds.isNotEmpty) {
        final total = detailIds.length;
        final rcvWhFilledIds = store.state.rcvWhState.rcvWhs
            .map((r) => r.idFormDetail.trim())
            .where((s) => s.isNotEmpty)
            .toSet();
        final rcvToolFilledIds = store.state.rcvToolState.rcvTools
            .map((r) => r.idFormDetail.trim())
            .where((s) => s.isNotEmpty)
            .toSet();
        final whCount = detailIds.where(rcvWhFilledIds.contains).length;
        final toolCount = detailIds.where(rcvToolFilledIds.contains).length;
        final allRcvWh = whCount == total;
        final anyRcvWh = whCount > 0;
        final allRcvTool = toolCount == total;
        final anyRcvTool = toolCount > 0;

        if (allRcvTool) {
          filled = max(filled, 7);
        } else if (anyRcvTool) {
          filled = max(filled, 6);
          partialStepIndex = 6;
          partialProgress = toolCount / total;
          partialCountLabel = '$toolCount/$total';
        } else if (allRcvWh) {
          filled = max(filled, 6);
        } else if (anyRcvWh) {
          filled = max(filled, 5);
          partialStepIndex = 5;
          partialProgress = whCount / total;
          partialCountLabel = '$whCount/$total';
        }
      }
    }

    final partialFallback = AppStrings.current.partial;

    switch (n) {
      case 'RECEIVED TOOL STORE':
      case 'RECEIVED BY TOOL STORE':
        filled = stepCount;
        partialStepIndex = null;
        partialProgress = null;
        partialCountLabel = null;
        break;
      case 'PARTIAL RECEIVED TOOL STORE':
      case 'PARTIAL RECEIVED BY TOOL STORE':
        filled = max(filled, 6);
        partialStepIndex = 6;
        partialProgress = 0.5;
        partialCountLabel ??= partialFallback;
        break;
      case 'RECEIVED BY WH/GA':
        filled = max(filled, 6);
        if (partialStepIndex == 6) {
          partialStepIndex = null;
          partialProgress = null;
          partialCountLabel = null;
        }
        break;
      case 'PARTIAL RECEIVED BY WH/GA':
        filled = max(filled, 5);
        partialStepIndex = 5;
        partialProgress = partialProgress ?? 0.5;
        partialCountLabel ??= partialFallback;
        break;
      default:
        break;
    }

    return OrderTimelineViewModel(
      orangeCompleted: filled.clamp(0, stepCount),
      partialStepIndex: partialStepIndex,
      partialProgress: partialProgress?.clamp(0.0, 1.0),
      partialCountLabel: partialCountLabel,
    );
  }

  /// Milestone string for the upcoming workflow step (matches timeline step cards).
  static String nextMilestoneLabel(OrderTimelineViewModel vm) {
    if (vm.redStepIndex != null) {
      final i = vm.redStepIndex!.clamp(0, stepCount - 1);
      return nextMilestoneLabels[i];
    }
    final nextIdx = vm.orangeCompleted.clamp(0, stepCount);
    if (nextIdx >= stepCount) {
      return AppStrings.current.completedStatus;
    }
    return nextMilestoneLabels[nextIdx];
  }

  static bool timelineStepIsPartial(OrderTimelineViewModel vm, int stepIndex) {
    if (vm.redStepIndex != null) return false;
    final p = vm.partialProgress;
    return vm.partialStepIndex == stepIndex && p != null && p > 0 && p < 1;
  }

  static double timelinePartialProgress(
    OrderTimelineViewModel vm,
    int stepIndex,
  ) {
    if (!timelineStepIsPartial(vm, stepIndex)) return 0;
    return vm.partialProgress!.clamp(0.0, 1.0);
  }
}

/// Visual 7-step order status timeline (desktop zig-zag / mobile compact).
class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({
    super.key,
    required this.viewModel,
    this.wrapInPanel = true,
  });

  final OrderTimelineViewModel viewModel;
  final bool wrapInPanel;

  static const double _timelineAboveBand = 80;
  static const double _timelineBelowBand = 80;
  static const double _timelineNodeDiameter = 28;
  static const double _timelineVConnectorHeight = 8;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    final s = AppStrings.current;
    final steps = s.workflowSteps;

    final panelBg = context.isDarkMode
        ? Colors.black
        : clrOrange.withValues(alpha: 0.08);
    final activeColor = clrOrange;
    final errorColor = Colors.red.shade700;
    final inactiveCardBg = context.mutedSurface;
    final inactiveTitle = context.inactiveTitle;
    final connectorMuted = context.connectorMuted;
    final isMobile = MediaQuery.sizeOf(context).width < mobileWidth;
    final orangeSteps = vm.orangeCompleted.clamp(0, OrderTimelineLogic.stepCount);
    final trackOrangeThrough = (vm.redStepIndex ?? vm.orangeCompleted).clamp(
      0,
      OrderTimelineLogic.stepCount,
    );
    const trackHeight = 3.0;
    final mobileStepSize = 36.0;
    final mobileNodeSize = _timelineNodeDiameter;
    final aboveBand = isMobile ? 62.0 : _timelineAboveBand + 18;
    final belowBand = isMobile ? 62.0 : _timelineBelowBand + 18;
    final connectorGap = isMobile ? 4.0 : 4.0;
    final panelPadding = wrapInPanel
        ? (isMobile
              ? const EdgeInsets.fromLTRB(6, 6, 6, 6)
              : const EdgeInsets.fromLTRB(8, 8, 8, 8))
        : (isMobile
              ? const EdgeInsets.fromLTRB(6, 2, 6, 6)
              : const EdgeInsets.fromLTRB(8, 2, 8, 8));

    Widget timelineNode(int i) {
      final isRed = vm.redStepIndex == i;
      final isPartial = OrderTimelineLogic.timelineStepIsPartial(vm, i);
      final isOrangeDone = !isRed && !isPartial && i < orangeSteps;
      final accent = isRed ? errorColor : activeColor;
      if (isPartial) {
        final t = OrderTimelineLogic.timelinePartialProgress(vm, i);
        if (isMobile) {
          return _buildMobileTimelineCircle(
            size: mobileNodeSize,
            fill: context.cardSurface,
            borderColor: accent,
            child: Icon(Icons.more_horiz, size: 14, color: accent),
          );
        }
        return _buildPartialFilledCircle(
          diameter: _timelineNodeDiameter,
          progress: t,
          activeColor: accent,
          inactiveFill: context.cardSurface,
          borderColor: accent,
          centerChild: Text(
            '${(t * 100).round()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      }
      return Container(
        width: isMobile ? mobileNodeSize : _timelineNodeDiameter,
        height: isMobile ? mobileNodeSize : _timelineNodeDiameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (isOrangeDone || isRed) ? accent : context.cardSurface,
          border: Border.all(
            color: (isOrangeDone || isRed) ? accent : context.connectorMuted,
            width: 2,
          ),
          boxShadow: (isOrangeDone || isRed)
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: isRed
            ? const Icon(Icons.close, color: Colors.white, size: 15)
            : (isOrangeDone
                  ? const Icon(Icons.check, color: Colors.white, size: 15)
                  : null),
      );
    }

    Widget stepCard(int i) {
      final isRed = vm.redStepIndex == i;
      final isPartial = OrderTimelineLogic.timelineStepIsPartial(vm, i);
      final isOrangeDone = !isRed && !isPartial && i < orangeSteps;
      final title = steps[i].$1;
      final subtitle = steps[i].$2;
      final accent = isRed ? errorColor : activeColor;
      final partialLabel = isPartial && vm.partialCountLabel != null
          ? s.partialWithCount(vm.partialCountLabel!)
          : isPartial
          ? s.partial
          : subtitle;
      if (isMobile) {
        final stepSize = mobileStepSize;
        Widget circle;
        if (isPartial) {
          circle = _buildMobileTimelineCircle(
            size: stepSize,
            fill: inactiveCardBg,
            borderColor: accent,
            child: Text(
              '${i + 1}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          );
        } else {
          circle = _buildMobileTimelineCircle(
            size: stepSize,
            fill: (isOrangeDone || isRed) ? accent : inactiveCardBg,
            borderColor: (isOrangeDone || isRed) ? accent : context.cardBorder,
            child: Text(
              '${i + 1}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: (isOrangeDone || isRed) ? Colors.white : inactiveTitle,
              ),
            ),
          );
        }
        final tooltipMsg = isPartial && vm.partialCountLabel != null
            ? '$title\n$partialLabel (${vm.partialCountLabel})'
            : '$title\n$partialLabel';
        return Tooltip(
          message: tooltipMsg,
          waitDuration: const Duration(milliseconds: 300),
          showDuration: const Duration(seconds: 5),
          preferBelow: i.isEven,
          child: Center(child: circle),
        );
      }
      if (isPartial) {
        final t = OrderTimelineLogic.timelinePartialProgress(vm, i);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: inactiveCardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  height: 1.15,
                  color: inactiveTitle,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                partialLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 8,
                  height: 1.2,
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: t,
                  minHeight: 4,
                  backgroundColor: connectorMuted,
                  color: accent,
                ),
              ),
            ],
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: (isOrangeDone || isRed) ? accent : inactiveCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isOrangeDone || isRed) ? accent : context.cardBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 10,
                height: 1.15,
                color: (isOrangeDone || isRed) ? Colors.white : inactiveTitle,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 8,
                height: 1.2,
                color: (isOrangeDone || isRed)
                    ? Colors.white.withValues(alpha: 0.9)
                    : context.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    Widget verticalConnector(int i) {
      final isPartial = OrderTimelineLogic.timelineStepIsPartial(vm, i);
      if (isPartial) {
        final t = OrderTimelineLogic.timelinePartialProgress(vm, i);
        final h = _timelineVConnectorHeight;
        final activeH = (h * t).clamp(1.0, h);
        return SizedBox(
          width: 2,
          height: h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 2,
                height: activeH,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Container(
                width: 2,
                height: h - activeH,
                decoration: BoxDecoration(
                  color: connectorMuted,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        );
      }
      final lineActive = vm.redStepIndex != null
          ? i <= vm.redStepIndex!
          : i < orangeSteps;
      return Container(
        width: 2,
        height: _timelineVConnectorHeight,
        decoration: BoxDecoration(
          color: lineActive ? activeColor : connectorMuted,
          borderRadius: BorderRadius.circular(1),
        ),
      );
    }

    final nodeBand = isMobile ? mobileNodeSize : _timelineNodeDiameter;
    final trackTop = aboveBand + nodeBand / 2 - trackHeight / 2;
    final stackHeight = aboveBand + nodeBand + belowBand;

    final timelineBody = SizedBox(
      height: stackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: trackTop,
            height: trackHeight,
            child: _HorizontalTrackSegments(
              completed: trackOrangeThrough,
              trackHeight: trackHeight,
              partialVm: vm,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(OrderTimelineLogic.stepCount, (i) {
              final cardAbove = i.isEven;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? 0 : 2,
                    right: i == OrderTimelineLogic.stepCount - 1 ? 0 : 2,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: aboveBand,
                        child: cardAbove
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  stepCard(i),
                                  SizedBox(height: connectorGap),
                                  verticalConnector(i),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      SizedBox(
                        height: isMobile
                            ? mobileNodeSize
                            : _timelineNodeDiameter,
                        child: Center(child: timelineNode(i)),
                      ),
                      SizedBox(
                        height: belowBand,
                        child: !cardAbove
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  verticalConnector(i),
                                  SizedBox(height: connectorGap),
                                  stepCard(i),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );

    if (!wrapInPanel) {
      return Padding(padding: panelPadding, child: timelineBody);
    }

    return Container(
      width: double.infinity,
      padding: panelPadding,
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDarkMode
              ? context.cardBorder
              : clrOrange.withValues(alpha: 0.18),
        ),
      ),
      child: timelineBody,
    );
  }

  static Widget _buildPartialFilledCircle({
    required double diameter,
    required double progress,
    required Color activeColor,
    required Color inactiveFill,
    required Color borderColor,
    Widget? centerChild,
  }) {
    final t = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        children: [
          SizedBox(
            width: diameter,
            height: diameter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: inactiveFill,
                border: Border.all(color: borderColor, width: 2),
              ),
            ),
          ),
          SizedBox(
            width: diameter,
            height: diameter,
            child: ClipOval(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: t,
                child: SizedBox(
                  width: diameter,
                  height: diameter,
                  child: ColoredBox(color: activeColor),
                ),
              ),
            ),
          ),
          SizedBox(
            width: diameter,
            height: diameter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: t >= 1
                      ? activeColor
                      : activeColor.withValues(alpha: 0.85),
                  width: 2,
                ),
              ),
            ),
          ),
          ?centerChild,
        ],
      ),
    );
  }

  static Widget _buildMobileTimelineCircle({
    required double size,
    required Color fill,
    required Color borderColor,
    required Widget child,
    double borderWidth = 2,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _HorizontalTrackSegments extends StatelessWidget {
  const _HorizontalTrackSegments({
    required this.completed,
    required this.trackHeight,
    this.partialVm,
  });

  final int completed;
  final double trackHeight;
  final OrderTimelineViewModel? partialVm;

  @override
  Widget build(BuildContext context) {
    final activeColor = clrOrange;
    final connectorMuted = context.connectorMuted;
    final capR = trackHeight / 2;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(flex: 1, child: SizedBox()),
        for (int k = 0; k < OrderTimelineLogic.stepCount - 1; k++)
          Expanded(
            flex: 2,
            child: Builder(
              builder: (context) {
                final partialStep = partialVm?.partialStepIndex;
                final partialT = partialVm?.partialProgress;
                final isApproachPartial =
                    partialStep != null &&
                    partialT != null &&
                    partialT > 0 &&
                    partialT < 1 &&
                    k == partialStep - 1;
                if (isApproachPartial) {
                  final t = partialT.clamp(0.0, 1.0);
                  final leftFlex = (t * 1000).round().clamp(1, 999);
                  final rightFlex = ((1 - t) * 1000).round().clamp(1, 999);
                  return ClipRRect(
                    borderRadius: BorderRadius.horizontal(
                      left: k == 0 ? Radius.circular(capR) : Radius.zero,
                      right: k == OrderTimelineLogic.stepCount - 2
                          ? Radius.circular(capR)
                          : Radius.zero,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: leftFlex,
                          child: Container(
                            height: trackHeight,
                            color: activeColor,
                          ),
                        ),
                        Expanded(
                          flex: rightFlex,
                          child: Container(
                            height: trackHeight,
                            color: connectorMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Container(
                  height: trackHeight,
                  decoration: BoxDecoration(
                    color: k < completed ? activeColor : connectorMuted,
                    borderRadius: BorderRadius.horizontal(
                      left: k == 0 ? Radius.circular(capR) : Radius.zero,
                      right: k == OrderTimelineLogic.stepCount - 2
                          ? Radius.circular(capR)
                          : Radius.zero,
                    ),
                  ),
                );
              },
            ),
          ),
        const Expanded(flex: 1, child: SizedBox()),
      ],
    );
  }
}
