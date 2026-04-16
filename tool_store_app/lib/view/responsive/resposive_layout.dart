import 'package:flutter/material.dart';
import 'package:tool_store_app/view/var/var.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget dekstopLayout;

  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    required this.dekstopLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileWidth) {
          return mobileLayout;
        } else {
          return dekstopLayout;
        }
      },
    );
  }
}
