import 'package:dio/dio.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:tool_store_app/controller/cont_crud/redux/action.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/model/api_client.dart';
import 'package:tool_store_app/model/repositories/list_merge_utils.dart';
import 'package:tool_store_app/model/repositories/mutating_list_fetch_result.dart';
import 'package:tool_store_app/model/repositories/rcv_tool_repository.dart';
import 'package:tool_store_app/model/repositories/rcv_wh_repository.dart';
import 'package:tool_store_app/view/var/var.dart';

ThunkAction<AppState> getDataRcvWh({
  required String param,
  required String idRcvWh,
  required String idFormDetail,
  required String rcvWhDate,
  required String rcvWhIdInput,
  required String rcvWhDateInput,
  String idForm = '',
  bool mergeForForm = false,
}) {
  return (Store<AppState> store) async {
    final isView = param == paramViewDataRcvWh;
    final scopedFormId = idForm.trim();
    final scopedView = isView && mergeForForm && scopedFormId.isNotEmpty;

    if (isView) {
      if (scopedView) {
        store.dispatch(FetchDataRcvWhRefresh());
      } else if (store.state.rcvWhState.rcvWhs.isNotEmpty) {
        store.dispatch(FetchDataRcvWhRefresh());
      } else {
        store.dispatch(FetchDataRcvWh());
      }
    }
    final body = <String, dynamic>{
      'param': param,
      'id_rcv_wh': idRcvWh,
      'id_form_detail': idFormDetail,
      'rcv_wh_date': rcvWhDate,
      'rcv_wh_id_input': rcvWhIdInput,
      'rcv_wh_date_input': rcvWhDateInput,
    };
    if (scopedView) {
      body['id_form'] = scopedFormId;
      body['idForm'] = scopedFormId;
    }

    try {
      final RcvWhFetchResult result = await fetchRcvWhList(body, param);
      if (isView) {
        final list = scopedView
            ? mergeChildRowsForToolDetails(
                existing: store.state.rcvWhState.rcvWhs,
                incoming: result.list,
                toolDetailIds: toolDetailIdsForForm(
                  store.state.formsDetailState.formsDetail,
                  scopedFormId,
                ),
                childDetailId: (row) => row.idFormDetail,
              )
            : result.list;
        store.dispatch(DataRcvWhLoadedAction(list));
      }
      return result;
    } on DioException catch (e) {
      final msg = applyDioError(e);
      store.dispatch(DataRcvWhErrorAction(msg));
      throw Exception(msg);
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      store.dispatch(DataRcvWhErrorAction(msg));
      rethrow;
    }
  };
}

ThunkAction<AppState> getDataRcvTool({
  required String param,
  required String idRcvTool,
  required String idFormDetail,
  required String rcvToolDate,
  required String rcvToolIdInput,
  required String rcvToolDateInput,
  String idForm = '',
  bool mergeForForm = false,
}) {
  return (Store<AppState> store) async {
    final isView = param == paramViewDataRcvTool;
    final scopedFormId = idForm.trim();
    final scopedView = isView && mergeForForm && scopedFormId.isNotEmpty;

    if (isView) {
      if (scopedView) {
        store.dispatch(FetchDataRcvToolRefresh());
      } else if (store.state.rcvToolState.rcvTools.isNotEmpty) {
        store.dispatch(FetchDataRcvToolRefresh());
      } else {
        store.dispatch(FetchDataRcvTool());
      }
    }
    final body = <String, dynamic>{
      'param': param,
      'id_rcv_tool': idRcvTool,
      'id_form_detail': idFormDetail,
      'rcv_tool_date': rcvToolDate,
      'rcv_tool_id_input': rcvToolIdInput,
      'rcv_tool_date_input': rcvToolDateInput,
    };
    if (scopedView) {
      body['id_form'] = scopedFormId;
      body['idForm'] = scopedFormId;
    }

    try {
      final RcvToolFetchResult result = await fetchRcvToolList(body, param);
      if (isView) {
        final list = scopedView
            ? mergeChildRowsForToolDetails(
                existing: store.state.rcvToolState.rcvTools,
                incoming: result.list,
                toolDetailIds: toolDetailIdsForForm(
                  store.state.formsDetailState.formsDetail,
                  scopedFormId,
                ),
                childDetailId: (row) => row.idFormDetail,
              )
            : result.list;
        store.dispatch(DataRcvToolLoadedAction(list));
      }
      return result;
    } on DioException catch (e) {
      final msg = applyDioError(e);
      store.dispatch(DataRcvToolErrorAction(msg));
      throw Exception(msg);
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      store.dispatch(DataRcvToolErrorAction(msg));
      rethrow;
    }
  };
}
