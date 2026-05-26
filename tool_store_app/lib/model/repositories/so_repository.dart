import 'package:tool_store_app/controller/api_url/api.dart';
import 'package:tool_store_app/model/api_client.dart';
import 'package:tool_store_app/model/parsers/mutating_list_fetch_parser.dart';
import 'package:tool_store_app/model/repositories/mutating_list_fetch_result.dart';
import 'package:tool_store_app/view/var/var.dart';

Future<SoFetchResult> fetchSoList(
  Map<String, dynamic> body,
  String param,
) async {
  final response = await apiPost(ApiUrl.contSO, body);
  return parseMutatingListFetchResponse(
    data: response.data,
    param: param,
    isStatusEnvelope: isSoApiStatusEnvelope,
    isMutatingParam: (p) =>
        p == paramAddDataSO || p == paramEditDataSO || p == paramDeleteDataSO,
  );
}
