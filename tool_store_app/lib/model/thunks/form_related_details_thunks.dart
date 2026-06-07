import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/model/thunks/po_thunks.dart';
import 'package:tool_store_app/model/thunks/rcv_thunks.dart';
import 'package:tool_store_app/model/thunks/so_thunks.dart';
import 'package:tool_store_app/model/thunks/tool_detail_thunks.dart';
import 'package:tool_store_app/view/var/var.dart';

/// Loads tool lines and related PO/SO/Rcv rows for one form (server-scoped by `id_form`).
ThunkAction<AppState> loadFormRelatedDetails({
  required String idForm,
}) {
  return (Store<AppState> store) async {
    final id = idForm.trim();
    if (id.isEmpty) return;

    await store.dispatch(
      getDataToolDetail(
        param: paramViewDataTool,
        idFormDetail: '',
        idFrom: id,
        formComment: '',
        pnGroup: '',
        pnDesc: '',
        qty: '',
        explan: '',
        actionNote: '',
        valType: '',
        partValue: '',
        formDetailDate: '',
        formDetailUser: '',
        mergeForForm: true,
      ),
    );

    await Future.wait<void>([
      store.dispatch(
        getDataPO(
          param: paramViewDataPO,
          idPO: '',
          idFormDetail: '',
          idForm: id,
          poNO: '',
          dateUpdatePO: '',
          userUpdatePO: '',
          mergeForForm: true,
        ),
      ),
      store.dispatch(
        getDataSO(
          param: paramViewDataSO,
          idSo: '',
          idFormDetail: '',
          idForm: id,
          so: '',
          eta: '',
          noteSo: '',
          dateUpdateSo: '',
          idUpdateSo: '',
          mergeForForm: true,
        ),
      ),
      store.dispatch(
        getDataRcvWh(
          param: paramViewDataRcvWh,
          idRcvWh: '',
          idFormDetail: '',
          idForm: id,
          rcvWhDate: '',
          rcvWhIdInput: '',
          rcvWhDateInput: '',
          mergeForForm: true,
        ),
      ),
      store.dispatch(
        getDataRcvTool(
          param: paramViewDataRcvTool,
          idRcvTool: '',
          idFormDetail: '',
          idForm: id,
          rcvToolDate: '',
          rcvToolIdInput: '',
          rcvToolDateInput: '',
          mergeForForm: true,
        ),
      ),
    ]);
  };
}
