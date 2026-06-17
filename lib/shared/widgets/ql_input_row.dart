import 'package:flutter/material.dart';
import 'package:range_line/app/theme/app_spacing.dart';
import 'package:range_line/shared/widgets/ql_input.dart';

class QlInputRow extends StatelessWidget {
  const QlInputRow({
    super.key,
    required this.left,
    required this.right,
  });

  final QlInput left;
  final QlInput right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: right),
      ],
    );
  }
}
