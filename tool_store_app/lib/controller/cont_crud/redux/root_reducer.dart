import 'package:redux/redux.dart';
import 'package:tool_store_app/controller/cont_crud/cont_function_crud.dart';
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

final formReducer = combineReducers<FormState>([
  TypedReducer<FormState, FetchUsersAction>(
    (state, action) => state.copyWith(forms: [], isLoading: true, error: null),
  ).call,
  TypedReducer<FormState, UsersLoadedAction>(
    (state, action) => state.copyWith(isLoading: false, forms: action.users),
  ).call,
  TypedReducer<FormState, UsersErrorAction>(
    (state, action) => state.copyWith(isLoading: false, error: action.errors),
  ).call,
]);

// Reducer UTAMA
AppState appReducer(AppState state, dynamic action) {
  return AppState(
    userState: userReducer(state.userState, action),
    formState: formReducer(state.formState, action),
  );
}
