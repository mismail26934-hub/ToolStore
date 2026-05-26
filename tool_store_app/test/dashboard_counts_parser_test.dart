import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/model/parsers/dashboard_counts_parser.dart';

void main() {
  group('parseDashboardCountsResponse', () {
    test('parses map body', () {
      final counts = parseDashboardCountsResponse({
        'draft': 2,
        'superior_approval': 1,
        'notification_total': 5,
      });
      expect(counts.draft, 2);
      expect(counts.superiorApproval, 1);
      expect(counts.notificationTotal, 5);
    });

    test('parses JSON string body', () {
      final body = jsonEncode({
        'draft': '3',
        'counter_ga': 4,
      });
      final counts = parseDashboardCountsResponse(body);
      expect(counts.draft, 3);
      expect(counts.counterGa, 4);
    });

    test('matches FormDashboardCounts.fromJson for same payload', () {
      final payload = {
        'service_admin': 2,
        'dept_head': 1,
      };
      expect(
        parseDashboardCountsResponse(payload),
        FormDashboardCounts.fromJson(payload),
      );
    });

    test('throws on unexpected type', () {
      expect(() => parseDashboardCountsResponse([]), throwsFormatException);
    });
  });
}
