import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/controller/function/funct.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/mixin/mixin_pref.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_appbars.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_fill_remaining.dart';
import 'package:tool_store_app/view/custom/shimmer/app_shimmer.dart';
import 'package:tool_store_app/view/custom/shimmer/skeletons.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/theme/theme_controller.dart';
import 'package:tool_store_app/l10n/l10n_ext.dart';
import 'package:tool_store_app/view/menu/drawer/drawer.dart';
import 'package:tool_store_app/view/var/var.dart';

class UserData extends StatefulWidget {
  const UserData({super.key});
  @override
  State<UserData> createState() => _UserDataState();
}

class _UserDataState extends State<UserData> with MixinPref {
  // 1. Buat variabel key di sini
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _searchField = 'all';
  int _currentPage = 1;

  bool _accessPending = true;
  bool _accessGranted = false;

  static bool _isSuperAdminLevel(String raw) =>
      raw.trim().toUpperCase() == 'SUPERADMIN';

  Future<void> _verifySuperAdminAccess() async {
    await refreshPref();
    if (!mounted) return;
    if (_isSuperAdminLevel(level)) {
      setState(() {
        _accessPending = false;
        _accessGranted = true;
      });
      _refreshUsers();
      return;
    }
    setState(() {
      _accessPending = false;
      _accessGranted = false;
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

  bool get _canSubmitSearch => _searchController.text.trim().isNotEmpty;

  /// Memanggil [getDataUser] dengan keyword dari field (hanya saat ikon search diklik).
  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _searchQuery = query;
    });
    _refreshUsers();
  }

  void _onSearchTextEdited() => setState(() {});

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchField = 'all';
    });
    _refreshUsers();
  }

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    return value.trim();
  }

  Color _statusColor(String value) {
    final status = value.toLowerCase();
    if (status.contains('active') || status.contains('aktif')) {
      return Colors.green;
    }
    if (status.contains('inactive') ||
        status.contains('nonaktif') ||
        status.contains('disable')) {
      return Colors.red;
    }
    return Colors.orange;
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              _displayValue(value),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(dynamic users, int index) {
    final statusColor = _statusColor(users.status);
    final isDark = context.isDarkMode;
    final surface = context.cardSurface;
    final LinearGradient? orangeCardGradient = isDark
        ? null
        : LinearGradient(
            colors: [
              Color.alphaBlend(
                clrOrange.withValues(alpha: 0.14),
                surface,
              ),
              Color.alphaBlend(
                clrOrange.withValues(alpha: 0.22),
                surface,
              ),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? Colors.black : null,
        gradient: orangeCardGradient,
        border: Border.all(color: context.cardBorder),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: clrOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: clrOrange,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SelectableText(
                  _displayValue(users.username),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: context.s.editUserTooltip,
                onPressed: () {
                  _openUserForm(
                    idUsers: users.idUsers,
                    username: users.username,
                    password: users.password,
                    namaUser: users.namaUser,
                    noTelp: users.noTelp,
                    idTU: users.idTU,
                    level: users.level,
                    superiorId: users.superiorId,
                    namaSuperior: users.namaSuperior,
                  );
                },
                icon: const Icon(Icons.edit_document),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetaChip(
                icon: Icons.verified_user_outlined,
                label: context.s.levelChip(_displayValue(users.level)),
                color: Colors.orange.shade800,
              ),
              _buildMetaChip(
                icon: Icons.flag_outlined,
                label: _displayValue(users.status),
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildLineItem(context.s.fieldName, users.namaUser),
          _buildLineItem(context.s.fieldPhone, users.noTelp),
          _buildLineItem(context.s.fieldSuperior, users.namaSuperior),
        ],
      ),
    );
  }

  Future<void> _fetchUsersPage({
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
        viewKeyword: _searchQuery,
        viewSearchField: _searchField,
      ),
    );
  }

  void _restoreScrollOffset(double offset) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(offset.clamp(0.0, max));
    });
  }

  Future<void> _refreshUsers({bool preserveScroll = false}) async {
    if (!mounted) return;
    final scrollOffset = preserveScroll && _scrollController.hasClients
        ? _scrollController.offset
        : null;
    setState(() => _currentPage = 1);
    try {
      await _fetchUsersPage(page: 1, append: false);
    } catch (_) {
      // Error already dispatched to Redux store.
    }
    if (scrollOffset != null && mounted) {
      _restoreScrollOffset(scrollOffset);
    }
  }

  Future<void> _openUserForm({
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
      await _refreshUsers(preserveScroll: true);
    }
  }

  Future<void> _loadMoreUsers() async {
    if (store.state.userState.isLoadingMore || !store.state.userState.hasMore) {
      return;
    }
    final nextPage = _currentPage + 1;
    try {
      await _fetchUsersPage(page: nextPage, append: true);
      if (mounted) setState(() => _currentPage = nextPage);
    } catch (_) {
      // Error already dispatched to Redux store.
    }
  }

  String _userLoadSummary(UserState state) {
    final n = state.users.length;
    final t = state.totalUsers;
    if (t != null) return context.s.usersLoadedSummary(n, t);
    return context.s.usersLoadedCount(n);
  }

  @override
  void initState() {
    super.initState();
    _verifySuperAdminAccess();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    final s = context.s;
    final fieldLabels = s.userSearchFieldLabels;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _onSearchTextEdited(),
              onSubmitted: _canSubmitSearch ? (_) => _submitSearch() : null,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: s.searchUserHint,
                hintStyle: TextStyle(color: context.iconMuted),
                prefixIcon: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: _canSubmitSearch ? clrOrange : context.iconMuted,
                  ),
                  tooltip: s.search,
                  onPressed: _canSubmitSearch ? _submitSearch : null,
                ),
                filled: true,
                fillColor: context.searchAccentFill,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.searchAccentBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.searchAccentBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: clrOrange, width: 1.4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: context.searchAccentFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.searchAccentBorder),
            ),
            child: DropdownButton<String>(
              value: _searchField,
              underline: const SizedBox.shrink(),
              iconEnabledColor: clrOrange,
              borderRadius: BorderRadius.circular(12),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
              items: fieldLabels.entries
                  .map(
                    (entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _searchField = value;
                });
                _refreshUsers();
              },
            ),
          ),
          if (_searchController.text.trim().isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: IconButton(
                onPressed: _clearSearch,
                icon: Icon(Icons.close_rounded, color: Colors.red.shade400),
                tooltip: s.clearSearch,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchNotFoundContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 52, color: context.iconMuted),
            const SizedBox(height: 12),
            Text(
              context.s.searchNotFound(_searchQuery),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_accessPending) {
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
    if (!_accessGranted) {
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
        key: _scaffoldKey,
        backgroundColor: context.pageBackground,
        drawer: DrawerMenu(title: name),
        body: RefreshIndicator(
          onRefresh: _refreshUsers,
          child: CustomScrollView(
            key: const PageStorageKey<String>('user_data_scroll'),
            controller: _scrollController,
            slivers: [
              SliverAppbars(
                title: titleDataUser,
                onPressTailing: () {
                  _openUserForm(
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
                onPressLeading: () => _scaffoldKey.currentState?.openDrawer(),
                iconTailing: Icon(Icons.add),
                iconLeading: Icon(Icons.menu),
              ),
              StoreConnector<AppState, UserState>(
                converter: (store) => store.state.userState,
                builder: (context, state) {
                  final hasMoreUsers = state.hasMore;
                  // 1. Tampilan saat Loading
                  if (state.isLoading && state.users.isEmpty) {
                    return ShimmerListSliver(
                      itemCount: 6,
                      itemBuilder: (context, index) =>
                          UserRowSkeleton(key: ValueKey('user_load_$index')),
                    );
                  }
                  // 2. Tampilan saat Error
                  if (state.error != null) {
                    return SliverFillRemaiings(
                      errors: state.error ?? '${state.error}',
                      hasScrollBodys: false,
                    );
                  }
                  // 3. Pencarian API: kosong dengan keyword → tidak ada hasil
                  if (state.users.isEmpty && _searchQuery.isNotEmpty) {
                    return SliverMainAxisGroup(
                      slivers: [
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _PinnedSearchHeaderDelegate(
                            backgroundColor: context.pageBackground,
                            child: _buildSearchBar(),
                          ),
                        ),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildSearchNotFoundContent(),
                        ),
                      ],
                    );
                  }
                  // 4. Data benar-benar kosong (tanpa filter)
                  if (state.users.isEmpty) {
                    return SliverFillRemaiings(
                      errors: state.error ?? context.s.noRecordDataFound,
                      hasScrollBodys: false,
                    );
                  }
                  return SliverMainAxisGroup(
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _PinnedSearchHeaderDelegate(
                          backgroundColor: context.pageBackground,
                          child: _buildSearchBar(),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final users = state.users[index];
                          return KeyedSubtree(
                            key: ValueKey<String>(
                              'user_${users.idUsers.trim()}',
                            ),
                            child: _buildUserCard(users, index),
                          );
                        }, childCount: state.users.length),
                      ),
                      if (state.totalUsers != null &&
                          !hasMoreUsers &&
                          state.users.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                            child: Text(
                              _userLoadSummary(state),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: context.textSecondary),
                            ),
                          ),
                        ),
                      if (hasMoreUsers)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                            child: Column(
                              children: [
                                Text(
                                  _userLoadSummary(state),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: context.textSecondary),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: state.isLoadingMore
                                        ? null
                                        : _loadMoreUsers,
                                    icon: state.isLoadingMore
                                        ? SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.orange.shade800,
                                            ),
                                          )
                                        : const Icon(Icons.expand_more),
                                    label: Text(
                                      state.isLoadingMore
                                          ? context.s.loading
                                          : context.s.loadMoreUsers(
                                              kUserPageSize,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinnedSearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedSearchHeaderDelegate({
    required this.child,
    required this.backgroundColor,
  });

  final Widget child;
  final Color backgroundColor;

  @override
  double get minExtent => 68;

  @override
  double get maxExtent => 68;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedSearchHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
