import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/l10n/l10n_ext.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/custom/picker/post_list_picker_config.dart';
import 'package:tool_store_app/view/var/var.dart';

/// Searchable paginated dialog to pick a [PostList] row (superior or user).
class PostListPickerDialog extends StatefulWidget {
  const PostListPickerDialog({
    super.key,
    required this.config,
    required this.initialItems,
    required this.onSelected,
  });

  final PostListPickerConfig config;
  final List<PostList> initialItems;
  final ValueChanged<PostList> onSelected;

  @override
  State<PostListPickerDialog> createState() => _PostListPickerDialogState();
}

class _PostListPickerDialogState extends State<PostListPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _searchField = 'all';
  List<PostList> _items = [];
  int _currentPage = 1;
  int? _totalItems;
  bool _hasMore = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  PostListPickerConfig get _config => widget.config;

  bool get _canSubmitSearch => _searchController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _items = _config.prepareInitial(widget.initialItems);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchItems());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchItems({bool append = false}) async {
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
      final parsed = await _config.fetchPage(
        keyword: _searchQuery,
        searchField: _searchField,
        page: page,
        limit: kUserPageSize,
      );
      var list = parsed.items;
      if (_searchQuery.isNotEmpty && _searchField != 'all') {
        list = _config.applyFieldFilter(list, _searchField, _searchQuery);
      }
      final merged = append ? _config.merge(_items, list) : list;
      final deduped = _config.dedupe(merged);
      final total = parsed.total;
      final hasMore = total != null
          ? deduped.length < total
          : list.length >= kUserPageSize;
      if (!mounted) return;
      setState(() {
        _items = _config.sort(deduped);
        _currentPage = page;
        _totalItems = total;
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

  Future<void> _loadMore() async {
    await _fetchItems(append: true);
  }

  String _pickerLoadSummary() {
    final n = _items.length;
    final t = _totalItems;
    if (t != null) {
      return _config.loadedSummary(n, t);
    }
    return _config.loadedCount(n);
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() => _searchQuery = query);
    _fetchItems();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchField = 'all';
    });
    _fetchItems();
  }

  void _onSearchTextEdited() => setState(() {});

  Widget _buildSearchBar() {
    final s = context.s;
    final fieldLabels = _config.searchFieldLabels;
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
                hintText: _config.searchHint,
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
                        _fetchItems();
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

  Widget _buildTile(PostList item, ThemeData theme) {
    final title = _config.tileTitle(item);
    final sub = _config.tileSubtitle?.call(item);
    final userLine = _config.tileUsernameLine?.call(item);
    return Material(
      color: context.cardSurface,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: () => widget.onSelected(item),
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
                    if (sub != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                    if (userLine != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        userLine,
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
    if (_isLoading && _items.isEmpty) {
      return Center(child: CircularProgressIndicator(color: clrOrange));
    }
    if (_error != null && _items.isEmpty) {
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
    if (_items.isEmpty) {
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
                _config.emptyMessage(context, _searchQuery),
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
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _buildTile(_items[i], theme),
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
        if (_items.isNotEmpty)
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
                      onPressed: _isLoadingMore ? null : _loadMore,
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
                      _config.headerIcon,
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
                          _config.title,
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
