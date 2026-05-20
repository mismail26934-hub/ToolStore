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
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/theme/theme_controller.dart';
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
        const SnackBar(
          content: Text(
            'Akses ditolak. Menu User hanya untuk SUPERADMIN. '
            'Sesi diakhiri — silakan login kembali.',
          ),
        ),
      );
      final prefs = await SharedPreferences.getInstance();
      await ThemeController.preserveOnPrefsClear(prefs);
      if (!mounted) return;
      await PageRoutes.routeLoginFast(context);
    });
  }

  static const Map<String, String> _searchFieldLabels = {
    'all': 'Semua',
    'username': 'Username',
    'name': 'Name',
    'phone': 'No.Telp',
    'level': 'Level',
    'status': 'Status',
  };

  /// Memanggil [getDataUser] dengan keyword dari field (hanya saat ikon search diklik).
  void _submitSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim();
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            context.cardSurface,
            statusColor.withValues(alpha: context.isDarkMode ? 0.12 : 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                tooltip: 'Edit user',
                onPressed: () {
                  postContUser(
                    users.idUsers,
                    users.username,
                    users.password,
                    users.namaUser,
                    users.noTelp,
                    users.idTU,
                    users.level,
                    users.superiorId,
                    users.namaSuperior,
                    context,
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
                label: 'Level ${_displayValue(users.level)}',
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
          _buildLineItem('Name', users.namaUser),
          _buildLineItem('No.Telp', users.noTelp),
          _buildLineItem('Superior', users.namaSuperior),
        ],
      ),
    );
  }

  Future<void> _fetchUsersPage({required int page, required bool append}) async {
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

  Future<void> _refreshUsers() async {
    if (!mounted) return;
    setState(() => _currentPage = 1);
    try {
      await _fetchUsersPage(page: 1, append: false);
    } catch (_) {
      // Error already dispatched to Redux store.
    }
  }

  Future<void> _loadMoreUsers() async {
    if (store.state.userState.isLoadingMore ||
        !store.state.userState.hasMore) {
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

  @override
  void initState() {
    super.initState();
    _verifySuperAdminAccess();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _onSearchTextEdited(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari data user...',
                hintStyle: TextStyle(color: context.iconMuted),
                prefixIcon: IconButton(
                  icon: Icon(Icons.search, color: clrOrange),
                  tooltip: 'Cari',
                  onPressed: _submitSearch,
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
              items: _searchFieldLabels.entries
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
                tooltip: 'Clear search',
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
              '$_searchQuery '
              'Not Found',
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
          body: Center(child: CircularProgressIndicator(color: clrOrange)),
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
            slivers: [
              SliverAppbars(
                title: titleDataUser,
                onPressTailing: () {
                  postContUser("", "", "", "", "", "", "", "", "", context);
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
                  if (state.isLoading) {
                    return SliverFillRemaiings(
                      errors: "Loading",
                      hasScrollBodys: false,
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
                      errors: state.error ?? "No Record Data Found",
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
                          return _buildUserCard(users, index);
                        }, childCount: state.users.length),
                      ),
                      if (hasMoreUsers)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                            child: Column(
                              children: [
                                Text(
                                  '${state.users.length} user(s) loaded',
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
                                          ? 'Loading...'
                                          : 'Load $kUserPageSize more',
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
