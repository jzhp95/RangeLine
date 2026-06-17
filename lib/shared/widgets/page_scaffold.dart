import 'package:flutter/material.dart';
import 'package:range_line/app/theme/app_spacing.dart';

class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
    this.bottomPadding = 24,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding.add(EdgeInsets.only(bottom: bottomPadding)),
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.cardGap),
          children[i],
        ],
      ],
    );
  }
}
