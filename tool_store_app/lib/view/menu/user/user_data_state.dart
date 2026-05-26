import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_appbars.dart';
import 'package:tool_store_app/view/custom/shimmer/app_shimmer.dart';
import 'package:tool_store_app/view/custom/shimmer/skeletons.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/menu/drawer/drawer.dart';
import 'package:tool_store_app/view/var/var.dart';
import 'package:tool_store_app/view/menu/user/user_data_search.dart';
import 'package:tool_store_app/view/menu/user/user_data_user_card.dart';
import 'package:tool_store_app/view/menu/user/user_data_state_base.dart';
import 'package:tool_store_app/view/menu/user/user_data_list.dart';

class UserDataState extends UserDataStateBase with UserDataListMixin {
  @override
  void initState() {
    super.initState();
    verifySuperAdminAccess();
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget buildUserCard(PostList users, int index) {
    return buildUserDataUserCard(
      context: context,
      users: users,
      index: index,
      displayValue: displayValue,
      statusColorForStatus: statusColor,
      onEdit: () => openUserForm(
        idUsers: users.idUsers,
        username: users.username,
        password: users.password,
        namaUser: users.namaUser,
        noTelp: users.noTelp,
        idTU: users.idTU,
        level: users.level,
        superiorId: users.superiorId,
        namaSuperior: users.namaSuperior,
      ),
    );
  }

  @override
  Widget buildSearchBar() {
    return buildUserDataSearchBar(
      context: context,
      searchController: searchController,
      searchField: searchField,
      canSubmitSearch: canSubmitSearch,
      onSubmitSearch: submitSearch,
      onSearchTextEdited: onSearchTextEdited,
      onSearchFieldChanged: (value) {
        setState(() => searchField = value);
        refreshUsers();
      },
      onClearSearch: clearSearch,
    );
  }

  @override
  Widget buildSearchNotFoundContent() {
    return buildUserDataSearchNotFoundContent(
      context: context,
      searchQuery: searchQuery,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (accessPending) {
      return SafeArea(
        bottom: true,
        child: Scaffold(
          backgroundColor: context.pageBackground,
          body: ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: 6,
            itemBuilder: (context, index) => AppShimmer(
              child: UserRowSkeleton(key: ValueKey('user_access_$index')),
            ),
          ),
        ),
      );
    }
    if (!accessGranted) {
      return SafeArea(
        bottom: true,
        child: Scaffold(
          backgroundColor: context.pageBackground,
          body: const SizedBox.shrink(),
        ),
      );
    }

    return SafeArea(
      bottom: true,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: context.pageBackground,
        drawer: DrawerMenu(title: name),
        body: RefreshIndicator(
          onRefresh: refreshUsers,
          child: CustomScrollView(
            key: const PageStorageKey<String>('user_data_scroll'),
            controller: scrollController,
            slivers: [
              SliverAppbars(
                title: titleDataUser,
                onPressTailing: () {
                  openUserForm(
                    idUsers: '',
                    username: '',
                    password: '',
                    namaUser: '',
                    noTelp: '',
                    idTU: '',
                    level: '',
                    superiorId: '',
                    namaSuperior: '',
                  );
                },
                onPressLeading: () => scaffoldKey.currentState?.openDrawer(),
                iconTailing: Icon(Icons.add),
                iconLeading: Icon(Icons.menu),
              ),
              StoreConnector<AppState, UserState>(
                converter: (store) => store.state.userState,
                builder: (context, state) => buildUserDataUsersListSliver(state),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
