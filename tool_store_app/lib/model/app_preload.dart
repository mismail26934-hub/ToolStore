import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/model/api_client.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/var/var.dart';

/// Preloads Redux data after login. Skips when no session token is stored.
///
/// Dispatch order is fixed: user → forms → superior → dashboard counts.
/// Tool/PO/SO/Rcv details load lazily when a form card is expanded.
Future<void> preloadAuthenticatedData() async {
  final creds = await loadAuthCredentials();
  if (!creds.isAuthenticated) return;

  store.dispatch(
    getDataUser(
      param: paramViewDataUser,
      idUsers: '',
      username: '',
      password: '',
      namaUser: '',
      foto: '',
      idTU: '',
      noTelp: '',
      token: creds.token,
      level: '',
      status: '',
      superiorId: '',
      limit: kUserFullFetchLimit,
    ),
  );

  store.dispatch(
    getDataTool(
      param: paramViewDataForm,
      idForm: '',
      formNo: '',
      formServName: '',
      formCheckBy: '',
      formDateCheckBy: '',
      formDateServName: '',
      formServComment: '',
      formSuperiorAprd: '',
      formSuperiorComment: '',
      formSadminComment: '',
      formMilestone: '',
      formStatusOrder: '',
      formSheadAprd: '',
      formSheadComment: '',
      fromDateUpdate: '',
      formUserUpdate: '',
    ),
  );

  store.dispatch(
    getDataSuperrior(
      param: paramViewDataSuperrior,
      superiorId: '',
      namaSuperior: '',
      statusSuperior: '',
      userIdInputSuperior: '',
      dateInputSuperior: '',
    ),
  );

  store.dispatch(getDashboardFormCounts());
}
