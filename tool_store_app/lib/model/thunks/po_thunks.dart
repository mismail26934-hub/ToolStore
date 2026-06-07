import 'package:dio/dio.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:tool_store_app/controller/cont_crud/redux/action.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/model/api_client.dart';
import 'package:tool_store_app/model/repositories/list_merge_utils.dart';
import 'package:tool_store_app/model/repositories/mutating_list_fetch_result.dart';
import 'package:tool_store_app/model/repositories/po_repository.dart';
import 'package:tool_store_app/view/var/var.dart';

ThunkAction<AppState> getDataPO({
  required String param,
  required String idPO,
  required String idFormDetail,
  required String poNO,
  required String dateUpdatePO,
  required String userUpdatePO,
  String idForm = '',
  bool mergeForForm = false,
}) {
  return (Store<AppState> store) async {
    final isView = param == paramViewDataPO;
    final scopedFormId = idForm.trim();
    final scopedView = isView && mergeForForm && scopedFormId.isNotEmpty;

    if (isView) {
      if (scopedView) {
        store.dispatch(FetchDataPORefresh());
      } else if (store.state.posDetailState.posDetail.isNotEmpty) {
        store.dispatch(FetchDataPORefresh());
      } else {
        store.dispatch(FetchDataPO());
      }
    }
    final body = <String, dynamic>{
      'param': param,
      'id_po': idPO,
      'id_form_detail': idFormDetail,
      'po_no': poNO,
      'date_update_po': dateUpdatePO,
      'user_update_po': userUpdatePO,
    };
    if (scopedView) {
      body['id_form'] = scopedFormId;
      body['idForm'] = scopedFormId;
    }

    try {
      final PoFetchResult result = await fetchPoList(body, param);
      if (isView) {
        final list = scopedView
            ? mergeChildRowsForToolDetails(
                existing: store.state.posDetailState.posDetail,
                incoming: result.list,
                toolDetailIds: toolDetailIdsForForm(
                  store.state.formsDetailState.formsDetail,
                  scopedFormId,
                ),
                childDetailId: (row) => row.idFormDetail,
              )
            : result.list;
        store.dispatch(DataPOLoadedAction(list));
      }
      return result;
    } on DioException catch (e) {
      final msg = applyDioError(e);
      store.dispatch(DataPOErrorAction(msg));
      throw Exception(msg);
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      store.dispatch(DataPOErrorAction(msg));
      rethrow;
    }
  };
}
