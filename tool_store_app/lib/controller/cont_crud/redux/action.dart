import 'package:tool_store_app/controller/api_url/post_list.dart';

// Dipanggil saat mulai loading
class FetchUsersAction {}

class UsersLoadedAction {
  // Dipanggil saat data berhasil didapat
  final List<PostList> users;
  UsersLoadedAction(this.users);
}

class UsersErrorAction {
  // Dipanggil jika terjadi error
  final String errors;
  UsersErrorAction(this.errors);
}

// TOOL
class FetchDatasAction {}

class DatasLoadedAction {
  // Dipanggil saat data berhasil didapat
  final List<PostList> forms;
  DatasLoadedAction(this.forms);
}

class DatasErrorAction {
  // Dipanggil jika terjadi error
  final String errors;
  DatasErrorAction(this.errors);
}

// TOOL DETAIL
class FetchDataToolsAction {}

class DataToolsLoadedAction {
  // Dipanggil saat data berhasil didapat
  final List<PostList> formsDetail;
  DataToolsLoadedAction(this.formsDetail);
}

class DataToolsErrorAction {
  // Dipanggil jika terjadi error
  final String errors;
  DataToolsErrorAction(this.errors);
}

// PO
class FetchDataPO {}

class DataPOLoadedAction {
  final List<PostList> poS;
  DataPOLoadedAction(this.poS);
}

class DataPOErrorAction {
  final String errors;
  DataPOErrorAction(this.errors);
}

// SO
class FetchDataSO {}

class DataSOLoadedAction {
  final List<PostList> so;
  DataSOLoadedAction(this.so);
}

class DataSOErrorAction {
  final String errors;
  DataSOErrorAction(this.errors);
}

// SUPERRIOR
class FetchDataSuperrior {}

class DataSuperriorLoadedAction {
  final List<PostList> superrior;
  DataSuperriorLoadedAction(this.superrior);
}

class DataSuperriorErrorAction {
  final String errors;
  DataSuperriorErrorAction(this.errors);
}

// RCV WH
class FetchDataRcvWh {}

class DataRcvWhLoadedAction {
  final List<PostList> rcvWh;
  DataRcvWhLoadedAction(this.rcvWh);
}

class DataRcvWhErrorAction {
  final String errors;
  DataRcvWhErrorAction(this.errors);
}

// RCV TOOL ROOM
class FetchDataRcvTool {}

class DataRcvToolLoadedAction {
  final List<PostList> rcvTool;
  DataRcvToolLoadedAction(this.rcvTool);
}

class DataRcvToolErrorAction {
  final String errors;
  DataRcvToolErrorAction(this.errors);
}

//MULTIPLE ADD
class UpdateToolFormAction {
  // Gunakan Map atau buat field satu per satu sesuai kebutuhan
  final Map<String, dynamic> payload;

  UpdateToolFormAction(this.payload);
}
