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

// Reducer UTAMA
AppState appReducer(AppState state, dynamic action) {
  return AppState(
    userState: userReducer(state.userState, action),
    formsState: formReducer(state.formsState, action),
  );
}
