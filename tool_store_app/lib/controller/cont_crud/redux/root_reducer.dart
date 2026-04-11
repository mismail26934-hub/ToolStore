import 'package:tool_store_app/controller/cont_crud/cont_function_crud.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';

UserState userReducer(UserState state, dynamic action) {
  if (action is FetchUsersAction) {
    return UserState(users: [], isLoading: true, error: null);
  } else if (action is UsersLoadedAction) {
    return UserState(users: action.users, isLoading: false, error: null);
  } else if (action is UsersErrorAction) {
    return UserState(users: [], isLoading: false, error: action.errors);
  }
  return state;
}
