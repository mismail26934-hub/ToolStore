import 'package:flutter/material.dart';
import 'package:tool_store_app/l10n/l10n_ext.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/picker/post_list_picker_config.dart';
import 'package:tool_store_app/view/custom/picker/post_list_picker_utils.dart';

/// Built-in picker configs for superior and tool-form user fields.
abstract final class PostListPickerPresets {
  PostListPickerPresets._();

  static PostListPickerConfig superior(BuildContext context) {
    final s = context.s;
    return PostListPickerConfig(
      title: s.pickSuperiorTitle,
      headerIcon: Icons.supervisor_account_outlined,
      searchFieldLabels: s.superiorSearchFieldLabels,
      searchHint: s.searchNameOrUsernameHint,
      emptyMessage: (ctx, query) => query.isNotEmpty
          ? ctx.s.searchNotFound(query)
          : ctx.s.noSuperiorData,
      loadedSummary: (n, t) => s.superiorsLoadedSummary(n, t),
      loadedCount: (n) => s.superiorsLoadedCount(n),
      prepareInitial: (initial) =>
          sortSuperiorsForPicker(dedupeSuperiorRows(initial)),
      dedupe: dedupeSuperiorRows,
      sort: sortSuperiorsForPicker,
      merge: mergePickerSuperiors,
      applyFieldFilter: applySuperiorPickerFieldFilter,
      fetchPage: ({
        required keyword,
        required searchField,
        required page,
        required limit,
      }) async {
        final parsed = await fetchSuperiorsForPicker(
          keyword: keyword,
          searchField: searchField,
          page: page,
          limit: limit,
        );
        return PostListPickerPage(items: parsed.items, total: parsed.total);
      },
      tileTitle: superiorPickerTitle,
      tileSubtitle: superiorPickerSubtitle,
      tileUsernameLine: superiorPickerUsernameLine,
    );
  }

  static PostListPickerConfig toolUser(
    BuildContext context, {
    required String title,
    required String levelFilter,
  }) {
    final s = context.s;
    final level = levelFilter.trim();
    return PostListPickerConfig(
      title: title,
      headerIcon: Icons.person_search_rounded,
      searchFieldLabels: s.userSearchFieldLabels,
      searchHint: s.searchUserHint,
      emptyMessage: (ctx, query) => query.isNotEmpty
          ? ctx.s.searchNotFound(query)
          : ctx.s.noSearchResults,
      loadedSummary: (n, t) => s.usersLoadedSummary(n, t),
      loadedCount: (n) => s.usersLoadedCount(n),
      prepareInitial: (initial) => sortUsersForPicker(
        dedupeUsersById(filterUsersByLevel(initial, level)),
      ),
      dedupe: dedupeUsersById,
      sort: sortUsersForPicker,
      merge: mergePickerUsers,
      applyFieldFilter: applyUserPickerFieldFilter,
      fetchPage: ({
        required keyword,
        required searchField,
        required page,
        required limit,
      }) async {
        final parsed = await fetchUsersForPicker(
          keyword: keyword,
          searchField: searchField,
          levelFilter: level,
          page: page,
          limit: limit,
        );
        return PostListPickerPage(items: parsed.items, total: parsed.total);
      },
      tileTitle: userPickerTitle,
      tileUsernameLine: (u) =>
          userPickerShowUsernameLine(u) ? userPickerUsernameLine(u) : null,
    );
  }
}
