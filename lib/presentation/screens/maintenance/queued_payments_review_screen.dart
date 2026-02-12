import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/bill_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../providers/bills_provider.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/empty_state.dart';

class QueuedPaymentsReviewScreen extends StatefulWidget {
  const QueuedPaymentsReviewScreen({super.key});

  @override
  State<QueuedPaymentsReviewScreen> createState() => _QueuedPaymentsReviewScreenState();
}

class _QueuedPaymentsReviewScreenState extends State<QueuedPaymentsReviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillsProvider>().loadBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Queued Payments'),
      ),
      body: Consumer<BillsProvider>(
        builder: (context, billsProvider, _) {
          final queuedBills = billsProvider.queuedBills;

          if (billsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (queuedBills.isEmpty) {
            return EmptyState(
              icon: Icons.check_circle_outline,
              title: 'All Cleared',
              message: 'You have no queued payments remaining.',
              actionLabel: 'Return Home',
              onAction: () => context.go('/home'),
            );
          }

          return ListView.builder(
            padding: AppSpacing.screenPadding,
            itemCount: queuedBills.length,
            itemBuilder: (context, index) {
              final bill = queuedBills[index];
              return _buildQueuedBillCard(context, bill);
            },
          );
        },
      ),
    );
  }

  Widget _buildQueuedBillCard(BuildContext context, BillModel bill) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.payeeName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Due: ${Formatters.formatDate(bill.dueDate)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatters.formatCurrency(bill.amount),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _removeQueuedPayment(context, bill),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Remove'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                AppSpacing.horizontalMD,
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _processPayment(context, bill),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Pay Now (Sim)'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeQueuedPayment(BuildContext context, BillModel bill) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Queued Payment?'),
        content: Text('This will cancel the payment for ${bill.payeeName} and return the bill to "Pending" status.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await context.read<PaymentProvider>().removeQueuedPayment(bill.id!);
      if (success && context.mounted) {
        context.read<BillsProvider>().loadBills();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed queued payment for ${bill.payeeName}')),
        );
      }
    }
  }

  Future<void> _processPayment(BuildContext context, BillModel bill) async {
    // In a real app, maybe biometric auth here again?
    // For demo flow, we just confirm and execute.
    final success = await context.read<PaymentProvider>().processQueuedPayment(bill.id!);

    if (success && context.mounted) {
      context.read<BillsProvider>().loadBills();

      // Check if this was the last one
      final remaining = context.read<BillsProvider>().queuedBills.length;

      if (remaining <= 1) { // 1 because the provider might not have updated the list in getter yet if we didn't await loadBills fully or if it's sync
         // Actually we awaited loadBills.
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment simulated for ${bill.payeeName}'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
