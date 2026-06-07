import 'package:flutter/material.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/shimmer/tool_detail_shimmers.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/custom/navbar/pinned_search_header.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_fill_remaining.dart';
import 'package:tool_store_app/debug/agent_log.dart';
import 'tool_data_state_base.dart';

mixin ToolDataListMixin on ToolDataStateBase {
  Widget buildToolDataFormsListSliver(FormsState state) {
    final filteredForms = state.forms.where(matchesMilestoneFilter).toList();
    final hasMoreForms = state.hasMore;
    // #region agent log
    if (!state.isLoadingTool) {
      String listBranch = 'list';
      if (state.error != null) {
        listBranch = 'error';
      } else if (state.forms.isEmpty && searchQuery.isNotEmpty) {
        listBranch = 'searchEmpty';
      } else if (state.forms.isEmpty) {
        listBranch = 'apiEmpty';
      } else if (filteredForms.isEmpty) {
        listBranch = 'filterEmpty';
      }
      agentDebugLog(
        hypothesisId: listBranch == 'filterEmpty' ? 'B' : 'A',
        location: 'tool_data.dart:listBuilder',
        message: 'list render branch',
        data: {
          'branch': listBranch,
          'formsCount': state.forms.length,
          'filteredCount': filteredForms.length,
          'searchQuery': searchQuery,
          'hasMilestoneFilters': hasMilestoneFilters,
          'milestoneFiltersNorms': milestoneFiltersNorms.toList(),
          'filterBlank': widget.filterBlankFormMilestone,
          'excludeFilters': widget.excludeFormMilestoneFilters,
        },
      );
    }
    // #endregion
    if (state.isLoadingTool && state.forms.isEmpty) {
      return const FormCardListLoadingSliver();
    }
    if (state.error != null) {
      return SliverFillRemaiings(
        errors: state.error ?? '${state.error}',
        hasScrollBodys: false,
      );
    }
    if (state.forms.isEmpty && searchQuery.isNotEmpty) {
      return SliverMainAxisGroup(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: PinnedSearchHeaderDelegate(
              backgroundColor: context.pageBackground,
              child: buildSearchBar(),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: buildSearchNotFoundContent(),
          ),
        ],
      );
    }
    if (state.forms.isEmpty) {
      return SliverFillRemaiings(
        errors: state.error ?? "No Record Data Found",
        hasScrollBodys: false,
      );
    }
    if (filteredForms.isEmpty) {
      return SliverMainAxisGroup(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: PinnedSearchHeaderDelegate(
              backgroundColor: context.pageBackground,
              child: buildSearchBar(),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: buildSearchNotFoundContent(),
          ),
        ],
      );
    }
    return SliverMainAxisGroup(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: PinnedSearchHeaderDelegate(
            backgroundColor: context.pageBackground,
            child: buildSearchBar(),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final forms = filteredForms[index];
            return buildFormCard(forms, index);
          }, childCount: filteredForms.length),
        ),
        if (state.totalForms != null &&
            !hasMoreForms &&
            filteredForms.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Text(
                formLoadSummary(state, filteredForms.length),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: context.textSecondary),
              ),
            ),
          ),
        if (hasMoreForms)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                children: [
                  Text(
                    formLoadSummary(state, filteredForms.length),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: state.isLoadingMore ? null : loadMoreForms,
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
                            ? strings.loading
                            : strings.loadMoreUsers(kToolFormPageSize),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
