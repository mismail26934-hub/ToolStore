import 'package:flutter_test/flutter_test.dart';
import 'package:tool_store_app/view/menu/tool/tool_order_timeline.dart';

void main() {
  group('OrderTimelineLogic.normFormMilestone', () {
    test('normalizes case, dots, and extra spaces', () {
      expect(
        OrderTimelineLogic.normFormMilestone('  check by tool store.  '),
        'CHECK BY TOOL STORE',
      );
    });
  });

  group('OrderTimelineLogic.filledStepsFromMilestoneNorm', () {
    test('maps known milestones to step counts', () {
      expect(OrderTimelineLogic.filledStepsFromMilestoneNorm(''), 0);
      expect(OrderTimelineLogic.filledStepsFromMilestoneNorm('DRAFT'), 0);
      expect(
        OrderTimelineLogic.filledStepsFromMilestoneNorm('CHECK BY TOOL STORE'),
        1,
      );
      expect(
        OrderTimelineLogic.filledStepsFromMilestoneNorm('SUPERIOR APPROVED'),
        2,
      );
      expect(
        OrderTimelineLogic.filledStepsFromMilestoneNorm('RECEIVED TOOL STORE'),
        7,
      );
    });
  });

  group('OrderTimelineLogic.isApprovedValue', () {
    test('accepts common approval tokens', () {
      expect(OrderTimelineLogic.isApprovedValue('APPROVED'), isTrue);
      expect(OrderTimelineLogic.isApprovedValue('y'), isTrue);
      expect(OrderTimelineLogic.isApprovedValue('NO'), isFalse);
    });
  });

  group('OrderTimelineViewModel', () {
    test('equality uses all fields', () {
      const a = OrderTimelineViewModel(orangeCompleted: 3);
      const b = OrderTimelineViewModel(orangeCompleted: 3);
      const c = OrderTimelineViewModel(
        orangeCompleted: 3,
        partialStepIndex: 5,
        partialProgress: 0.5,
      );
      expect(a, b);
      expect(a == c, isFalse);
    });
  });
}
