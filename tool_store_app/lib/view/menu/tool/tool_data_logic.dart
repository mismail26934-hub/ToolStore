import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/menu/tool/tool_order_timeline.dart';

/// Service Support tile status derived from form milestone (UI maps colors/icons).
enum ToolDataServiceSupportMilestoneKind {
  none,
  continueFlow,
  hold,
}

/// Pure tool-data list filter and milestone gate logic (no widgets / Redux).
abstract final class ToolDataLogic {
  ToolDataLogic._();

  static Set<String> milestoneFiltersNorms({
    String? formMilestoneFilter,
    List<String> formMilestoneFilters = const [],
  }) {
    final singleNorm =
        OrderTimelineLogic.normFormMilestone(formMilestoneFilter ?? '');
    return {
      ...formMilestoneFilters.map(OrderTimelineLogic.normFormMilestone),
      if (singleNorm.isNotEmpty) singleNorm,
    }..removeWhere((value) => value.isEmpty);
  }

  static Set<String> excludeMilestoneFilterNorms({
    List<String> excludeFormMilestoneFilters = const [],
  }) {
    return excludeFormMilestoneFilters
        .map(OrderTimelineLogic.normFormMilestone)
        .where((value) => value.isNotEmpty)
        .toSet();
  }

  static bool hasMilestoneFilters(Set<String> milestoneFiltersNorms) =>
      milestoneFiltersNorms.isNotEmpty;

  /// Dashboard list uses a larger page size when client-side milestone filter is active.
  static int formsFetchLimit({required bool hasMilestoneFilters}) =>
      hasMilestoneFilters ? kToolFormDashboardFetchLimit : kToolFormPageSize;

  /// Whether [form] passes the milestone filter configured on [ToolData].
  static bool matchesFormMilestoneFilter({
    required String formMilestone,
    required bool filterBlankFormMilestone,
    required bool excludeFormMilestoneFilter,
    required Set<String> milestoneFiltersNorms,
    required Set<String> excludeMilestoneFilterNorms,
  }) {
    if (filterBlankFormMilestone) {
      final isBlank = formMilestone.trim().isEmpty;
      if (excludeFormMilestoneFilter) return !isBlank;
      return isBlank;
    }
    final currentMilestoneNorm =
        OrderTimelineLogic.normFormMilestone(formMilestone);
    if (excludeMilestoneFilterNorms.isNotEmpty &&
        excludeMilestoneFilterNorms.contains(currentMilestoneNorm)) {
      return false;
    }
    if (!hasMilestoneFilters(milestoneFiltersNorms)) return true;
    final isMatch = milestoneFiltersNorms.contains(currentMilestoneNorm);
    if (excludeFormMilestoneFilter) return !isMatch;
    return isMatch;
  }

  static bool isRejectedApprovalValue(String value) {
    final normalized = value.trim().toUpperCase();
    return normalized == 'REJECTED' ||
        normalized == 'REJECT' ||
        normalized == 'N' ||
        normalized == 'NO';
  }

  static ToolDataServiceSupportMilestoneKind serviceSupportMilestoneKind(
    String formMilestone,
  ) {
    final m = formMilestone.trim().toUpperCase();
    if (m == 'CONTINUE' || m == 'REVIEWED BY SERVICE ADMIN') {
      return ToolDataServiceSupportMilestoneKind.continueFlow;
    }
    if (m == 'HOLD' || m == 'HOLD BY SERVICE ADMIN') {
      return ToolDataServiceSupportMilestoneKind.hold;
    }
    return ToolDataServiceSupportMilestoneKind.none;
  }

  static bool canSuperiorApprovalByMilestoneNorm(String milestoneNorm) =>
      milestoneNorm == 'CHECK BY TOOL STORE';

  static bool canSuperiorApprovalByMilestone(String formMilestone) =>
      canSuperiorApprovalByMilestoneNorm(
        OrderTimelineLogic.normFormMilestone(formMilestone),
      );

  static bool canServiceSupportReviewByMilestoneNorm(String milestoneNorm) =>
      milestoneNorm == 'SUPERIOR APPROVED' ||
      milestoneNorm == 'HOLD BY SERVICE ADMIN';

  static bool canServiceSupportReviewByMilestone(String formMilestone) {
    final n = OrderTimelineLogic.normFormMilestone(formMilestone);
    return canServiceSupportReviewByMilestoneNorm(n);
  }

  static bool canDeptHeadApprovalByMilestoneNorm(String milestoneNorm) =>
      milestoneNorm == 'REVIEWED BY SERVICE ADMIN' ||
      milestoneNorm == 'REJECTED BY SERVICE DEPT HEAD';

  static bool canDeptHeadApprovalByMilestone(String formMilestone) {
    final n = OrderTimelineLogic.normFormMilestone(formMilestone);
    return canDeptHeadApprovalByMilestoneNorm(n);
  }

  static bool canRequestOrderByMilestoneNorm(String milestoneNorm) =>
      milestoneNorm.isEmpty || milestoneNorm == 'DRAFT';

  static bool canRequestOrderByMilestone(String formMilestone) =>
      canRequestOrderByMilestoneNorm(
        OrderTimelineLogic.normFormMilestone(formMilestone),
      );

  /// [allowAnyMilestone] is true for SUPERADMIN.
  static bool canAddToolByMilestoneNorm({
    required String milestoneNorm,
    required bool allowAnyMilestone,
  }) {
    if (allowAnyMilestone) return true;
    return milestoneNorm.isEmpty || milestoneNorm == 'DRAFT';
  }

  static bool canAddToolByMilestone({
    required String formMilestone,
    required bool allowAnyMilestone,
  }) =>
      canAddToolByMilestoneNorm(
        milestoneNorm: OrderTimelineLogic.normFormMilestone(formMilestone),
        allowAnyMilestone: allowAnyMilestone,
      );
}
