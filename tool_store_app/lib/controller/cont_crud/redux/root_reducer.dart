import 'package:redux/redux.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/action.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';

List<PostList> _mergeUsers(List<PostList> existing, List<PostList> incoming) {
  if (incoming.isEmpty) return existing;
  final ids = existing.map((u) => u.idUsers.trim()).toSet();
  final merged = List<PostList>.from(existing);
  for (final user in incoming) {
    final id = user.idUsers.trim();
    if (id.isEmpty || !ids.contains(id)) {
      merged.add(user);
      if (id.isNotEmpty) ids.add(id);
    }
  }
  return merged;
}

final userReducer = combineReducers<UserState>([
  TypedReducer<UserState, FetchUsersAction>(
    (state, action) => state.copyWith(
      users: [],
      isLoading: true,
      isLoadingMore: false,
      hasMore: true,
      error: null,
      clearTotalUsers: true,
    ),
  ).call,
  TypedReducer<UserState, FetchUsersMoreAction>(
    (state, action) => state.copyWith(isLoadingMore: true, error: null),
  ).call,
  TypedReducer<UserState, UsersLoadedAction>(
    (state, action) => state.copyWith(
      isLoading: false,
      isLoadingMore: false,
      users: action.users,
      hasMore: action.hasMore,
      totalUsers: action.totalUsers,
      clearTotalUsers: action.totalUsers == null,
    ),
  ).call,
  TypedReducer<UserState, UsersAppendAction>(
    (state, action) => state.copyWith(
      isLoadingMore: false,
      users: _mergeUsers(state.users, action.users),
      hasMore: action.hasMore,
      totalUsers: action.totalUsers ?? state.totalUsers,
    ),
  ).call,
  TypedReducer<UserState, UsersErrorAction>(
    (state, action) => state.copyWith(
      isLoading: false,
      isLoadingMore: false,
      error: action.errors,
    ),
  ).call,
]);

List<PostList> _mergeForms(List<PostList> existing, List<PostList> incoming) {
  if (incoming.isEmpty) return existing;
  final ids = existing.map((f) => f.idForm.trim()).toSet();
  final merged = List<PostList>.from(existing);
  for (final form in incoming) {
    final id = form.idForm.trim();
    if (id.isEmpty || !ids.contains(id)) {
      merged.add(form);
      if (id.isNotEmpty) ids.add(id);
    }
  }
  return merged;
}

final formReducer = combineReducers<FormsState>([
  TypedReducer<FormsState, FetchDatasAction>(
    (state, action) => state.copyWith(
      forms: [],
      isLoadingTool: true,
      isLoadingMore: false,
      hasMore: true,
      error: null,
      clearTotalForms: true,
    ),
  ).call,
  TypedReducer<FormsState, FetchDatasMoreAction>(
    (state, action) => state.copyWith(isLoadingMore: true, error: null),
  ).call,
  TypedReducer<FormsState, DatasLoadedAction>(
    (state, action) => state.copyWith(
      isLoadingTool: false,
      isLoadingMore: false,
      forms: action.forms,
      hasMore: action.hasMore,
      totalForms: action.totalForms,
      clearTotalForms: action.totalForms == null,
    ),
  ).call,
  TypedReducer<FormsState, DatasAppendAction>(
    (state, action) => state.copyWith(
      isLoadingMore: false,
      forms: _mergeForms(state.forms, action.forms),
      hasMore: action.hasMore,
      totalForms: action.totalForms ?? state.totalForms,
    ),
  ).call,
  TypedReducer<FormsState, DatasErrorAction>(
    (state, action) => state.copyWith(
      isLoadingTool: false,
      isLoadingMore: false,
      error: action.errors,
    ),
  ).call,
  TypedReducer<FormsState, FetchDashboardCountsAction>(
    (state, action) => state.copyWith(
      isLoadingDashboardCounts: true,
      clearDashboardCountsError: true,
    ),
  ).call,
  TypedReducer<FormsState, DashboardCountsLoadedAction>(
    (state, action) => state.copyWith(
      isLoadingDashboardCounts: false,
      dashboardCounts: action.counts,
      clearDashboardCountsError: true,
    ),
  ).call,
  TypedReducer<FormsState, DashboardCountsErrorAction>(
    (state, action) => state.copyWith(
      isLoadingDashboardCounts: false,
      dashboardCountsError: action.errors,
    ),
  ).call,
]);

final formsDetailReducer = combineReducers<FormsDetailState>([
  TypedReducer<FormsDetailState, FetchDataToolsAction>(
    (state, action) =>
        state.copyWith(formsDetail: [], isLoadingToolDetail: true, error: null),
  ).call,
  TypedReducer<FormsDetailState, DataToolsLoadedAction>(
    (state, action) => state.copyWith(
      isLoadingToolDetail: false,
      formsDetail: action.formsDetail,
    ),
  ).call,
  TypedReducer<FormsDetailState, DataToolsErrorAction>(
    (state, action) =>
        state.copyWith(isLoadingToolDetail: false, error: action.errors),
  ).call,
]);

final poReducer = combineReducers<PosDetailState>([
  TypedReducer<PosDetailState, FetchDataPO>(
    (state, action) =>
        state.copyWith(posDetail: [], isLoadingPO: true, error: null),
  ).call,
  TypedReducer<PosDetailState, DataPOLoadedAction>(
    (state, action) =>
        state.copyWith(isLoadingPO: false, posDetail: action.poS),
  ).call,
  TypedReducer<PosDetailState, DataPOErrorAction>(
    (state, action) => state.copyWith(isLoadingPO: false, error: action.errors),
  ).call,
]);

final soReducer = combineReducers<SosDetailState>([
  TypedReducer<SosDetailState, FetchDataSO>(
    (state, action) =>
        state.copyWith(sosDetail: [], isLoadingSO: true, error: null),
  ).call,
  TypedReducer<SosDetailState, DataSOLoadedAction>(
    (state, action) => state.copyWith(isLoadingSO: false, sosDetail: action.so),
  ).call,
  TypedReducer<SosDetailState, DataSOErrorAction>(
    (state, action) => state.copyWith(isLoadingSO: false, error: action.errors),
  ).call,
]);

final superriorReducer = combineReducers<SuperriorState>([
  TypedReducer<SuperriorState, FetchDataSuperrior>(
    (state, action) =>
        state.copyWith(superriorS: [], isLoadingSuperrior: true, error: null),
  ).call,
  TypedReducer<SuperriorState, DataSuperriorLoadedAction>(
    (state, action) =>
        state.copyWith(isLoadingSuperrior: false, superriorS: action.superrior),
  ).call,
  TypedReducer<SuperriorState, DataSuperriorErrorAction>(
    (state, action) =>
        state.copyWith(isLoadingSuperrior: false, error: action.errors),
  ).call,
]);

final rcvWhReducer = combineReducers<RcvWhState>([
  TypedReducer<RcvWhState, FetchDataRcvWh>(
    (state, action) =>
        state.copyWith(rcvWhs: [], isLoadingrcvWh: true, error: null),
  ).call,
  TypedReducer<RcvWhState, DataRcvWhLoadedAction>(
    (state, action) =>
        state.copyWith(isLoadingrcvWh: false, rcvWhs: action.rcvWh),
  ).call,
  TypedReducer<RcvWhState, DataRcvWhErrorAction>(
    (state, action) =>
        state.copyWith(isLoadingrcvWh: false, error: action.errors),
  ).call,
]);

final rcvToolReducer = combineReducers<RcvToolState>([
  TypedReducer<RcvToolState, FetchDataRcvTool>(
    (state, action) =>
        state.copyWith(rcvTools: [], isLoadingrcvTool: true, error: null),
  ).call,
  TypedReducer<RcvToolState, DataRcvToolLoadedAction>(
    (state, action) =>
        state.copyWith(isLoadingrcvTool: false, rcvTools: action.rcvTool),
  ).call,
  TypedReducer<RcvToolState, DataRcvToolErrorAction>(
    (state, action) =>
        state.copyWith(isLoadingrcvTool: false, error: action.errors),
  ).call,
]);

// Reducer UTAMA
AppState appReducer(AppState state, dynamic action) {
  return AppState(
    userState: userReducer(state.userState, action),
    formsState: formReducer(state.formsState, action),
    formsDetailState: formsDetailReducer(state.formsDetailState, action),
    posDetailState: poReducer(state.posDetailState, action),
    sosDetailState: soReducer(state.sosDetailState, action),
    superriorState: superriorReducer(state.superriorState, action),
    rcvWhState: rcvWhReducer(state.rcvWhState, action),
    rcvToolState: rcvToolReducer(state.rcvToolState, action),
  );
}
