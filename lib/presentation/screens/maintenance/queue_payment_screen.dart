import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/bills_provider.dart';
import '../../providers/payment_provider.dart';
import '../../../data/models/bill_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_radius.dart';
import '../../../core/utils/formatters.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/warning_banner.dart';
import '../../widgets/toast.dart';

class QueuePaymentScreen extends StatefulWidget {
  final int billId;

  const QueuePaymentScreen({super.key, required this.billId});

  @override
  State<QueuePaymentScreen> createState() => _QueuePaymentScreenState();
}

class _QueuePaymentScreenState extends State<QueuePaymentScreen> {
  BillModel? _bill;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBill();
  }

  Future<void> _loadBill() async {
    final bill = await context.read<BillsProvider>().getBillById(widget.billId);
    if (mounted) {
      setState(() {
        _bill = bill;
      });
    }
  }

  Future<void> _queuePayment() async {
    if (_bill == null) return;

    setState(() {
      _isLoading = true;
    });

    // Use the provider which handles the transaction, logic, and audit logging
    final success = await context.read<PaymentProvider>().queuePayment(billId: _bill!.id!);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Refresh bills list to show updated status
        await context.read<BillsProvider>().loadBills();

        if (mounted) {
          Toast.show(
            context,
            'Payment queued successfully',
            type: ToastType.success,
          );
          context.pop();
        }
      } else {
        final error = context.read<PaymentProvider>().error;
        Toast.show(
          context,
          error ?? 'Failed to queue payment',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bill == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Queue Payment'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Payment'),
        backgroundColor: AppColors.maintenance,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WarningBanner(
              type: WarningType.info,
              title: 'Payment Intent Only',
              message:
                  'System maintenance is in progress. This payment will be QUEUED (not processed immediately) and will execute automatically when service resumes.',
            ),
            AppSpacing.verticalLG,
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bill Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    AppSpacing.verticalMD,
                    _buildDetailRow('Payee', _bill!.payeeName),
                    AppSpacing.verticalSM,
                    _buildDetailRow(
                      'Amount',
                      Formatters.formatCurrency(_bill!.amount),
                      isHighlighted: true,
                    ),
                    AppSpacing.verticalSM,
                    _buildDetailRow(
                      'Due Date',
                      Formatters.formatDate(_bill!.dueDate),
                    ),
                    AppSpacing.verticalSM,
                    _buildDetailRow('Category', _bill!.category),
                  ],
                ),
              ),
            ),
            AppSpacing.verticalLG,
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: AppRadius.cardRadius,
                border: Border.all(color: AppColors.warning),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning),
                  AppSpacing.horizontalSM,
                  Expanded(
                    child: Text(
                      'This is a payment INTENT and will process later when maintenance ends.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalXL,
            PrimaryButton(
              label: 'Queue This Payment',
              onPressed: _isLoading ? null : _queuePayment,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
                fontSize: isHighlighted ? 18 : null,
              ),
        ),
      ],
    );
  }
}
