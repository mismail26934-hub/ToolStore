import 'package:redux/redux.dart';
import 'package:tool_store_app/controller/cont_crud/redux/action.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';

final userReducer = combineReducers<UserState>([
  TypedReducer<UserState, FetchUsersAction>(
    (state, action) => state.copyWith(users: [], isLoading: true, error: null),
  ).call,
  TypedReducer<UserState, UsersLoadedAction>((state, action) {
    return state.copyWith(isLoading: false, users: action.users);
  }).call,
  TypedReducer<UserState, UsersErrorAction>(
    (state, action) => state.copyWith(isLoading: false, error: action.errors),
  ).call,
]);

final formReducer = combineReducers<FormsState>([
  TypedReducer<FormsState, FetchDatasAction>(
    (state, action) =>
        state.copyWith(forms: [], isLoadingTool: true, error: null),
  ).call,
  TypedReducer<FormsState, DatasLoadedAction>(
    (state, action) =>
        state.copyWith(isLoadingTool: false, forms: action.forms),
  ).call,
  TypedReducer<FormsState, DatasErrorAction>(
    (state, action) =>
        state.copyWith(isLoadingTool: false, error: action.errors),
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

// Reducer UTAMA
AppState appReducer(AppState state, dynamic action) {
  return AppState(
    userState: userReducer(state.userState, action),
    formsState: formReducer(state.formsState, action),
    formsDetailState: formsDetailReducer(state.formsDetailState, action),
    posDetailState: poReducer(state.posDetailState, action),
    sosDetailState: soReducer(state.sosDetailState, action),
    superriorState: superriorReducer(state.superriorState, action),
  );
}
