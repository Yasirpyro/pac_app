import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cashflow_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_radius.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/currency_input.dart';
import '../../widgets/date_picker_field.dart';
import '../../widgets/toast.dart';

class CashflowInputsScreen extends StatefulWidget {
  const CashflowInputsScreen({super.key});

  @override
  State<CashflowInputsScreen> createState() => _CashflowInputsScreenState();
}

class _CashflowInputsScreenState extends State<CashflowInputsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _balanceController = TextEditingController();
  final _bufferController = TextEditingController();
  DateTime? _nextPayday;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentValues();
  }

  void _loadCurrentValues() {
    final cashflowProvider = context.read<CashflowProvider>();
    _balanceController.text = cashflowProvider.currentBalance.toStringAsFixed(2);
    _bufferController.text = cashflowProvider.safetyBuffer.toStringAsFixed(2);
    _nextPayday = cashflowProvider.nextPayday;
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _bufferController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_nextPayday == null) {
      Toast.show(
        context,
        'Please select next payday date',
        type: ToastType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final balance = double.parse(_balanceController.text);
      final buffer = double.parse(_bufferController.text);

      await context.read<CashflowProvider>().updateAll(
            balance: balance,
            nextPayday: _nextPayday!,
            safetyBuffer: buffer,
          );

      if (mounted) {
        Toast.show(
          context,
          'Cashflow settings updated',
          type: ToastType.success,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        Toast.show(
          context,
          'Failed to save changes: $e',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashflow Settings'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: AppRadius.cardRadius,
                  border: Border.all(color: AppColors.info),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: AppColors.info),
                    AppSpacing.horizontalSM,
                    Expanded(
                      child: Text(
                        'Provide your cashflow information to help PAC make better recommendations.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalXL,
              CurrencyInput(
                label: 'Current Balance',
                controller: _balanceController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current balance';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount > 999999.99) {
                    return 'Amount cannot exceed \$999,999.99';
                  }
                  return null;
                },
              ),
              AppSpacing.verticalMD,
              Text(
                'Enter your checking account balance',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              AppSpacing.verticalXL,
              DatePickerField(
                label: 'Next Payday Date',
                selectedDate: _nextPayday,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
                onDateSelected: (date) {
                  setState(() {
                    _nextPayday = date;
                  });
                },
              ),
              AppSpacing.verticalMD,
              Text(
                'When do you next get paid?',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              AppSpacing.verticalXL,
              CurrencyInput(
                label: 'Safety Buffer',
                controller: _bufferController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your safety buffer';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 100) {
                    return 'Safety buffer must be at least \$100';
                  }
                  if (amount > 2000) {
                    return 'Safety buffer cannot exceed \$2,000';
                  }
                  return null;
                },
              ),
              AppSpacing.verticalMD,
              Text(
                'Minimum balance you want to maintain',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              AppSpacing.verticalXL,
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: AppRadius.cardRadius,
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: AppColors.warning),
                    AppSpacing.horizontalSM,
                    Expanded(
                      child: Text(
                        'For demo purposes only. Production app would sync with real account data.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalXL,
              PrimaryButton(
                label: 'Save Changes',
                onPressed: _isLoading ? null : _saveChanges,
                isLoading: _isLoading,
              ),
              AppSpacing.verticalMD,
              SecondaryButton(
                label: 'Cancel',
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
