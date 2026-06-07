import 'package:dio/dio.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:tool_store_app/controller/cont_crud/redux/action.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/model/api_client.dart';
import 'package:tool_store_app/model/repositories/list_merge_utils.dart';
import 'package:tool_store_app/model/repositories/mutating_list_fetch_result.dart';
import 'package:tool_store_app/model/repositories/so_repository.dart';
import 'package:tool_store_app/view/var/var.dart';

ThunkAction<AppState> getDataSO({
  required String param,
  required String idSo,
  required String idFormDetail,
  required String so,
  required String eta,
  required String noteSo,
  required String dateUpdateSo,
  required String idUpdateSo,
  String idForm = '',
  bool mergeForForm = false,
}) {
  return (Store<AppState> store) async {
    final isView = param == paramViewDataSO;
    final scopedFormId = idForm.trim();
    final scopedView = isView && mergeForForm && scopedFormId.isNotEmpty;

    if (isView) {
      if (scopedView) {
        store.dispatch(FetchDataSORefresh());
      } else if (store.state.sosDetailState.sosDetail.isNotEmpty) {
        store.dispatch(FetchDataSORefresh());
      } else {
        store.dispatch(FetchDataSO());
      }
    }
    final body = <String, dynamic>{
      'param': param,
      'id_so': idSo,
      'id_form_detail': idFormDetail,
      'so': so,
      'eta': eta,
      'note_so': noteSo,
      'date_update_so': dateUpdateSo,
      'id_update_so': idUpdateSo,
    };
    if (scopedView) {
      body['id_form'] = scopedFormId;
      body['idForm'] = scopedFormId;
    }

    try {
      final SoFetchResult result = await fetchSoList(body, param);
      if (isView) {
        final list = scopedView
            ? mergeChildRowsForToolDetails(
                existing: store.state.sosDetailState.sosDetail,
                incoming: result.list,
                toolDetailIds: toolDetailIdsForForm(
                  store.state.formsDetailState.formsDetail,
                  scopedFormId,
                ),
                childDetailId: (row) => row.idFormDetail,
              )
            : result.list;
        store.dispatch(DataSOLoadedAction(list));
      }
      return result;
    } on DioException catch (e) {
      final msg = applyDioError(e);
      store.dispatch(DataSOErrorAction(msg));
      throw Exception(msg);
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      store.dispatch(DataSOErrorAction(msg));
      rethrow;
    }
  };
}
