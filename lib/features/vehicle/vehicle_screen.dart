import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:range_line/app/theme/app_colors.dart';
import 'package:range_line/app/theme/app_spacing.dart';
import 'package:range_line/app/theme/app_typography.dart';
import 'package:range_line/data/providers/database_providers.dart';
import 'package:range_line/shared/models/vehicle.dart';
import 'package:range_line/shared/widgets/app_card.dart';
import 'package:range_line/shared/widgets/text_input_field.dart';

class VehicleScreen extends ConsumerStatefulWidget {
  const VehicleScreen({super.key});

  @override
  ConsumerState<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends ConsumerState<VehicleScreen> {
  bool _editing = false;
  bool _saving = false;

  late final TextEditingController _brand;
  late final TextEditingController _model;
  late final TextEditingController _year;
  late final TextEditingController _plate;
  late final TextEditingController _color;
  late final TextEditingController _displacement;
  late final TextEditingController _transmission;
  late final TextEditingController _fuelType;
  late final TextEditingController _purchaseDate;
  late final TextEditingController _purchasePrice;

  @override
  void initState() {
    super.initState();
    _brand = TextEditingController();
    _model = TextEditingController();
    _year = TextEditingController();
    _plate = TextEditingController();
    _color = TextEditingController();
    _displacement = TextEditingController();
    _transmission = TextEditingController();
    _fuelType = TextEditingController();
    _purchaseDate = TextEditingController();
    _purchasePrice = TextEditingController();
  }

  @override
  void dispose() {
    _brand.dispose();
    _model.dispose();
    _year.dispose();
    _plate.dispose();
    _color.dispose();
    _displacement.dispose();
    _transmission.dispose();
    _fuelType.dispose();
    _purchaseDate.dispose();
    _purchasePrice.dispose();
    super.dispose();
  }

  void _fillDraft(Vehicle vehicle) {
    _brand.text = vehicle.brand;
    _model.text = vehicle.model;
    _year.text = vehicle.year;
    _plate.text = vehicle.plate;
    _color.text = vehicle.color;
    _displacement.text = vehicle.displacement;
    _transmission.text = vehicle.transmission;
    _fuelType.text = vehicle.fuelType;
    _purchaseDate.text = vehicle.purchaseDate;
    _purchasePrice.text = vehicle.purchasePrice;
  }

  Vehicle _buildDraft(Vehicle current) {
    return current.copyWith(
      brand: _brand.text.trim(),
      model: _model.text.trim(),
      year: _year.text.trim(),
      plate: _plate.text.trim(),
      color: _color.text.trim(),
      displacement: _displacement.text.trim(),
      transmission: _transmission.text.trim(),
      fuelType: _fuelType.text.trim(),
      purchaseDate: _purchaseDate.text.trim(),
      purchasePrice: _purchasePrice.text.trim(),
    );
  }

  Future<void> _save(Vehicle current) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final draft = _buildDraft(current);
      await ref.read(vehicleRepositoryProvider).saveVehicle(draft);
      if (!mounted) return;
      ref.invalidate(vehicleProvider);
      setState(() => _editing = false);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleAsync = ref.watch(vehicleProvider);

    return vehicleAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
      data: (vehicle) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            8,
            AppSpacing.pageHorizontal,
            32,
          ),
          children: [
            if (_editing)
              _buildEditView(vehicle)
            else
              _buildReadOnlyView(vehicle),
          ],
        );
      },
    );
  }

  Widget _buildReadOnlyView(Vehicle vehicle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('车辆档案', style: AppTypography.label),
                Text('我的车辆', style: AppTypography.headline),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () {
                _fillDraft(vehicle);
                setState(() => _editing = true);
              },
              icon: const Icon(Icons.edit_outlined, size: 14),
              label: const Text('编辑'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.directions_car_outlined, color: AppColors.primary),
              ),
              const SizedBox(height: 14),
              Text(
                vehicle.displayName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onPrimaryContainer,
                  height: 1.15,
                ),
              ),
              Text(
                vehicle.year,
                style: AppTypography.label.copyWith(
                  color: AppColors.onPrimaryContainer.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _specChip(vehicle.displacement),
                  _specChip(vehicle.transmission),
                  _specChip(vehicle.color),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      vehicle.plate,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimaryContainer,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline, size: 15, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('基本信息', style: AppTypography.title),
                ],
              ),
              const SizedBox(height: 4),
              _infoRow('购车日期', vehicle.purchaseDate),
              _infoRow('购车价格', '¥ ${vehicle.purchasePrice}'),
              _infoRow('发动机', vehicle.displacement),
              _infoRow('变速箱', vehicle.transmission),
              _infoRow('燃油类型', vehicle.fuelType),
              _infoRow('车身颜色', vehicle.color, last: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditView(Vehicle current) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('正在编辑', style: AppTypography.label),
                Text('车辆信息', style: AppTypography.headline),
              ],
            ),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => setState(() => _editing = false),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _saving ? null : () => _save(current),
                  child: Text(_saving ? '保存中...' : '保存'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _sectionTitle('车辆信息'),
        AppCard(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              TextInputField(label: '品牌', controller: _brand),
              const SizedBox(height: 12),
              TextInputField(label: '型号', controller: _model),
              const SizedBox(height: 12),
              TextInputField(label: '年款', controller: _year),
              const SizedBox(height: 12),
              TextInputField(label: '车牌号', controller: _plate),
              const SizedBox(height: 12),
              TextInputField(label: '车身颜色', controller: _color),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _sectionTitle('技术规格'),
        AppCard(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              TextInputField(label: '发动机排量', controller: _displacement),
              const SizedBox(height: 12),
              TextInputField(label: '变速箱', controller: _transmission),
              const SizedBox(height: 12),
              TextInputField(label: '燃油类型', controller: _fuelType),
              const SizedBox(height: 12),
              TextInputField(label: '购车日期', controller: _purchaseDate),
              const SizedBox(height: 12),
              TextInputField(label: '购车价格', controller: _purchasePrice),
            ],
          ),
        ),
      ],
    );
  }

  Widget _specChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.primary.withValues(alpha: 0.15),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 10),
      child: Text(
        title,
        style: AppTypography.label.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          fontSize: 10.5,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: Border(
          bottom: last
              ? BorderSide.none
              : const BorderSide(color: AppColors.outline),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(label, style: AppTypography.label),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
