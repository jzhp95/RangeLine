import 'package:flutter/material.dart';
import 'package:range_line/app/theme/app_colors.dart';
import 'package:range_line/app/theme/app_radius.dart';
import 'package:range_line/app/theme/app_typography.dart';

class NotesInput extends StatefulWidget {
  const NotesInput({
    super.key,
    required this.controller,
    this.onChanged,
    this.maxLength = 200,
    this.label = '备注（选填）',
    this.placeholder = '如：中石化会员卡优惠、新开业加油站…',
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final int maxLength;
  final String label;
  final String placeholder;

  @override
  State<NotesInput> createState() => _NotesInputState();
}

class _NotesInputState extends State<NotesInput> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
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
          child: Column(
            children: [
              TextField(
                focusNode: _focusNode,
                controller: widget.controller,
                onChanged: (v) {
                  if (v.length > widget.maxLength) {
                    widget.controller.text = v.substring(0, widget.maxLength);
                    widget.controller.selection = TextSelection.collapsed(
                      offset: widget.maxLength,
                    );
                  }
                  widget.onChanged?.call(widget.controller.text);
                },
                maxLines: 3,
                style: AppTypography.body,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: widget.placeholder,
                  hintStyle: AppTypography.label,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${widget.controller.text.length}/${widget.maxLength}',
                  style: AppTypography.label.copyWith(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
