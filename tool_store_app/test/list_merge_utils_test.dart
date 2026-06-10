import 'package:flutter_test/flutter_test.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/model/repositories/list_merge_utils.dart';

PostList _tool({
  required String idForm,
  required String idFormDetail,
}) {
  return PostList.fromJson({
    'id_form': idForm,
    'id_form_detail': idFormDetail,
  });
}

PostList _po({required String idFormDetail, required String idPo}) {
  return PostList.fromJson({
    'id_form_detail': idFormDetail,
    'id_po': idPo,
  });
}

void main() {
  group('mergeToolsForForm', () {
    test('replaces rows for target form only', () {
      final existing = [
        _tool(idForm: 'F1', idFormDetail: 'D1'),
        _tool(idForm: 'F2', idFormDetail: 'D2'),
      ];
      final incoming = [
        _tool(idForm: 'F1', idFormDetail: 'D1-new'),
      ];

      final merged = mergeToolsForForm(
        existing: existing,
        incoming: incoming,
        idForm: 'F1',
      );

      expect(merged, hasLength(2));
      expect(merged.map((t) => t.idFormDetail).toList(), ['D2', 'D1-new']);
    });

    test('assigns parent id when API omits id_form on detail rows', () {
      final incoming = [
        _tool(idForm: '', idFormDetail: 'D9'),
      ];

      final merged = mergeToolsForForm(
        existing: const [],
        incoming: incoming,
        idForm: 'F1',
      );

      expect(merged, hasLength(1));
      expect(merged.first.idForm, 'F1');
      expect(merged.first.idFormDetail, 'D9');
    });
  });

  group('mergeChildRowsForToolDetails', () {
    test('replaces PO rows for tool detail ids', () {
      final existing = [
        _po(idFormDetail: 'D1', idPo: 'PO-1'),
        _po(idFormDetail: 'D2', idPo: 'PO-2'),
      ];
      final incoming = [
        _po(idFormDetail: 'D1', idPo: 'PO-1-updated'),
      ];

      final merged = mergeChildRowsForToolDetails(
        existing: existing,
        incoming: incoming,
        toolDetailIds: {'D1'},
        childDetailId: (row) => row.idFormDetail,
      );

      expect(merged, hasLength(2));
      expect(merged.map((p) => p.idPo).toList(), ['PO-2', 'PO-1-updated']);
    });
  });
}
