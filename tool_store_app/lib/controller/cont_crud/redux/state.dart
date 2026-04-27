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
      // Jika parameter baru (list) null, gunakan nilai yang sudah ada (this.users)
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
      // Jika parameter baru (list) null, gunakan nilai yang sudah ada (this.forms)
      forms: forms ?? this.forms,
      isLoadingTool: isLoadingTool ?? this.isLoadingTool,
      error: error ?? this.error,
    );
  }
}

class FormsDetailState {
  final List<PostList> formsDetail;
  final bool isLoadingToolDetail;
  final String? error;

  FormsDetailState({
    this.formsDetail = const [],
    this.isLoadingToolDetail = false,
    this.error,
  });

  // Factory untuk state awal
  factory FormsDetailState.initial() =>
      FormsDetailState(formsDetail: [], isLoadingToolDetail: false);

  FormsDetailState copyWith({
    List<PostList>? formsDetail,
    bool? isLoadingToolDetail,
    String? error,
  }) {
    return FormsDetailState(
      // Jika parameter baru (list) null, gunakan nilai yang sudah ada (this.formsDetail)
      formsDetail: formsDetail ?? this.formsDetail,
      isLoadingToolDetail: isLoadingToolDetail ?? this.isLoadingToolDetail,
      error: error ?? this.error,
    );
  }
}

class PosDetailState {
  final List<PostList> posDetail;
  final bool isLoadingPO;
  final String? error;

  PosDetailState({
    this.posDetail = const [],
    this.isLoadingPO = false,
    this.error,
  });

  // Factory untuk state awal
  factory PosDetailState.initial() =>
      PosDetailState(posDetail: [], isLoadingPO: false);

  PosDetailState copyWith({
    List<PostList>? posDetail,
    bool? isLoadingPO,
    String? error,
  }) {
    return PosDetailState(
      // Jika parameter baru (list) null, gunakan nilai yang sudah ada (this.poDetail)
      posDetail: posDetail ?? this.posDetail,
      isLoadingPO: isLoadingPO ?? this.isLoadingPO,
      error: error ?? this.error,
    );
  }
}

class SosDetailState {
  final List<PostList> sosDetail;
  final bool isLoadingSO;
  final String? error;

  SosDetailState({
    this.sosDetail = const [],
    this.isLoadingSO = false,
    this.error,
  });

  // Factory untuk state awal
  factory SosDetailState.initial() =>
      SosDetailState(sosDetail: [], isLoadingSO: false);

  SosDetailState copyWith({
    List<PostList>? sosDetail,
    bool? isLoadingSO,
    String? error,
  }) {
    return SosDetailState(
      // Jika parameter baru (list) null, gunakan nilai yang sudah ada (this.formsDetail)
      sosDetail: sosDetail ?? this.sosDetail,
      isLoadingSO: isLoadingSO ?? this.isLoadingSO,
      error: error ?? this.error,
    );
  }
}

class SuperriorState {
  final List<PostList> superriorS;
  final bool isLoadingSuperrior;
  final String? error;

  SuperriorState({
    this.superriorS = const [],
    this.isLoadingSuperrior = false,
    this.error,
  });

  // Factory untuk state awal
  factory SuperriorState.initial() =>
      SuperriorState(superriorS: [], isLoadingSuperrior: false);

  SuperriorState copyWith({
    List<PostList>? superriorS,
    bool? isLoadingSuperrior,
    String? error,
  }) {
    return SuperriorState(
      // Jika parameter baru (list) null, gunakan nilai yang sudah ada (this.formsDetail)
      superriorS: superriorS ?? this.superriorS,
      isLoadingSuperrior: isLoadingSuperrior ?? this.isLoadingSuperrior,
      error: error ?? this.error,
    );
  }
}

class AppState {
  final UserState userState;
  final FormsState formsState;
  final FormsDetailState formsDetailState;
  final PosDetailState posDetailState;
  final SosDetailState sosDetailState;
  final SuperriorState superriorState;

  AppState({
    required this.userState,
    required this.formsState,
    required this.formsDetailState,
    required this.posDetailState,
    required this.sosDetailState,
    required this.superriorState,
  });

  factory AppState.initial() => AppState(
    userState: UserState.initial(),
    formsState: FormsState.initial(),
    formsDetailState: FormsDetailState.initial(),
    posDetailState: PosDetailState.initial(),
    sosDetailState: SosDetailState.initial(),
    superriorState: SuperriorState.initial(),
  );
}
