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
import '../../widgets/destructive_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/toast.dart';

class EditBillScreen extends StatefulWidget {
  final int billId;

  const EditBillScreen({super.key, required this.billId});

  @override
  State<EditBillScreen> createState() => _EditBillScreenState();
}

class _EditBillScreenState extends State<EditBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _payeeController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;
  bool _isSaving = false;
  bool _isLoading = true;
  BillModel? _bill;

  @override
  void initState() {
    super.initState();
    _loadBill();
  }

  Future<void> _loadBill() async {
    final bill = await context.read<BillsProvider>().getBillById(widget.billId);
    if (mounted && bill != null) {
      setState(() {
        _bill = bill;
        _payeeController.text = bill.payeeName;
        _amountController.text = bill.amount.toString();
        _selectedDate = bill.dueDate;
        _selectedCategory = bill.category;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _payeeController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Bill')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Bill')),
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
              AppSpacing.verticalXL,
              PrimaryButton(
                label: 'Save Changes',
                isLoading: _isSaving,
                onPressed: _updateBill,
              ),
              AppSpacing.verticalMD,
              DestructiveButton(
                label: 'Delete Bill',
                onPressed: () {
                  ConfirmationDialog.show(
                    context: context,
                    title: 'Delete Bill?',
                    message: 'This cannot be undone.',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                    onConfirm: () async {
                      final provider = context.read<BillsProvider>();
                      await provider.deleteBill(widget.billId);
                      if (context.mounted) {
                        Toast.show(context, 'Bill deleted', type: ToastType.info);
                        context.go('/bills');
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateBill() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedCategory == null) return;

    setState(() => _isSaving = true);

    final updated = _bill!.copyWith(
      payeeName: _payeeController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      dueDate: _selectedDate!,
      category: _selectedCategory!,
    );

    await context.read<BillsProvider>().updateBill(updated);

    if (mounted) {
      Toast.show(context, 'Bill updated', type: ToastType.success);
      context.pop();
    }
  }
}
