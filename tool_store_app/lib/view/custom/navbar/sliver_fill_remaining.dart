import 'package:flutter/material.dart';

class SliverFillRemaiings extends StatefulWidget {
  const SliverFillRemaiings({
    super.key,
    required this.errors,
    required this.hasScrollBodys,
  });

  final String errors;
  final bool hasScrollBodys;

  @override
  State<SliverFillRemaiings> createState() => _SliverFillRemaiingsState();
}

class _SliverFillRemaiingsState extends State<SliverFillRemaiings> {
  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: widget.hasScrollBodys,
      child: Center(child: Text(widget.errors)),
    );
  }
}
