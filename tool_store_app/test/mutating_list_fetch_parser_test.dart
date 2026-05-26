import 'package:flutter_test/flutter_test.dart';
import 'package:tool_store_app/model/parsers/mutating_list_fetch_parser.dart';
import 'package:tool_store_app/view/var/var.dart';

void main() {
  group('parseMutatingListFetchResponse', () {
    test('parses view rows and ignores status envelope', () {
      final result = parseMutatingListFetchResponse(
        data: [
          {'value': '1', 'message': 'OK'},
          {'id_po': '10', 'po_no': 'PO-1'},
        ],
        param: paramViewDataPO,
        isStatusEnvelope: isPoApiStatusEnvelope,
        isMutatingParam: (p) =>
            p == paramAddDataPO ||
            p == paramEditDataPO ||
            p == paramDeleteDataPO,
      );
      expect(result.list, hasLength(1));
      expect(result.list.first.idPo, '10');
      expect(result.statusValue, isNull);
    });

    test('returns failure envelope on mutating param when value is not 1', () {
      final result = parseMutatingListFetchResponse(
        data: [
          {'value': '0', 'message': 'Duplicate PO'},
        ],
        param: paramAddDataPO,
        isStatusEnvelope: isPoApiStatusEnvelope,
        isMutatingParam: (p) => p == paramAddDataPO,
      );
      expect(result.statusValue, '0');
      expect(result.serverMessage, 'Duplicate PO');
      expect(result.list, isEmpty);
    });
  });
}
