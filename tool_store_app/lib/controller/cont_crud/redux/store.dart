import 'package:redux/redux.dart';
import 'package:tool_store_app/controller/cont_crud/redux/root_reducer.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';

final store = Store<UserState>(userReducer, initialState: UserState.initial());
