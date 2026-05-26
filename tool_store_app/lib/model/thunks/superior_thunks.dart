import 'package:dio/dio.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:tool_store_app/controller/cont_crud/redux/action.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/model/api_client.dart';
import 'package:tool_store_app/model/repositories/superior_repository.dart';
import 'package:tool_store_app/view/var/var.dart';

ThunkAction<AppState> getDataSuperrior({
  required String param,
  required String superiorId,
  required String namaSuperior,
  required String statusSuperior,
  required String userIdInputSuperior,
  required String dateInputSuperior,
}) {
  return (Store<AppState> store) async {
    final isView = param == paramViewDataSuperrior;
    if (isView && store.state.superriorState.superriorS.isNotEmpty) {
      store.dispatch(FetchDataSuperriorRefresh());
    } else if (isView) {
      store.dispatch(FetchDataSuperrior());
    }
    final body = <String, dynamic>{
      'param': param,
      'superior_id': superiorId,
      'nama_superior': namaSuperior,
      'status_superior': statusSuperior,
      'user_id_input_superior': userIdInputSuperior,
      'date_input_superior': dateInputSuperior,
    };

    try {
      final parsed = await fetchSuperiorList(body);
      final listSuperrior = parsed.items;
      store.dispatch(DataSuperriorLoadedAction(listSuperrior));
      return listSuperrior;
    } on DioException catch (e) {
      final msg = applyDioError(e);
      store.dispatch(DataSuperriorErrorAction(msg));
      return [];
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      store.dispatch(DataSuperriorErrorAction(msg));
      return [];
    }
  };
}
