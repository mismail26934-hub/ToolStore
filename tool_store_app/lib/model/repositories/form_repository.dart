import 'package:tool_store_app/controller/api_url/api.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/model/api_client.dart';
import 'package:tool_store_app/model/parsers/dashboard_counts_parser.dart';
import 'package:tool_store_app/model/parsers/form_list_parser.dart';
import 'package:tool_store_app/view/var/var.dart';

/// Page size for tool form list lazy loading (matches PHP default in cont_form.php).
const int kToolFormPageSize = 20;

/// Larger fetch for dashboard milestone counts (legacy; dashboard uses COUNT API).
const int kToolFormDashboardFetchLimit = 1000;

Future<ParsedFormListResult> fetchFormList(Map<String, dynamic> body) async {
  final response = await apiPost(ApiUrl.contDataTool, body);
  return parseFormListResponse(response.data);
}

Future<FormDashboardCounts> fetchDashboardFormCounts() async {
  final response = await apiPost(ApiUrl.contDataTool, {
    'param': paramDashboardCountForm,
  });
  return parseDashboardCountsResponse(response.data);
}
