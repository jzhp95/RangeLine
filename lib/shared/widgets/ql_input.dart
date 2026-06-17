import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:range_line/app/theme/app_colors.dart';
import 'package:range_line/app/theme/app_radius.dart';
import 'package:range_line/app/theme/app_typography.dart';

class QlInput extends StatefulWidget {
  const QlInput({
    super.key,
    required this.label,
    this.controller,
    this.onChanged,
    this.unit,
    this.placeholder,
    this.readOnly = false,
    this.highlight = false,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
  });

  final String label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? unit;
  final String? placeholder;
  final bool readOnly;
  final bool highlight;
  final TextInputType keyboardType;

  @override
  State<QlInput> createState() => _QlInputState();
}

class _QlInputState extends State<QlInput> {
  late TextEditingController _controller;
  final _focusNode = FocusNode();
  bool _focused = false;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _focusNode.addListener(() {
      setState(() => _focused = widget.readOnly ? false : _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _focused
        ? AppColors.primary
        : (widget.highlight ? AppColors.primary : AppColors.outline);
    final borderWidth = _focused ? 2.0 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: _focused ? 11 : 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  readOnly: widget.readOnly,
                  controller: _controller,
                  onChanged: widget.onChanged,
                  keyboardType: widget.readOnly ? TextInputType.text : widget.keyboardType,
                  inputFormatters: widget.readOnly
                      ? null
                      : [
                          if (widget.keyboardType ==
                              const TextInputType.numberWithOptions(decimal: true))
                            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                        ],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: widget.readOnly ? FontWeight.w400 : FontWeight.w500,
                    color: widget.readOnly ? AppColors.onSurfaceVariant : AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: widget.placeholder,
                    hintStyle: AppTypography.label.copyWith(fontSize: 15),
                  ),
                ),
              ),
              if (widget.unit != null) ...[
                const SizedBox(width: 3),
                Text(widget.unit!, style: AppTypography.label.copyWith(fontSize: 11)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
