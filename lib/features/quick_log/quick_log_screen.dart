import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:range_line/app/shell/main_shell.dart';
import 'package:range_line/app/theme/app_colors.dart';
import 'package:range_line/app/theme/app_spacing.dart';
import 'package:range_line/app/theme/app_typography.dart';
import 'package:range_line/data/providers/database_providers.dart';
import 'package:range_line/shared/models/expense_category.dart';
import 'package:range_line/shared/models/fuel_grade.dart';
import 'package:range_line/shared/services/fuel_calculator.dart';
import 'package:range_line/shared/widgets/app_card.dart';
import 'package:range_line/shared/widgets/chip_group.dart';
import 'package:range_line/shared/widgets/date_picker_row.dart';
import 'package:range_line/shared/widgets/md3_switch_row.dart';
import 'package:range_line/shared/widgets/notes_input.dart';
import 'package:range_line/shared/widgets/ql_input.dart';
import 'package:range_line/shared/widgets/ql_input_row.dart';
import 'package:range_line/shared/widgets/save_button.dart';
import 'package:range_line/shared/widgets/segment_toggle.dart';
import 'package:range_line/shared/widgets/text_input_field.dart';

enum _QuickLogType { fuel, expense }

class QuickLogScreen extends ConsumerStatefulWidget {
  const QuickLogScreen({super.key});

  @override
  ConsumerState<QuickLogScreen> createState() => _QuickLogScreenState();
}

class _QuickLogScreenState extends ConsumerState<QuickLogScreen> {
  _QuickLogType _type = _QuickLogType.fuel;

  final _mileageController = TextEditingController();
  final _fuelAmountController = TextEditingController();
  final _pumpPriceController = TextEditingController(text: '7.48');
  final _discountController = TextEditingController(text: '0');
  final _stationController = TextEditingController();
  final _fuelNotesController = TextEditingController();

  bool _isFull = true;
  bool _prevRecorded = true;
  FuelGrade _fuelGrade = FuelGrade.g95;
  DateTime _fuelDate = DateTime.now();

  final _expenseAmountController = TextEditingController();
  final _expenseNotesController = TextEditingController();
  ExpenseCategory _expenseCategory = ExpenseCategory.maintenance;
  DateTime _expenseDate = DateTime.now();

  bool _savingFuel = false;
  bool _savedFuel = false;
  int _fuelShakeTick = 0;

  bool _savingExpense = false;
  bool _savedExpense = false;
  int _expenseShakeTick = 0;

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _mileageController.addListener(_onFormChanged);
    _fuelAmountController.addListener(_onFormChanged);
    _pumpPriceController.addListener(_onFormChanged);
    _discountController.addListener(_onFormChanged);
    _stationController.addListener(_onFormChanged);
    _fuelNotesController.addListener(_onFormChanged);
    _expenseAmountController.addListener(_onFormChanged);
    _expenseNotesController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _mileageController.removeListener(_onFormChanged);
    _fuelAmountController.removeListener(_onFormChanged);
    _pumpPriceController.removeListener(_onFormChanged);
    _discountController.removeListener(_onFormChanged);
    _stationController.removeListener(_onFormChanged);
    _fuelNotesController.removeListener(_onFormChanged);
    _expenseAmountController.removeListener(_onFormChanged);
    _expenseNotesController.removeListener(_onFormChanged);
    _mileageController.dispose();
    _fuelAmountController.dispose();
    _pumpPriceController.dispose();
    _discountController.dispose();
    _stationController.dispose();
    _fuelNotesController.dispose();
    _expenseAmountController.dispose();
    _expenseNotesController.dispose();
    super.dispose();
  }

  double _toDouble(String value) => double.tryParse(value.trim()) ?? 0;
  int _toInt(String value) => int.tryParse(value.trim()) ?? 0;

  bool get _canSaveFuel =>
      _toInt(_mileageController.text) > 0 &&
      _toDouble(_fuelAmountController.text) > 0;

  bool get _canSaveExpense => _toDouble(_expenseAmountController.text) > 0;

  double? get _pumpTotal => FuelCalculator.calcPumpTotal(
        _toDouble(_fuelAmountController.text),
        _toDouble(_pumpPriceController.text),
      );

  double get _actualTotal =>
      FuelCalculator.calcActualTotal(_pumpTotal ?? 0, _toDouble(_discountController.text));

  double? get _actualPricePerL => FuelCalculator.calcActualPricePerL(
        _actualTotal,
        _toDouble(_fuelAmountController.text),
      );

  Future<void> _saveFuel() async {
    if (_savingFuel) return;
    if (!_canSaveFuel) {
      setState(() => _fuelShakeTick++);
      return;
    }

    setState(() => _savingFuel = true);
    try {
      await ref.read(recordRepositoryProvider).addFuelRecord(
            date: _fuelDate,
            mileage: _toInt(_mileageController.text),
            fuelAmount: _toDouble(_fuelAmountController.text),
            pricePerL: _toDouble(_pumpPriceController.text),
            discountAmount: _toDouble(_discountController.text),
            isFull: _isFull,
            prevRecorded: _prevRecorded,
            fuelGrade: _fuelGrade,
            station: _stationController.text.trim(),
            notes: _fuelNotesController.text.trim(),
          );

      if (!mounted) return;
      setState(() => _savedFuel = true);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      goToHistoryTab(context);

      await Future.delayed(const Duration(milliseconds: 1700));
      if (!mounted) return;
      setState(() {
        _savedFuel = false;
        _mileageController.clear();
        _fuelAmountController.clear();
        _discountController.text = '0';
        _stationController.clear();
        _fuelNotesController.clear();
      });
    } finally {
      if (mounted) {
        setState(() => _savingFuel = false);
      }
    }
  }

  Future<void> _saveExpense() async {
    if (_savingExpense) return;
    if (!_canSaveExpense) {
      setState(() => _expenseShakeTick++);
      return;
    }

    setState(() => _savingExpense = true);
    try {
      await ref.read(recordRepositoryProvider).addExpenseRecord(
            date: _expenseDate,
            category: _expenseCategory,
            totalCost: _toDouble(_expenseAmountController.text),
            notes: _expenseNotesController.text.trim(),
          );
      if (!mounted) return;
      setState(() => _savedExpense = true);
      await Future.delayed(const Duration(milliseconds: 2200));
      if (!mounted) return;
      setState(() {
        _savedExpense = false;
        _expenseAmountController.clear();
        _expenseNotesController.clear();
      });
    } finally {
      if (mounted) {
        setState(() => _savingExpense = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        8,
        AppSpacing.pageHorizontal,
        40,
      ),
      children: [
        const Column(
          children: [
            Text('极速记账', style: AppTypography.headline),
            SizedBox(height: 2),
            Text('快速记录加油或其他费用', style: AppTypography.label),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SegmentToggle(
          options: const ['加油记录', '其他费用'],
          value: _type == _QuickLogType.fuel ? '加油记录' : '其他费用',
          onChanged: (v) {
            setState(() {
              _type = v == '加油记录' ? _QuickLogType.fuel : _QuickLogType.expense;
            });
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_type == _QuickLogType.fuel) _buildFuelForm() else _buildExpenseForm(),
      ],
    );
  }

  Widget _buildFuelForm() {
    return Column(
      children: [
        QlInputRow(
          left: QlInput(
            label: '当前总里程',
            controller: _mileageController,
            unit: 'km',
            placeholder: '12450',
          ),
          right: QlInput(
            label: '本次加油量',
            controller: _fuelAmountController,
            unit: 'L',
            placeholder: '42.1',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '价格信息',
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: QlInput(
                      label: '机显单价',
                      controller: _pumpPriceController,
                      unit: '元/L',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 14, left: 8, right: 8),
                    child: Text('=', style: AppTypography.label),
                  ),
                  Expanded(
                    child: _ReadOnlyMoneyInput(
                      label: '机显金额（自动）',
                      value: _pumpTotal != null ? _pumpTotal!.toStringAsFixed(2) : '',
                      highlight: _pumpTotal != null,
                      unit: '元',
                      placeholder: '—',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: QlInput(
                      label: '优惠金额',
                      controller: _discountController,
                      unit: '元',
                      placeholder: '0.00',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 14, left: 8, right: 8),
                    child: Text('→', style: AppTypography.label),
                  ),
                  Expanded(
                    child: _ReadOnlyMoneyInput(
                      label: '实付金额（自动）',
                      value: _pumpTotal != null ? _actualTotal.toStringAsFixed(2) : '',
                      highlight: _pumpTotal != null,
                      unit: '元',
                      placeholder: '—',
                    ),
                  ),
                ],
              ),
              if (_actualPricePerL != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '实付单价',
                        style: AppTypography.label.copyWith(
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${_actualPricePerL!.toStringAsFixed(3)} 元/L',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      if (_toDouble(_discountController.text) > 0)
                        Text(
                          '省了 ¥${_toDouble(_discountController.text).toStringAsFixed(2)}',
                          style: AppTypography.label.copyWith(color: AppColors.primary),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Md3SwitchRow(
            value: _isFull,
            onChanged: (v) => setState(() => _isFull = v),
            label: '本次是否加满？',
            subtitle: _isFull ? '已加满，可精准计算油耗' : '未加满，仅记录花费',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Md3SwitchRow(
            value: _prevRecorded,
            onChanged: (v) => setState(() => _prevRecorded = v),
            label: '上次加油记录了吗？',
            subtitle: _prevRecorded ? '里程连续，油耗可正常计算' : '上次漏记，本次油耗将跳过计算',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('油号选择', style: AppTypography.label),
        ),
        const SizedBox(height: AppSpacing.sm),
        ChipGroup(
          options: const ['92号', '95号', '98号'],
          value: _fuelGrade.label,
          onChanged: (v) {
            setState(() {
              _fuelGrade = switch (v) {
                '92号' => FuelGrade.g92,
                '98号' => FuelGrade.g98,
                _ => FuelGrade.g95,
              };
            });
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        TextInputField(
          label: '加油站（选填）',
          controller: _stationController,
          placeholder: '如：中石化XX路站、中石油XX加油站',
        ),
        const SizedBox(height: AppSpacing.lg),
        DatePickerRow(
          date: _fuelDate,
          onDateChanged: (v) => setState(() => _fuelDate = v),
        ),
        const SizedBox(height: AppSpacing.lg),
        NotesInput(controller: _fuelNotesController),
        const SizedBox(height: AppSpacing.lg),
        SaveButton(
          label: '保存记录（保存后自动计算）',
          successLabel: '✓ 已保存，正在计算…',
          enabled: _canSaveFuel && !_savingFuel,
          success: _savedFuel,
          shakeTrigger: _fuelShakeTick,
          onPressed: _saveFuel,
        ),
        if (!_canSaveFuel)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '请填写里程和加油量后保存',
              style: AppTypography.label.copyWith(color: AppColors.danger),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildExpenseForm() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('费用类型', style: AppTypography.label),
        ),
        const SizedBox(height: AppSpacing.sm),
        ChipGroup(
          options: ExpenseCategory.values.map((e) => e.label).toList(),
          value: _expenseCategory.label,
          onChanged: (v) {
            setState(() => _expenseCategory = ExpenseCategory.fromLabel(v));
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        QlInput(
          label: '费用金额',
          controller: _expenseAmountController,
          unit: '元',
          placeholder: '0.00',
        ),
        const SizedBox(height: AppSpacing.lg),
        NotesInput(controller: _expenseNotesController),
        const SizedBox(height: AppSpacing.lg),
        DatePickerRow(
          date: _expenseDate,
          onDateChanged: (v) => setState(() => _expenseDate = v),
        ),
        const SizedBox(height: AppSpacing.lg),
        SaveButton(
          label: '保存${_expenseCategory.label}记录',
          successLabel: '✓ ${_expenseCategory.label}记录已保存',
          enabled: _canSaveExpense && !_savingExpense,
          success: _savedExpense,
          shakeTrigger: _expenseShakeTick,
          onPressed: _saveExpense,
        ),
        if (!_canSaveExpense)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '请填写费用金额后保存',
              style: AppTypography.label.copyWith(color: AppColors.danger),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

class _ReadOnlyMoneyInput extends StatelessWidget {
  const _ReadOnlyMoneyInput({
    required this.label,
    required this.value,
    required this.unit,
    required this.placeholder,
    required this.highlight,
  });

  final String label;
  final String value;
  final String unit;
  final String placeholder;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: 6),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: highlight ? AppColors.primary : AppColors.outline,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value.isEmpty ? placeholder : value,
                  style: TextStyle(
                    fontSize: 15,
                    color: value.isEmpty ? AppColors.onSurfaceVariant : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Text(unit, style: AppTypography.label.copyWith(fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
