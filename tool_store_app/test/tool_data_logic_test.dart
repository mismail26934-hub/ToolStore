import 'package:flutter_test/flutter_test.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/menu/tool/tool_data_logic.dart';

void main() {
  group('ToolDataLogic.milestoneFiltersNorms', () {
    test('merges list filter and single filter', () {
      final norms = ToolDataLogic.milestoneFiltersNorms(
        formMilestoneFilter: 'Superior Approved',
        formMilestoneFilters: const ['CHECK BY TOOL STORE', ''],
      );
      expect(norms, {
        'CHECK BY TOOL STORE',
        'SUPERIOR APPROVED',
      });
    });
  });

  group('ToolDataLogic.matchesFormMilestoneFilter', () {
    test('blank filter includes only empty milestone', () {
      expect(
        ToolDataLogic.matchesFormMilestoneFilter(
          formMilestone: '',
          filterBlankFormMilestone: true,
          excludeFormMilestoneFilter: false,
          milestoneFiltersNorms: const {},
          excludeMilestoneFilterNorms: const {},
        ),
        isTrue,
      );
      expect(
        ToolDataLogic.matchesFormMilestoneFilter(
          formMilestone: 'DRAFT',
          filterBlankFormMilestone: true,
          excludeFormMilestoneFilter: false,
          milestoneFiltersNorms: const {},
          excludeMilestoneFilterNorms: const {},
        ),
        isFalse,
      );
    });

    test('include mode matches normalized milestone set', () {
      final norms = ToolDataLogic.milestoneFiltersNorms(
        formMilestoneFilters: const ['Superior Approved'],
      );
      expect(
        ToolDataLogic.matchesFormMilestoneFilter(
          formMilestone: 'superior approved',
          filterBlankFormMilestone: false,
          excludeFormMilestoneFilter: false,
          milestoneFiltersNorms: norms,
          excludeMilestoneFilterNorms: const {},
        ),
        isTrue,
      );
      expect(
        ToolDataLogic.matchesFormMilestoneFilter(
          formMilestone: 'CHECK BY TOOL STORE',
          filterBlankFormMilestone: false,
          excludeFormMilestoneFilter: false,
          milestoneFiltersNorms: norms,
          excludeMilestoneFilterNorms: const {},
        ),
        isFalse,
      );
    });

    test('exclude mode inverts include match', () {
      final norms = ToolDataLogic.milestoneFiltersNorms(
        formMilestoneFilters: const ['DRAFT'],
      );
      expect(
        ToolDataLogic.matchesFormMilestoneFilter(
          formMilestone: 'DRAFT',
          filterBlankFormMilestone: false,
          excludeFormMilestoneFilter: true,
          milestoneFiltersNorms: norms,
          excludeMilestoneFilterNorms: const {},
        ),
        isFalse,
      );
      expect(
        ToolDataLogic.matchesFormMilestoneFilter(
          formMilestone: 'SUPERIOR APPROVED',
          filterBlankFormMilestone: false,
          excludeFormMilestoneFilter: true,
          milestoneFiltersNorms: norms,
          excludeMilestoneFilterNorms: const {},
        ),
        isTrue,
      );
    });

    test('exclude list removes milestones before include check', () {
      expect(
        ToolDataLogic.matchesFormMilestoneFilter(
          formMilestone: 'RECEIVED TOOL STORE',
          filterBlankFormMilestone: false,
          excludeFormMilestoneFilter: false,
          milestoneFiltersNorms: const {'DRAFT'},
          excludeMilestoneFilterNorms: const {'RECEIVED TOOL STORE'},
        ),
        isFalse,
      );
    });

    test('no filters passes all forms', () {
      expect(
        ToolDataLogic.matchesFormMilestoneFilter(
          formMilestone: 'anything',
          filterBlankFormMilestone: false,
          excludeFormMilestoneFilter: false,
          milestoneFiltersNorms: const {},
          excludeMilestoneFilterNorms: const {},
        ),
        isTrue,
      );
    });
  });

  group('ToolDataLogic.formsFetchLimit', () {
    test('uses dashboard limit when milestone filters active', () {
      expect(
        ToolDataLogic.formsFetchLimit(hasMilestoneFilters: true),
        kToolFormDashboardFetchLimit,
      );
      expect(
        ToolDataLogic.formsFetchLimit(hasMilestoneFilters: false),
        kToolFormPageSize,
      );
    });
  });

  group('ToolDataLogic.isRejectedApprovalValue', () {
    test('detects rejection tokens', () {
      expect(ToolDataLogic.isRejectedApprovalValue('REJECTED'), isTrue);
      expect(ToolDataLogic.isRejectedApprovalValue('no'), isTrue);
      expect(ToolDataLogic.isRejectedApprovalValue('APPROVED'), isFalse);
    });
  });

  group('ToolDataLogic.serviceSupportMilestoneKind', () {
    test('maps continue and hold milestones', () {
      expect(
        ToolDataLogic.serviceSupportMilestoneKind('continue'),
        ToolDataServiceSupportMilestoneKind.continueFlow,
      );
      expect(
        ToolDataLogic.serviceSupportMilestoneKind('HOLD BY SERVICE ADMIN'),
        ToolDataServiceSupportMilestoneKind.hold,
      );
      expect(
        ToolDataLogic.serviceSupportMilestoneKind('DRAFT'),
        ToolDataServiceSupportMilestoneKind.none,
      );
    });
  });

  group('ToolDataLogic milestone gates', () {
    test('superior approval only at CHECK BY TOOL STORE', () {
      expect(
        ToolDataLogic.canSuperiorApprovalByMilestone('check by tool store'),
        isTrue,
      );
      expect(
        ToolDataLogic.canSuperiorApprovalByMilestone('SUPERIOR APPROVED'),
        isFalse,
      );
    });

    test('request order only for empty or DRAFT', () {
      expect(ToolDataLogic.canRequestOrderByMilestone(''), isTrue);
      expect(ToolDataLogic.canRequestOrderByMilestone('draft'), isTrue);
      expect(
        ToolDataLogic.canRequestOrderByMilestone('CHECK BY TOOL STORE'),
        isFalse,
      );
    });

    test('add tool respects superadmin bypass', () {
      expect(
        ToolDataLogic.canAddToolByMilestone(
          formMilestone: 'RECEIVED TOOL STORE',
          allowAnyMilestone: true,
        ),
        isTrue,
      );
      expect(
        ToolDataLogic.canAddToolByMilestone(
          formMilestone: 'RECEIVED TOOL STORE',
          allowAnyMilestone: false,
        ),
        isFalse,
      );
      expect(
        ToolDataLogic.canAddToolByMilestone(
          formMilestone: '',
          allowAnyMilestone: false,
        ),
        isTrue,
      );
    });
  });
}
