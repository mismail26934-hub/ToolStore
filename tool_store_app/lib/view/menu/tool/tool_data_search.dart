import 'package:flutter/material.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/var/var.dart';
import 'package:tool_store_app/l10n/app_strings.dart';
import 'package:tool_store_app/l10n/l10n_ext.dart';
import 'package:tool_store_app/view/custom/tool_form_search_popup.dart'
    show kToolFormSearchFieldKeys;

Widget buildToolDataSearchBar({
  required BuildContext context,
  required TextEditingController searchController,
  required String searchField,
  required bool canSubmitSearch,
  required VoidCallback onSubmitSearch,
  required VoidCallback onSearchTextEdited,
  required ValueChanged<String> onSearchFieldChanged,
  required VoidCallback onClearSearch,
  required String clearSearchTooltip,
}) {
  final s = context.s;
  final fieldLabels = s.searchFieldLabels;
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            onChanged: (_) => onSearchTextEdited(),
            onSubmitted: canSubmitSearch ? (_) => onSubmitSearch() : null,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: s.searchFormHint,
              hintStyle: TextStyle(color: context.iconMuted),
              prefixIcon: IconButton(
                icon: Icon(
                  Icons.search,
                  color: canSubmitSearch ? clrOrange : context.iconMuted,
                ),
                tooltip: s.search,
                onPressed: canSubmitSearch ? onSubmitSearch : null,
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
            value: searchField,
            underline: const SizedBox.shrink(),
            iconEnabledColor: clrOrange,
            borderRadius: BorderRadius.circular(12),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.orange.shade900,
              fontWeight: FontWeight.w600,
            ),
            items: kToolFormSearchFieldKeys
                .map(
                  (key) => DropdownMenuItem<String>(
                    value: key,
                    child: Text(fieldLabels[key] ?? key),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              onSearchFieldChanged(value);
            },
          ),
        ),
        if (searchController.text.trim().isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: IconButton(
              onPressed: onClearSearch,
              icon: Icon(Icons.close_rounded, color: Colors.red.shade400),
              tooltip: clearSearchTooltip,
            ),
          ),
      ],
    ),
  );
}

Widget buildToolDataSearchNotFoundContent({
  required BuildContext context,
  required String searchQuery,
  required bool hasMilestoneFilters,
}) {
  final s = AppStrings.current;
  final message = searchQuery.isEmpty && hasMilestoneFilters
      ? s.noFormsMilestoneFilter
      : searchQuery.isEmpty
      ? s.searchNotFoundSuffix
      : s.searchNotFound(searchQuery);
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 52,
            color: clrOrange.withValues(alpha: 0.75),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.orange.shade800),
          ),
        ],
      ),
    ),
  );
}
