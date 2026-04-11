import 'package:tool_store_app/controller/api_url/post_list.dart';

class UserState {
  late final List<PostList> users;
  late bool isLoading;
  late final String? error;

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

class FormState {
  late final List<PostList> forms;
  late bool isLoading;
  late final String? error;

  FormState({this.forms = const [], this.isLoading = false, this.error});

  // Factory untuk state awal
  factory FormState.initial() => FormState(forms: [], isLoading: false);

  FormState copyWith({List<PostList>? forms, bool? isLoading, String? error}) {
    return FormState(
      // Jika parameter baru (list) null, gunakan nilai yang sudah ada (this.list)
      forms: forms ?? this.forms,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AppState {
  final UserState userState;
  final FormState formState;

  AppState({required this.userState, required this.formState});

  factory AppState.initial() =>
      AppState(userState: UserState.initial(), formState: FormState.initial());
}
