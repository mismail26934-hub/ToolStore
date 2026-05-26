import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/controller/function/navigation_helpers.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/mixin/mixin_pref.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/theme/theme_controller.dart';
import 'package:tool_store_app/l10n/l10n_ext.dart';
import 'package:tool_store_app/view/menu/user/user_data_logic.dart';
import 'package:tool_store_app/view/menu/user/user_data.dart' show UserData;
import 'package:tool_store_app/view/var/var.dart';

abstract class UserDataStateBase extends State<UserData> with MixinPref {
  Widget buildSearchBar();
  Widget buildSearchNotFoundContent();
  Widget buildUserCard(PostList users, int index);

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String searchField = 'all';
  int currentPage = 1;

  bool accessPending = true;
  bool accessGranted = false;

  bool get canSubmitSearch => searchController.text.trim().isNotEmpty;

  Future<void> verifySuperAdminAccess() async {
    await refreshPref();
    if (!mounted) return;
    if (UserDataLogic.isSuperAdminLevel(level)) {
      setState(() {
        accessPending = false;
        accessGranted = true;
      });
      refreshUsers();
      return;
    }
    setState(() {
      accessPending = false;
      accessGranted = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.s.accessDeniedSessionEnded),
        ),
      );
      final prefs = await SharedPreferences.getInstance();
      await ThemeController.preserveOnPrefsClear(prefs);
      if (!mounted) return;
      await PageRoutes.routeLoginFast(context);
    });
  }

  void submitSearch() {
    final query = searchController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      searchQuery = query;
    });
    refreshUsers();
  }

  void onSearchTextEdited() => setState(() {});

  void clearSearch() {
    searchController.clear();
    setState(() {
      searchQuery = '';
      searchField = 'all';
    });
    refreshUsers();
  }

  String displayValue(String? value) => UserDataLogic.displayValue(value);

  Color statusColor(String value) {
    switch (UserDataLogic.userStatusTone(value)) {
      case UserDataStatusTone.active:
        return Colors.green;
      case UserDataStatusTone.inactive:
        return Colors.red;
      case UserDataStatusTone.other:
        return Colors.orange;
    }
  }

  Future<void> fetchUsersPage({
    required int page,
    required bool append,
  }) async {
    await store.dispatch(
      getDataUser(
        param: paramViewDataUser,
        idUsers: '',
        username: '',
        password: '',
        namaUser: '',
        foto: '',
        idTU: '',
        noTelp: '',
        token: '',
        level: '',
        status: '',
        superiorId: '',
        page: page,
        limit: kUserPageSize,
        append: append,
        viewKeyword: searchQuery,
        viewSearchField: searchField,
      ),
    );
  }

  void restoreScrollOffset(double offset) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;
      final max = scrollController.position.maxScrollExtent;
      scrollController.jumpTo(offset.clamp(0.0, max));
    });
  }

  Future<void> refreshUsers({bool preserveScroll = false}) async {
    if (!mounted) return;
    final scrollOffset = preserveScroll && scrollController.hasClients
        ? scrollController.offset
        : null;
    setState(() => currentPage = 1);
    try {
      await fetchUsersPage(page: 1, append: false);
    } catch (_) {
      // Error already dispatched to Redux store.
    }
    if (scrollOffset != null && mounted) {
      restoreScrollOffset(scrollOffset);
    }
  }

  Future<void> openUserForm({
    required String idUsers,
    required String username,
    required String password,
    required String namaUser,
    required String noTelp,
    required String idTU,
    required String level,
    required String superiorId,
    required String namaSuperior,
  }) async {
    final updated = await postContUser(
      idUsers,
      username,
      password,
      namaUser,
      noTelp,
      idTU,
      level,
      superiorId,
      namaSuperior,
      context,
      popOnSuccess: true,
    );
    if (updated == true && mounted) {
      await refreshUsers(preserveScroll: true);
    }
  }

  Future<void> loadMoreUsers() async {
    if (store.state.userState.isLoadingMore || !store.state.userState.hasMore) {
      return;
    }
    final nextPage = currentPage + 1;
    try {
      await fetchUsersPage(page: nextPage, append: true);
      if (mounted) setState(() => currentPage = nextPage);
    } catch (_) {
      // Error already dispatched to Redux store.
    }
  }

  String userLoadSummary(UserState state) {
    final n = state.users.length;
    final t = state.totalUsers;
    if (t != null) return context.s.usersLoadedSummary(n, t);
    return context.s.usersLoadedCount(n);
  }
}
