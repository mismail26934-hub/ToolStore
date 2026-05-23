import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/controller/function/funct.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/form/text_form_field.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/custom/show_dialog/show_dialog.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/custom/shimmer/app_shimmer.dart';
import 'package:tool_store_app/view/custom/shimmer/skeletons.dart';
import 'package:tool_store_app/l10n/app_strings.dart';
import 'package:tool_store_app/l10n/l10n_ext.dart';
import 'package:tool_store_app/view/var/var.dart';

String _userPickLabel(PostList u) {
  final n = u.namaUser.trim();
  if (n.isNotEmpty) return n;
  final un = u.username.trim();
  if (un.isNotEmpty) return un;
  return u.idUsers.trim();
}

List<PostList> _dedupeUsersById(List<PostList> list) {
  final seen = <String>{};
  final out = <PostList>[];
  for (final u in list) {
    final id = u.idUsers.trim();
    if (id.isEmpty) continue;
    if (seen.contains(id)) continue;
    seen.add(id);
    out.add(u);
  }
  return out;
}

List<PostList> _filterUserPickerRows(List<PostList> list, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return list;
  return list.where((u) {
    return u.namaUser.toLowerCase().contains(q) ||
        u.username.toLowerCase().contains(q) ||
        u.idUsers.toLowerCase().contains(q);
  }).toList();
}

List<PostList> _applyUserPickerFieldFilter(
  List<PostList> list,
  String searchField,
  String query,
) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return list;
  switch (searchField) {
    case 'username':
      return list.where((u) => u.username.toLowerCase().contains(q)).toList();
    case 'name':
      return list.where((u) => u.namaUser.toLowerCase().contains(q)).toList();
    case 'phone':
      return list.where((u) => u.noTelp.toLowerCase().contains(q)).toList();
    case 'level':
      return list.where((u) => u.level.toLowerCase().contains(q)).toList();
    case 'status':
      return list.where((u) => u.status.toLowerCase().contains(q)).toList();
    default:
      return _filterUserPickerRows(list, query);
  }
}

List<PostList> _sortUsersForPicker(List<PostList> list) {
  final sorted = List<PostList>.from(list)
    ..sort(
      (a, b) => _userPickLabel(
        a,
      ).toLowerCase().compareTo(_userPickLabel(b).toLowerCase()),
    );
  return sorted;
}

List<PostList> _mergePickerUsers(List<PostList> existing, List<PostList> incoming) {
  if (incoming.isEmpty) return existing;
  final ids = existing.map((u) => u.idUsers.trim()).toSet();
  final merged = List<PostList>.from(existing);
  for (final user in incoming) {
    final id = user.idUsers.trim();
    if (id.isEmpty || ids.contains(id)) continue;
    merged.add(user);
    ids.add(id);
  }
  return merged;
}

List<PostList> _filterUsersByLevel(List<PostList> list, String level) {
  final target = level.trim().toUpperCase();
  if (target.isEmpty) return list;
  return list
      .where((u) => u.level.trim().toUpperCase() == target)
      .toList();
}

bool _currentFormHasToolListItems(AppState state) {
  final idForm = idFormCont.text.trim();
  if (idForm.isEmpty) return false;
  return state.formsDetailState.formsDetail.any(
    (item) => item.idForm.trim() == idForm,
  );
}

class _ToolUserPickerDialog extends StatefulWidget {
  const _ToolUserPickerDialog({
    required this.userLevel,
    required this.initialUsers,
    required this.title,
    required this.onSelected,
  });

  final String userLevel;
  final List<PostList> initialUsers;
  final String title;
  final ValueChanged<PostList> onSelected;

  @override
  State<_ToolUserPickerDialog> createState() => _ToolUserPickerDialogState();
}

class _ToolUserPickerDialogState extends State<_ToolUserPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _searchField = 'all';
  List<PostList> _users = [];
  int _currentPage = 1;
  int? _totalUsers;
  bool _hasMore = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  bool get _canSubmitSearch => _searchController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _users = _sortUsersForPicker(
      _filterUsersByLevel(_dedupeUsersById(widget.initialUsers), widget.userLevel),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchUsers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers({bool append = false}) async {
    if (!mounted) return;
    if (append) {
      if (_isLoadingMore || !_hasMore) return;
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
      });
    }
    final page = append ? _currentPage + 1 : 1;
    try {
      final parsed = await fetchUsersForPicker(
        keyword: _searchQuery,
        searchField: _searchField,
        levelFilter: widget.userLevel,
        page: page,
        limit: kUserPageSize,
      );
      var list = parsed.items;
      if (_searchQuery.isNotEmpty && _searchField != 'all') {
        list = _applyUserPickerFieldFilter(list, _searchField, _searchQuery);
      }
      final merged = append
          ? _mergePickerUsers(_users, list)
          : list;
      final deduped = _dedupeUsersById(merged);
      final total = parsed.total;
      final hasMore = total != null
          ? deduped.length < total
          : list.length >= kUserPageSize;
      if (!mounted) return;
      setState(() {
        _users = _sortUsersForPicker(deduped);
        _currentPage = page;
        _totalUsers = total;
        _hasMore = hasMore;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreUsers() async {
    await _fetchUsers(append: true);
  }

  String _pickerLoadSummary() {
    final n = _users.length;
    final t = _totalUsers;
    if (t != null) {
      return context.s.usersLoadedSummary(n, t);
    }
    return context.s.usersLoadedCount(n);
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() => _searchQuery = query);
    _fetchUsers();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchField = 'all';
    });
    _fetchUsers();
  }

  void _onSearchTextEdited() => setState(() {});

  Widget _buildSearchBar() {
    final s = context.s;
    final fieldLabels = s.userSearchFieldLabels;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
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
              onChanged: _isLoading
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() => _searchField = value);
                      if (_searchQuery.isNotEmpty) {
                        _fetchUsers();
                      }
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
                onPressed: _isLoading ? null : _clearSearch,
                icon: Icon(Icons.close_rounded, color: Colors.red.shade400),
                tooltip: s.clearSearch,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserTile(PostList u, ThemeData theme) {
    final title = _userPickLabel(u);
    final un = u.username.trim();
    final showUserLine =
        un.isNotEmpty && un.toLowerCase() != title.toLowerCase();
    return Material(
      color: context.cardSurface,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: () => widget.onSelected(u),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.cardBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: clrOrange.withValues(alpha: 0.14),
                foregroundColor: clrOrange,
                radius: 22,
                child: Text(
                  title.isNotEmpty
                      ? title.characters.first.toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (showUserLine) ...[
                      const SizedBox(height: 2),
                      Text(
                        '@$un',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.iconMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.iconMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(ThemeData theme) {
    if (_isLoading && _users.isEmpty) {
      return Center(child: CircularProgressIndicator(color: clrOrange));
    }
    if (_error != null && _users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: clrRed),
          ),
        ),
      );
    }
    if (_users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_search_rounded,
                size: 48,
                color: context.iconMuted,
              ),
              const SizedBox(height: 12),
              Text(
                _searchQuery.isNotEmpty
                    ? context.s.searchNotFound(_searchQuery)
                    : context.s.noSearchResults,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Stack(
            children: [
              ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                itemCount: _users.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _buildUserTile(_users[i], theme),
              ),
              if (_isLoading && !_isLoadingMore)
                Positioned(
                  top: 8,
                  right: 24,
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: clrOrange,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_users.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: Column(
              children: [
                Text(
                  _pickerLoadSummary(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                if (_hasMore) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoadingMore ? null : _loadMoreUsers,
                      icon: _isLoadingMore
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
                        _isLoadingMore
                            ? context.s.loading
                            : context.s.loadMoreUsers(kUserPageSize),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = min(MediaQuery.sizeOf(context).height * 0.72, 560.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Container(
        width: min(MediaQuery.sizeOf(context).width - 40, 420),
        height: h,
        decoration: BoxDecoration(
          color: context.pageBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 8, 12),
              decoration: BoxDecoration(
                color: context.cardSurface,
                border: Border(bottom: BorderSide(color: context.cardBorder)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: clrOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.person_search_rounded,
                      color: clrOrange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.s.searchThenTapName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: context.chipNeutralBg,
                      foregroundColor: context.chipNeutralFg,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 22),
                  ),
                ],
              ),
            ),
            _buildSearchBar(),
            Expanded(child: _buildResults(theme)),
          ],
        ),
      ),
    );
  }
}

class ToolFormInput extends StatefulWidget {
  const ToolFormInput({super.key, required this.subtitle});
  final String subtitle;

  @override
  State<ToolFormInput> createState() => ToolFormInputState();
}

class ToolFormInputState extends State<ToolFormInput> {
  bool get _isEditMode => idFormCont.text.isNotEmpty;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final st = store.state.userState;
      if (!st.isLoading) {
        store.dispatch(
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
            limit: kUserFullFetchLimit,
          ),
        );
      }
      if (idFormCont.text.trim().isNotEmpty &&
          !store.state.formsDetailState.isLoadingToolDetail) {
        store.dispatch(
          getDataToolDetail(
            param: paramViewDataTool,
            idFormDetail: '',
            idFrom: '',
            formComment: '',
            pnGroup: '',
            pnDesc: '',
            qty: '',
            explan: '',
            actionNote: '',
            valType: '',
            partValue: '',
            formDetailDate: '',
            formDetailUser: '',
          ),
        );
      }
    });
  }

  Future<bool> _submitFormData(String param) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    try {
      final responseList = await store.dispatch(
        getDataTool(
          param: param,
          idForm: idFormCont.text,
          formNo: formNoCont.text,
          formServName: servNameCont.text,
          formCheckBy: checkedByCont.text,
          formDateCheckBy: dateCheckByCont.text,
          formDateServName: dateServNameCont.text,
          formServComment: servCommentCont.text,
          formSuperiorAprd: superiorAprdCont.text,
          formSuperiorComment: superiorCommentCont.text,
          formSadminComment: sadminCommentCont.text,
          formMilestone: milestoneCont.text,
          formStatusOrder: statusOrderCont.text,
          formSheadAprd: sheadAprdCont.text,
          formSheadComment: sheadCommentCont.text,
          fromDateUpdate: dateUpdateCont.text,
          formUserUpdate: userUpdateCont.text,
        ),
      );

      final apiResponse = responseList is List && responseList.isNotEmpty
          ? responseList.last
          : null;
      final String responseValue = apiResponse?.valueResponse.toString() ?? "";
      final String responseMessage =
          apiResponse?.messageResponse.toString() ?? "";
      final bool isSuccess = responseValue == "1";

      if (isSuccess) {
        await store.dispatch(
          getDataTool(
            param: paramViewDataForm,
            idForm: '',
            formNo: '',
            formServName: '',
            formCheckBy: '',
            formDateCheckBy: '',
            formDateServName: '',
            formServComment: '',
            formSuperiorAprd: '',
            formSuperiorComment: '',
            formSadminComment: '',
            formMilestone: '',
            formStatusOrder: '',
            formSheadAprd: '',
            formSheadComment: '',
            fromDateUpdate: '',
            formUserUpdate: '',
          ),
        );
      }

      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: isSuccess ? Colors.green : Colors.red,
          content: Text(
            responseMessage.isNotEmpty
                ? responseMessage
                : (isSuccess ? AppStrings.current.success : AppStrings.current.failedProcessData),
          ),
        ),
      );

      return isSuccess;
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(AppStrings.current.failedProcessData),
        ),
      );
      return false;
    } finally {
      _isSubmitting = false;
    }
  }

  InputDecoration _dropdownDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: Theme.of(context).textTheme.labelMedium,
      filled: true,
      fillColor: context.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: clrOrange, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Future<void> _openToolUserPicker({
    required String userLevel,
    required List<PostList> initialUsers,
    required TextEditingController targetCont,
    required String dialogTitle,
    VoidCallback? onPicked,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => _ToolUserPickerDialog(
        userLevel: userLevel,
        initialUsers: initialUsers,
        title: dialogTitle,
        onSelected: (u) {
          Navigator.pop(ctx);
          if (!mounted) return;
          setState(() {
            targetCont.text = _userPickLabel(u);
            onPicked?.call();
          });
        },
      ),
    );
  }

  Widget _buildToolUserPickerField({
    required BuildContext context,
    required String userLevel,
    required List<PostList> users,
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required String dialogTitle,
  }) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final hasValue = controller.text.trim().isNotEmpty;
        return FormField<String>(
          validator: (_) {
            if (controller.text.trim().isEmpty) {
              return AppStrings.current.required;
            }
            return null;
          },
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openToolUserPicker(
                      userLevel: userLevel,
                      initialUsers: users,
                      targetCont: controller,
                      dialogTitle: dialogTitle,
                      onPicked: () => field.didChange(
                        controller.text.trim().isNotEmpty
                            ? controller.text
                            : null,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: _dropdownDecoration(context, label).copyWith(
                        errorText: field.errorText,
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasValue)
                              IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  size: 22,
                                ),
                                onPressed: () => setState(() {
                                  controller.clear();
                                  field.didChange(null);
                                }),
                                tooltip: context.s.remove,
                              ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.manage_search_rounded,
                                color: clrOrange,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: Text(
                        hasValue ? controller.text : placeholder,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: hasValue ? null : context.iconMuted,
                          fontWeight: hasValue
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: clrOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: clrOrange),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        SizedBox(
          height: 48,
          width: 48,
          child: OutlinedButton(
            onPressed: () => selectDate(context, controller, () {}),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              side: BorderSide(color: context.cardBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Icon(Icons.date_range, color: clrOrange, size: 20),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormFields(
            labelTexts: label,
            textColor: Colors.black,
            controllers: controller,
            validators: (value) {
              if (value == null || value.isEmpty) {
                return context.s.requiredField;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Future<void> _returnToToolList(BuildContext context) async {
    final formId = idFormCont.text.trim();
    final formNo = formNoCont.text.trim();
    if (Navigator.canPop(context)) {
      Navigator.pop(context, formId);
      return;
    }
    await PageRoutes.routeTool(
      context,
      initialExpandedFormId: formId.isNotEmpty ? formId : null,
      initialSearchQuery: formNo.isNotEmpty ? formNo : null,
      initialSearchField: 'formNo',
    );
  }

  void _showDeleteDialog() {
    ShowDialogBox.show(
      context: context,
      title: AppStrings.current.deleteFormTitle(formNoCont.text),
      contentTitle: AppStrings.current.confirmDeleteThisData,
      onPressedNo: (dialogContext) {
        if (!dialogContext.mounted) return;
        Navigator.pop(dialogContext);
      },
      onPressedYes: (dialogContext) async {
        if (dialogContext.mounted) Navigator.pop(dialogContext);
        if (!mounted) return;
        final isSuccess = await _submitFormData(paramDeleteDataForm);
        if (!mounted || !isSuccess) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
          return;
        }
        await PageRoutes.routeTool(context);
      },
      textNo: AppStrings.current.cancel,
      textYes: AppStrings.current.yes,
      textColorNo: clrBlack,
      textColorYes: clrOrange,
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusOrderOptions = [
      context.s.statusHolder,
      context.s.statusNonHolder,
    ];
    final selectedStatusOrder =
        statusOrderOptions.contains(statusOrderCont.text)
        ? statusOrderCont.text
        : null;
    final categoryOptions = statusOrderCont.text == context.s.statusHolder
        ? [
            context.s.categoryMissing,
            context.s.categoryDamage,
            context.s.categoryAdditional,
          ]
        : [context.s.categoryBudget, context.s.categoryNonBudget];
    final selectedCategory = categoryOptions.contains(servCommentCont.text)
        ? servCommentCont.text
        : null;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: context.appBarSurface,
        foregroundColor: clrOrange,
        toolbarHeight: 84,
        titleSpacing: 18,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: clrOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: clrOrange.withValues(alpha: 0.2)),
            ),
            child: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              color: clrOrange,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode ? context.s.editDataTool : context.s.addDataTool,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: clrOrange,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              formNoCont.text.isEmpty
                  ? context.s.toolRequestForm
                  : formNoCont.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: clrOrange.withValues(alpha: 0.75),
                letterSpacing: 0.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                clrOrange.withValues(alpha: 0.14),
                clrOrange.withValues(alpha: 0.05),
                clrOrange.withValues(alpha: 0.14),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
            border: Border(
              bottom: BorderSide(color: context.cardBorder, width: 1),
            ),
          ),
        ),
        actions: [
          if (_isEditMode)
            StoreConnector<AppState, bool>(
              converter: (store) => _currentFormHasToolListItems(store.state),
              builder: (context, hasToolListData) {
                final canDelete = !hasToolListData;
                return Padding(
                  padding: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
                  child: Opacity(
                    opacity: canDelete ? 1 : 0.45,
                    child: Container(
                      decoration: BoxDecoration(
                        color: canDelete
                            ? clrOrange
                            : clrOrange.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: clrOrange.withValues(alpha: 0.05),
                        ),
                        boxShadow: canDelete
                            ? [
                                BoxShadow(
                                  color: clrOrange.withValues(alpha: 0.22),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: IconButton(
                        tooltip: canDelete
                            ? context.s.deleteDataTooltip
                            : context.s.cannotDeleteToolListHasData,
                        onPressed: canDelete ? _showDeleteDialog : null,
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: clrWhite,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: context.cardBorder,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                _buildSectionCard(
                  context: context,
                  title: context.s.requestInformationSection,
                  icon: Icons.description_outlined,
                  children: [
                    TextFormFields(
                      labelTexts: context.s.formNumber,
                      textColor: Colors.black,
                      controllers: formNoCont,
                      validators: (formNumber) {
                        if (formNumber == null || formNumber.isEmpty) {
                          return context.s.requiredField;
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 5.0,
                        right: 5.0,
                        top: 5.0,
                        bottom: 5.0,
                      ),
                      child: DropdownButtonFormField<String>(
                        style: Theme.of(context).textTheme.labelMedium,
                        initialValue: selectedStatusOrder,
                        items: statusOrderOptions
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() {
                          statusOrderCont.text = val.toString();
                          servCommentCont.clear();
                        }),
                        decoration: _dropdownDecoration(
                          context,
                          context.s.statusOrder,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.s.pleaseSelect;
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 5.0,
                        right: 5.0,
                        top: 5.0,
                        bottom: 5.0,
                      ),
                      child: DropdownButtonFormField<String>(
                        style: Theme.of(context).textTheme.labelMedium,
                        initialValue: selectedCategory,
                        items: categoryOptions
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: statusOrderCont.text.isEmpty
                            ? null
                            : (val) => setState(
                                () => servCommentCont.text = val.toString(),
                              ),
                        decoration: _dropdownDecoration(
                          context,
                          context.s.searchFieldCategory,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.s.pleaseSelect;
                          }
                          return null;
                        },
                      ),
                    ),
                    _buildDateField(
                      context: context,
                      label: context.s.createDate,
                      controller: dateServNameCont,
                    ),
                    StoreConnector<AppState, UserState>(
                      converter: (store) => store.state.userState,
                      builder: (context, userState) {
                        final users = List<PostList>.from(
                          _dedupeUsersById(userState.users),
                        )..sort(
                            (a, b) => _userPickLabel(
                              a,
                            ).toLowerCase().compareTo(
                              _userPickLabel(b).toLowerCase(),
                            ),
                          );
                        final mechanicUsers = List<PostList>.from(
                          _filterUsersByLevel(users, 'MECHANIC'),
                        );
                        final toolKeeperUsers = List<PostList>.from(
                          _filterUsersByLevel(users, 'TOOL_KEEPER'),
                        );
                        if (userState.isLoading && users.isEmpty) {
                          return const AppShimmer(
                            child: Column(
                              children: [
                                FieldSkeleton(),
                                FieldSkeleton(),
                              ],
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 5.0,
                                right: 5.0,
                                top: 5.0,
                                bottom: 5.0,
                              ),
                              child: _buildToolUserPickerField(
                                context: context,
                                userLevel: 'MECHANIC',
                                users: mechanicUsers,
                                controller: servNameCont,
                                label: context.s.searchFieldServiceman,
                                placeholder: context.s.tapToPickServiceman,
                                dialogTitle: context.s.pickServicemanTitle,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 5.0,
                                right: 5.0,
                                top: 5.0,
                                bottom: 5.0,
                              ),
                              child: _buildToolUserPickerField(
                                context: context,
                                userLevel: 'TOOL_KEEPER',
                                users: toolKeeperUsers,
                                controller: checkedByCont,
                                label: context.s.checkBy,
                                placeholder: context.s.tapToPickCheckBy,
                                dialogTitle: context.s.pickCheckByTitle,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    _buildDateField(
                      context: context,
                      label: context.s.checkDate,
                      controller: dateCheckByCont,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(paddingForm),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      elevation: 2,
                      shadowColor: clrBlack.withValues(alpha: 0.18),
                      backgroundColor: _isEditMode ? clrOrange : clrBtnPrimary,
                      foregroundColor: clrBtnPrimaryFgBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      ShowDialogBox.show(
                        context: context,
                        title: context.s.confirmDataCorrectTitle,
                        contentTitle: _isEditMode
                            ? context.s.confirmEditData
                            : context.s.confirmSaveData,
                        onPressedNo: (dialogContext) {
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                        },
                        onPressedYes: (dialogContext) async {
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                          if (!mounted) return;
                          if (formKey.currentState!.validate()) {
                            final actionParam = _isEditMode
                                ? paramEditDataForm
                                : paramAddDataForm;
                            final isSuccess = await _submitFormData(
                              actionParam,
                            );
                            if (!mounted || !isSuccess) return;
                            if (!context.mounted) return;
                            await _returnToToolList(context);
                          }
                        },
                        textNo: context.s.cancel,
                        textYes: context.s.yes,
                        textColorNo: clrBlack,
                        textColorYes: clrOrange,
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isEditMode ? Icons.save : Icons.save_outlined,
                          size: btnFontSize + 4,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isEditMode ? context.s.updateData : context.s.saveData,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: btnFontSize,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
