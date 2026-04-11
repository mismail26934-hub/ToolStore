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
