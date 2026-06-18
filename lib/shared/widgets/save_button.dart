import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:range_line/app/theme/app_colors.dart';
import 'package:range_line/app/theme/app_radius.dart';

class SaveButton extends StatefulWidget {
  const SaveButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.success = false,
    this.successLabel,
    this.shakeTrigger = 0,
  });

  final String label;
  final String? successLabel;
  final bool enabled;
  final bool success;
  final VoidCallback? onPressed;
  final int shakeTrigger;

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(SaveButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shakeTrigger != oldWidget.shakeTrigger) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.success ? AppColors.success : AppColors.primary;
    final text = widget.success ? (widget.successLabel ?? '✓ 已保存') : widget.label;

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final t = _shakeController.value;
        final offset = t == 0 ? 0.0 : math.sin(t * math.pi * 4) * 4 * (1 - t);
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: widget.enabled ? widget.onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: AppColors.onPrimary,
            disabledBackgroundColor: bg.withValues(alpha: widget.enabled ? 1 : 0.55),
            disabledForegroundColor: AppColors.onPrimary.withValues(alpha: 0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.3),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
