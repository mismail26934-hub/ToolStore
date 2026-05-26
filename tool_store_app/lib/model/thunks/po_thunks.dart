import 'package:dio/dio.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:tool_store_app/controller/cont_crud/redux/action.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/model/api_client.dart';
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
}) {
  return (Store<AppState> store) async {
    final isView = param == paramViewDataPO;
    if (isView && store.state.posDetailState.posDetail.isNotEmpty) {
      store.dispatch(FetchDataPORefresh());
    } else if (isView) {
      store.dispatch(FetchDataPO());
    }
    final body = <String, dynamic>{
      'param': param,
      'id_po': idPO,
      'id_form_detail': idFormDetail,
      'po_no': poNO,
      'date_update_po': dateUpdatePO,
      'user_update_po': userUpdatePO,
    };

    try {
      final PoFetchResult result = await fetchPoList(body, param);
      store.dispatch(DataPOLoadedAction(result.list));
      return result;
    } on DioException catch (e) {
      final msg = applyDioError(e);
      store.dispatch(DataPOErrorAction(errors));
      throw Exception(msg);
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      store.dispatch(DataPOErrorAction(msg));
      rethrow;
    }
  };
}
