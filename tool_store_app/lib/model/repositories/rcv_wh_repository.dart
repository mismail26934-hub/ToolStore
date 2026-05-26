import 'package:tool_store_app/controller/api_url/api.dart';
import 'package:tool_store_app/model/api_client.dart';
import 'package:tool_store_app/model/parsers/mutating_list_fetch_parser.dart';
import 'package:tool_store_app/model/repositories/mutating_list_fetch_result.dart';
import 'package:tool_store_app/view/var/var.dart';

Future<RcvWhFetchResult> fetchRcvWhList(
  Map<String, dynamic> body,
  String param,
) async {
  final response = await apiPost(ApiUrl.contRcvWh, body);
  return parseMutatingListFetchResponse(
    data: response.data,
    param: param,
    isStatusEnvelope: isRcvWhApiStatusEnvelope,
    isMutatingParam: (p) =>
        p == paramAddDataRcvWh ||
        p == paramEditDataRcvWh ||
        p == paramDeleteDataRcvWh,
  );
}
