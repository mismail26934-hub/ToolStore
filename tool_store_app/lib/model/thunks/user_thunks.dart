import 'package:dio/dio.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:tool_store_app/controller/cont_crud/redux/action.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/model/api_client.dart';
import 'package:tool_store_app/model/repositories/list_merge_utils.dart';
import 'package:tool_store_app/model/repositories/user_repository.dart';
import 'package:tool_store_app/view/var/var.dart';

ThunkAction<AppState> getDataUser({
  required String param,
  required String idUsers,
  required String username,
  required String password,
  required String namaUser,
  required String foto,
  required String idTU,
  required String noTelp,
  required String token,
  required String level,
  required String status,
  required String superiorId,
  int page = 1,
  int limit = kUserPageSize,
  bool append = false,
  String viewKeyword = '',
  String viewSearchField = 'all',
}) {
  return (Store<AppState> store) async {
    final isView = param == paramViewDataUser;
    if (isView) {
      if (append) {
        store.dispatch(FetchUsersMoreAction());
      } else if (store.state.userState.users.isNotEmpty) {
        store.dispatch(FetchUsersRefreshAction());
      } else {
        store.dispatch(FetchUsersAction());
      }
    }
    final body = <String, dynamic>{
      'param': param,
      'username': username,
      'password': password,
      'nama_user': namaUser,
      'foto': foto,
      'id_tu': idTU,
      'no_telp': noTelp,
      'token': token,
      'level': level,
      'status': status,
      'superior_id': superiorId,
      'page': page.toString(),
      'limit': limit.toString(),
    };
    final idUsersTrim = idUsers.trim();
    if (idUsersTrim.isNotEmpty) {
      body['id_users'] = idUsersTrim;
    }
    final kw = viewKeyword.trim();
    if (isView && kw.isNotEmpty) {
      body['keyword'] = kw;
      body['search_field'] = viewSearchField.trim().isEmpty
          ? 'all'
          : viewSearchField.trim();
    }
    try {
      final parsed = await fetchUserList(body);
      final listUser = parsed.items;
      final int? apiTotal = parsed.total;

      final bool hasMore;
      if (isView) {
        final mergedCount = append
            ? mergeUsersPreview(store.state.userState.users, listUser).length
            : listUser.length;
        if (apiTotal != null) {
          hasMore = mergedCount < apiTotal;
        } else {
          hasMore = listUser.length >= limit;
        }
      } else {
        hasMore = false;
      }

      if (isView) {
        if (append) {
          store.dispatch(
            UsersAppendAction(listUser, hasMore: hasMore, totalUsers: apiTotal),
          );
        } else {
          store.dispatch(
            UsersLoadedAction(listUser, hasMore: hasMore, totalUsers: apiTotal),
          );
        }
      }
      return listUser;
    } on DioException catch (e) {
      final msg = applyDioError(e);
      if (isView) store.dispatch(UsersErrorAction(msg));
      throw Exception(msg);
    } catch (e) {
      if (isView) store.dispatch(UsersErrorAction(e.toString()));
      throw Exception(e);
    }
  };
}
