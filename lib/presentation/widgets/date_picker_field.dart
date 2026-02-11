import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../core/utils/formatters.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? errorText;

  const DatePickerField({
    super.key,
    required this.label,
    this.selectedDate,
    this.firstDate,
    this.lastDate,
    required this.onDateSelected,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        AppSpacing.verticalXS,
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: AppRadius.inputRadius,
          child: Container(
            width: double.infinity,
            padding: AppSpacing.inputPadding,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(
                color: errorText != null ? AppColors.error : AppColors.outline,
              ),
              borderRadius: AppRadius.inputRadius,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                AppSpacing.horizontalSM,
                Text(
                  selectedDate != null
                      ? Formatters.formatDate(selectedDate!)
                      : 'Select date',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: selectedDate != null
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          AppSpacing.verticalXS,
          Text(
            errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}
