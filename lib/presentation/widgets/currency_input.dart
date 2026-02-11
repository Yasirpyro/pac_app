import 'package:flutter/material.dart';
import 'app_text_field.dart';

class CurrencyInput extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<double>? onChanged;
  final FormFieldValidator<String>? validator;

  const CurrencyInput({
    super.key,
    required this.label,
    this.controller,
    this.errorText,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: '0.00',
      controller: controller,
      errorText: errorText,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
      prefix: Padding(
        padding: EdgeInsets.only(left: 12),
        child: Text(
          '\$',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      onChanged: (value) {
        final amount = double.tryParse(value) ?? 0;
        onChanged?.call(amount);
      },
    );
  }
}
