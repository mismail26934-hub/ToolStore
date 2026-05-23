import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';

// Dipanggil saat mulai loading
class FetchUsersAction {}

/// Reload user list without clearing existing rows (keeps scroll position).
class FetchUsersRefreshAction {}

class FetchUsersMoreAction {}

class UsersLoadedAction {
  // Dipanggil saat data berhasil didapat
  final List<PostList> users;
  final bool hasMore;

  /// Total rows di server (pagination), dari API bila tersedia.
  final int? totalUsers;

  UsersLoadedAction(
    this.users, {
    this.hasMore = false,
    this.totalUsers,
  });
}

class UsersAppendAction {
  final List<PostList> users;
  final bool hasMore;

  /// Total rows di server; null = pertahankan nilai state sebelumnya.
  final int? totalUsers;

  UsersAppendAction(
    this.users, {
    required this.hasMore,
    this.totalUsers,
  });
}

class UsersErrorAction {
  // Dipanggil jika terjadi error
  final String errors;
  UsersErrorAction(this.errors);
}

// TOOL
class FetchDatasAction {}

/// Reload form list without clearing existing rows (keeps scroll position).
class FetchDatasRefreshAction {}

class FetchDatasMoreAction {}

class DatasLoadedAction {
  // Dipanggil saat data berhasil didapat
  final List<PostList> forms;
  final bool hasMore;

  /// Total rows di server (pagination), dari `cont_form.php` bila dikirim.
  final int? totalForms;

  DatasLoadedAction(
    this.forms, {
    this.hasMore = false,
    this.totalForms,
  });
}

class DatasAppendAction {
  final List<PostList> forms;
  final bool hasMore;

  /// Total rows di server; null = pertahankan nilai state sebelumnya.
  final int? totalForms;

  DatasAppendAction(
    this.forms, {
    required this.hasMore,
    this.totalForms,
  });
}

class DatasErrorAction {
  // Dipanggil jika terjadi error
  final String errors;
  DatasErrorAction(this.errors);
}

class FetchDashboardCountsAction {}

/// Reload dashboard counts without clearing cached values.
class FetchDashboardCountsRefreshAction {}

class DashboardCountsLoadedAction {
  final FormDashboardCounts counts;
  DashboardCountsLoadedAction(this.counts);
}

class DashboardCountsErrorAction {
  final String errors;
  DashboardCountsErrorAction(this.errors);
}

// TOOL DETAIL
class FetchDataToolsAction {}

/// Reload tool details without clearing existing rows.
class FetchDataToolsRefreshAction {}

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

class FetchDataPORefresh {}

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

class FetchDataSORefresh {}

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

class FetchDataSuperriorRefresh {}

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

class FetchDataRcvWhRefresh {}

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

class FetchDataRcvToolRefresh {}

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
