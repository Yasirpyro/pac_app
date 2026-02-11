import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/bill_model.dart';
import '../../../theme/app_spacing.dart';
import '../../providers/bills_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/currency_input.dart';
import '../../widgets/date_picker_field.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/toast.dart';

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _payeeController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;
  bool _isSaving = false;

  @override
  void dispose() {
    _payeeController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Bill')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Payee Name',
                controller: _payeeController,
                hint: 'e.g., ComEd Electric',
                validator: Validators.validatePayeeName,
                textInputAction: TextInputAction.next,
              ),
              AppSpacing.verticalMD,
              CurrencyInput(
                label: 'Amount',
                controller: _amountController,
                validator: Validators.validateAmount,
              ),
              AppSpacing.verticalMD,
              DatePickerField(
                label: 'Due Date',
                selectedDate: _selectedDate,
                errorText: _selectedDate == null && _isSaving
                    ? 'Due date is required'
                    : null,
                onDateSelected: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
              AppSpacing.verticalMD,
              AppDropdown<String>(
                label: 'Category',
                value: _selectedCategory,
                hint: 'Select category',
                items: AppConstants.billCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              if (_selectedCategory == null && _isSaving)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    'Category is required',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              AppSpacing.verticalXL,
              PrimaryButton(
                label: 'Add Bill',
                isLoading: _isSaving,
                onPressed: _saveBill,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveBill() async {
    setState(() => _isSaving = true);

    final formValid = _formKey.currentState!.validate();
    final dateValid = _selectedDate != null;
    final categoryValid = _selectedCategory != null;

    if (!formValid || !dateValid || !categoryValid) {
      setState(() => _isSaving = false);
      return;
    }

    final bill = BillModel(
      payeeName: _payeeController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      dueDate: _selectedDate!,
      category: _selectedCategory!,
    );

    await context.read<BillsProvider>().createBill(bill);

    if (mounted) {
      Toast.show(context, 'Bill added', type: ToastType.success);
      context.pop();
    }
  }
}
