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

Future<String?> resolveFormIdByFormNo(String formNo) async {
  final query = formNo.trim();
  if (query.isEmpty) return null;

  final parsed = await fetchFormList({
    'param': paramViewDataForm,
    'id_form': '',
    'form_no': '',
    'form_serv_name': '',
    'form_check_by': '',
    'form_date_check_by': '',
    'form_date_serv_name': '',
    'form_serv_comment': '',
    'form_superior_aprd': '',
    'form_superior_comment': '',
    'form_sadmin_comment': '',
    'form_milestone': '',
    'form_status_order': '',
    'form_shead_aprd': '',
    'form_shead_comment': '',
    'from_date_update': '',
    'form_user_update': '',
    'page': '1',
    'limit': '20',
    'keyword': query,
    'search_field': 'formNo',
  });

  for (final form in parsed.items) {
    if (form.formNo.trim() == query) {
      final id = form.idForm.trim();
      if (id.isNotEmpty) return id;
    }
  }

  if (parsed.items.isNotEmpty) {
    final id = parsed.items.first.idForm.trim();
    if (id.isNotEmpty) return id;
  }
  return null;
}
