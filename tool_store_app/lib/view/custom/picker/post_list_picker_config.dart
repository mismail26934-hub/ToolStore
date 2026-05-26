import 'package:flutter/material.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';

/// One page of picker search results.
class PostListPickerPage {
  const PostListPickerPage({required this.items, this.total});

  final List<PostList> items;
  final int? total;
}

typedef PostListPickerFetch = Future<PostListPickerPage> Function({
  required String keyword,
  required String searchField,
  required int page,
  required int limit,
});

/// Configuration for [PostListPickerDialog] (superior vs user-by-level).
class PostListPickerConfig {
  const PostListPickerConfig({
    required this.title,
    required this.headerIcon,
    required this.searchFieldLabels,
    required this.searchHint,
    required this.emptyMessage,
    required this.loadedSummary,
    required this.loadedCount,
    required this.prepareInitial,
    required this.dedupe,
    required this.sort,
    required this.merge,
    required this.applyFieldFilter,
    required this.fetchPage,
    required this.tileTitle,
    this.tileSubtitle,
    this.tileUsernameLine,
  });

  final String title;
  final IconData headerIcon;
  final Map<String, String> searchFieldLabels;
  final String searchHint;
  final String Function(BuildContext context, String searchQuery) emptyMessage;
  final String Function(int loaded, int total) loadedSummary;
  final String Function(int loaded) loadedCount;
  final List<PostList> Function(List<PostList> initial) prepareInitial;
  final List<PostList> Function(List<PostList> list) dedupe;
  final List<PostList> Function(List<PostList> list) sort;
  final List<PostList> Function(List<PostList> existing, List<PostList> incoming)
  merge;
  final List<PostList> Function(
    List<PostList> list,
    String searchField,
    String query,
  )
  applyFieldFilter;
  final PostListPickerFetch fetchPage;
  final String Function(PostList item) tileTitle;
  final String? Function(PostList item)? tileSubtitle;
  final String? Function(PostList item)? tileUsernameLine;
}
