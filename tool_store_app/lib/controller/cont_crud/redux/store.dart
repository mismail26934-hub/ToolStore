import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:tool_store_app/controller/cont_crud/redux/root_reducer.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';

final store = Store<AppState>(
  appReducer,
  initialState: AppState.initial(),
  middleware: [thunkMiddleware.call],
);
