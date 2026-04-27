import 'package:flutter/material.dart';

class LazyListExample extends StatefulWidget {
  const LazyListExample({super.key});
  @override
  State<LazyListExample> createState() => _LazyListExampleState();
}

class _LazyListExampleState extends State<LazyListExample> {
  final ScrollController _scrollController = ScrollController();
  List<String> items = List.generate(20, (i) => "Item ${i + 1}");
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Tambahkan listener untuk mendeteksi scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreItems();
      }
    });
  }

  Future<void> _loadMoreItems() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    // Simulasi fetch data dari API
    await Future.delayed(Duration(milliseconds: 1));
    List<String> newItems = List.generate(
      10,
      (i) => "Item ${items.length + i + 1}",
    );

    setState(() {
      items.addAll(newItems);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        controller: _scrollController,
        itemCount: items.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return Center(
              child: CircularProgressIndicator(),
            ); // Indikator loading di bawah
          }
          return ListTile(title: Text(items[index]));
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
        .dispose(); // Selalu dispose controller untuk menghindari memory leak
    super.dispose();
  }
}
