import 'package:dio/dio.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:tool_store_app/controller/cont_crud/redux/action.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/model/api_client.dart';
import 'package:tool_store_app/model/repositories/list_merge_utils.dart';
import 'package:tool_store_app/model/repositories/mutating_list_fetch_result.dart';
import 'package:tool_store_app/model/repositories/tool_detail_repository.dart';
import 'package:tool_store_app/view/var/var.dart';

ThunkAction<AppState> getDataToolDetail({
  required String param,
  required String idFormDetail,
  required String idFrom,
  required String formComment,
  required String pnGroup,
  required String pnDesc,
  required String qty,
  required String explan,
  required String actionNote,
  required String valType,
  required String partValue,
  required String formDetailDate,
  required String formDetailUser,
  bool mergeForForm = false,
}) {
  return (Store<AppState> store) async {
    final isView = param == paramViewDataTool;
    final scopedFormId = idFrom.trim();
    final scopedView = isView && mergeForForm && scopedFormId.isNotEmpty;

    if (isView) {
      if (scopedView) {
        store.dispatch(FetchDataToolsRefreshAction());
      } else if (store.state.formsDetailState.formsDetail.isNotEmpty) {
        store.dispatch(FetchDataToolsRefreshAction());
      } else {
        store.dispatch(FetchDataToolsAction());
      }
    }
    final body = <String, dynamic>{
      'param': param,
      'id_form_detail': idFormDetail,
      'id_form': idFrom,
      'idFrom': idFrom,
      'idForm': idFrom,
      'form_comment': formComment,
      'pn_group': pnGroup,
      'pn_desc': pnDesc,
      'qty': qty,
      'explan': explan,
      'action_note': actionNote,
      'val_type': valType,
      'part_value': partValue,
      'form_detail_date': formDetailDate,
      'formDetailDate': formDetailDate,
      'form_detail_user': formDetailUser,
      'formDetailUser': formDetailUser,
    };

    try {
      final ToolDetailFetchResult result = await fetchToolDetailList(
        body,
        param,
      );
      if (isView) {
        final list = scopedView
            ? mergeToolsForForm(
                existing: store.state.formsDetailState.formsDetail,
                incoming: result.list,
                idForm: scopedFormId,
              )
            : result.list;
        store.dispatch(DataToolsLoadedAction(list));
      }
      return result;
    } on DioException catch (e) {
      final msg = applyDioError(e);
      store.dispatch(DataToolsErrorAction(msg));
      throw Exception(msg);
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      store.dispatch(DataToolsErrorAction(msg));
      rethrow;
    }
  };
}
