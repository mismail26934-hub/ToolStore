import 'package:flutter/material.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/navbar/pinned_search_header.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_fill_remaining.dart';
import 'package:tool_store_app/view/custom/shimmer/app_shimmer.dart';
import 'package:tool_store_app/view/custom/shimmer/skeletons.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/l10n/l10n_ext.dart';
import 'package:tool_store_app/view/menu/user/user_data_state_base.dart';

mixin UserDataListMixin on UserDataStateBase {
  Widget buildUserDataUsersListSliver(UserState state) {
    final hasMoreUsers = state.hasMore;
    if (state.isLoading && state.users.isEmpty) {
      return ShimmerListSliver(
        itemCount: 6,
        itemBuilder: (context, index) =>
            UserRowSkeleton(key: ValueKey('user_load_$index')),
      );
    }
    if (state.error != null) {
      return SliverFillRemaiings(
        errors: state.error ?? '${state.error}',
        hasScrollBodys: false,
      );
    }
    if (state.users.isEmpty && searchQuery.isNotEmpty) {
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
          delegate: PinnedSearchHeaderDelegate(
            backgroundColor: context.pageBackground,
            child: buildSearchBar(),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final users = state.users[index];
            return KeyedSubtree(
              key: ValueKey<String>('user_${users.idUsers.trim()}'),
              child: buildUserCard(users, index),
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
                userLoadSummary(state),
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
                    userLoadSummary(state),
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: context.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: state.isLoadingMore ? null : loadMoreUsers,
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
                            : context.s.loadMoreUsers(kUserPageSize),
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
