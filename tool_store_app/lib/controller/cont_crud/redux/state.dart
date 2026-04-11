import 'package:tool_store_app/controller/api_url/post_list.dart';

class UserState {
  final List<PostList> users;
  final bool isLoading;
  final String? error;

  UserState({this.users = const [], this.isLoading = false, this.error});

  // Factory untuk state awal
  factory UserState.initial() => UserState(users: [], isLoading: false);
}
