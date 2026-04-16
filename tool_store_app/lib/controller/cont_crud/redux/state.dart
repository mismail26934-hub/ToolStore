import 'package:tool_store_app/controller/api_url/post_list.dart';

class UserState {
  final List<PostList> users;
  final bool isLoading;
  final String? error;

  UserState({this.users = const [], this.isLoading = false, this.error});

  // Factory untuk state awal
  factory UserState.initial() => UserState(users: [], isLoading: false);

  UserState copyWith({List<PostList>? users, bool? isLoading, String? error}) {
    return UserState(
      // Jika parameter baru (list) null, gunakan nilai yang sudah ada (this.list)
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class FormsState {
  final List<PostList> forms;
  final bool isLoadingTool;
  final String? error;

  FormsState({this.forms = const [], this.isLoadingTool = false, this.error});

  // Factory untuk state awal
  factory FormsState.initial() => FormsState(forms: [], isLoadingTool: false);

  FormsState copyWith({
    List<PostList>? forms,
    bool? isLoadingTool,
    String? error,
  }) {
    return FormsState(
      // Jika parameter baru (list) null, gunakan nilai yang sudah ada (this.list)
      forms: forms ?? this.forms,
      isLoadingTool: isLoadingTool ?? this.isLoadingTool,
      error: error ?? this.error,
    );
  }
}

class AppState {
  final UserState userState;
  final FormsState formsState;

  AppState({required this.userState, required this.formsState});

  factory AppState.initial() => AppState(
    userState: UserState.initial(),
    formsState: FormsState.initial(),
  );
}
