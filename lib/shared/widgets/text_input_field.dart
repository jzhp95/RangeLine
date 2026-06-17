import 'package:flutter/material.dart';
import 'package:range_line/app/theme/app_colors.dart';
import 'package:range_line/app/theme/app_radius.dart';
import 'package:range_line/app/theme/app_typography.dart';

class TextInputField extends StatefulWidget {
  const TextInputField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.placeholder,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? placeholder;

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTypography.label),
        const SizedBox(height: 6),
        Container(
          padding: EdgeInsets.all(_focused ? 11 : 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(
              color: _focused ? AppColors.primary : AppColors.outline,
              width: _focused ? 2 : 1,
            ),
          ),
          child: TextField(
            focusNode: _focusNode,
            controller: widget.controller,
            onChanged: widget.onChanged,
            style: AppTypography.body,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: widget.placeholder,
              hintStyle: AppTypography.label,
            ),
          ),
        ),
      ],
    );
  }
}
