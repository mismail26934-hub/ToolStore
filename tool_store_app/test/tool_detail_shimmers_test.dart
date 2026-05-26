import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/view/custom/shimmer/detail_section_vm.dart';
import 'package:tool_store_app/view/custom/shimmer/tool_detail_shimmers.dart';

void main() {
  testWidgets('DetailSectionBody shows loading shimmer when loading and empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DetailSectionBody(
            viewModel: DetailSectionVm(items: [], isLoading: true),
            itemBuilder: _neverBuilt,
          ),
        ),
      ),
    );

    expect(find.byType(DetailSectionLoadingShimmer), findsOneWidget);
    expect(find.byType(DetailSectionEmptyPlaceholder), findsNothing);
  });

  testWidgets('DetailSectionBody shows empty placeholder when idle and empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DetailSectionBody(
            viewModel: DetailSectionVm(items: [], isLoading: false),
            itemBuilder: _neverBuilt,
          ),
        ),
      ),
    );

    expect(find.byType(DetailSectionEmptyPlaceholder), findsOneWidget);
  });

  testWidgets('DetailSectionBody builds items when loaded', (tester) async {
    final items = [PostList.fromJson({'id_form': 'F1'})];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DetailSectionBody(
            viewModel: DetailSectionVm(items: items, isLoading: false),
            itemBuilder: _itemLabel,
          ),
        ),
      ),
    );

    expect(find.text('F1'), findsOneWidget);
  });
}

Widget _neverBuilt(BuildContext context, PostList item) =>
    throw StateError('should not build');

Widget _itemLabel(BuildContext context, PostList item) =>
    Text(item.idForm);
