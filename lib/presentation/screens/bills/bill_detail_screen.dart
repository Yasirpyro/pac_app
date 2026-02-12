import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_radius.dart';
import '../../../data/models/bill_model.dart';
import '../../providers/bills_provider.dart';
import '../../providers/cashflow_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/recommendation_provider.dart';
import '../../widgets/recommendation_panel.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/toast.dart';
import '../../widgets/category_icon.dart';

class BillDetailScreen extends StatefulWidget {
  final int billId;

  const BillDetailScreen({super.key, required this.billId});

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  BillModel? _bill;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBill();
  }

  Future<void> _loadBill() async {
    setState(() => _isLoading = true);
    final bill = await context.read<BillsProvider>().getBillById(widget.billId);

    if (bill != null && mounted) {
      // Get recommendation
      final cashflowProvider = context.read<CashflowProvider>();
      // Don't await this so UI loads faster, let the Consumer handle the state
      context.read<RecommendationProvider>().getRecommendation(
            billId: widget.billId,
            cashflowProvider: cashflowProvider,
          );
    }

    if (mounted) {
      setState(() {
        _bill = bill;
        _isLoading = false;
      });
    }
  }

  Future<void> _showDatePicker(BuildContext context, BillModel bill) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(bill.dueDate.year, bill.dueDate.month, bill.dueDate.day);

    if (dueDate.isBefore(today)) {
      Toast.show(context, 'Cannot set reminder for overdue bill', type: ToastType.error);
      return;
    }

    // Default to 3 days before due date
    var initialDate = dueDate.subtract(const Duration(days: 3));

    // If default is in the past, use today
    if (initialDate.isBefore(today)) {
      initialDate = today;
    }

    // Ensure initial date is not after due date
    if (initialDate.isAfter(dueDate)) {
      initialDate = dueDate;
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: dueDate, // Can't remind after due date
      helpText: 'Select Reminder Date',
    );

    if (pickedDate != null && mounted) {
      // Add time (e.g. 9 AM)
      final reminderDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        9, 0, 0
      );

      await context.read<BillsProvider>().setReminder(bill.id!, reminderDate);
      Toast.show(context, 'Reminder set for ${Formatters.formatDate(reminderDate)}', type: ToastType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bill Details')),
        body: const LoadingState(message: 'Loading bill...'),
      );
    }

    if (_bill == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bill Details')),
        body: const Center(child: Text('Bill not found')),
      );
    }

    final bill = _bill!;
    final daysUntilDue = bill.dueDate.difference(DateTime.now()).inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Details'),
        actions: [
          if (bill.status == 'Pending')
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await context.push('/edit-bill/${bill.id}');
                _loadBill();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount card
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  children: [
                    Row(
                      children: [
                        CategoryIcon(category: bill.category, size: 32),
                        AppSpacing.horizontalMD,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bill.payeeName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              AppSpacing.verticalXS,
                              Text(
                                bill.category,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(status: bill.status, dueDate: bill.dueDate),
                      ],
                    ),
                    AppSpacing.verticalLG,
                    Text(
                      Formatters.formatCurrency(bill.amount),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    AppSpacing.verticalSM,
                    Text(
                      'Due ${Formatters.formatDate(bill.dueDate)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppSpacing.verticalXS,
                    Text(
                      Formatters.formatDaysUntilDue(daysUntilDue),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: daysUntilDue < 0
                            ? AppColors.error
                            : daysUntilDue <= 3
                                ? AppColors.warning
                                : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            AppSpacing.verticalMD,

            // Reference ID (if exists)
            if (bill.referenceId != null) ...[
              Card(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Row(
                    children: [
                      const Icon(Icons.tag, color: AppColors.textSecondary, size: 20),
                      AppSpacing.horizontalSM,
                      Text(
                        'Reference: ${bill.referenceId}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.verticalMD,
            ],

            // AI Recommendation
            if (bill.status == 'Pending')
              Consumer<RecommendationProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (provider.recommendation != null) {
                    return RecommendationPanel(
                      recommendation: provider.recommendation!.displayText,
                      rationale: provider.rationale ?? provider.recommendation!.rationale,
                      onAccept: () {
                        context.push('/payment/confirm/${bill.id}');
                      },
                    );
                  }

                  if (provider.error != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text(
                        'Unable to load recommendation',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),

            AppSpacing.verticalLG,

            // Reminder Status (if any)
            Consumer<BillsProvider>(
              builder: (context, billsProvider, _) {
                final reminder = billsProvider.reminders[bill.id];
                if (reminder != null) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: AppSpacing.cardPadding,
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: AppRadius.cardRadius,
                      border: Border.all(color: AppColors.info),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.alarm, color: AppColors.info),
                        AppSpacing.horizontalSM,
                        Expanded(
                          child: Text(
                            'Reminder set for ${Formatters.formatDate(reminder.reminderDate)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.info,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.info),
                          onPressed: () async {
                            await context.read<BillsProvider>().removeReminder(bill.id!);
                          },
                          tooltip: 'Remove reminder',
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Action buttons
            if (bill.status == 'Pending')
              Consumer<BillsProvider>(
                builder: (context, billsProvider, _) {
                  final isFarOut = daysUntilDue > 7;

                  return Column(
                    children: [
                      // If due > 7 days, "Set Reminder" is Primary
                      if (isFarOut) ...[
                        PrimaryButton(
                          label: 'Set Reminder',
                          icon: Icons.alarm_add,
                          onPressed: () => _showDatePicker(context, bill),
                        ),
                        AppSpacing.verticalSM,
                        SecondaryButton(
                          label: 'Pay Now',
                          icon: Icons.payment,
                          onPressed: () {
                            context.push('/payment/confirm/${bill.id}');
                          },
                        ),
                      ] else ...[
                        // Otherwise "Pay Now" is Primary
                        PrimaryButton(
                          label: 'Pay Now',
                          icon: Icons.payment,
                          onPressed: () {
                            context.push('/payment/confirm/${bill.id}');
                          },
                        ),
                        AppSpacing.verticalSM,
                        SecondaryButton(
                          label: 'Mark as Paid',
                          icon: Icons.check,
                          onPressed: () {
                            ConfirmationDialog.show(
                              context: context,
                              title: 'Mark as Paid?',
                              message: 'This will mark "${bill.payeeName}" as paid.',
                              confirmLabel: 'Mark Paid',
                              onConfirm: () async {
                                await context.read<BillsProvider>().markAsPaid(bill.id!);
                                _loadBill();
                              },
                            );
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),

            if (bill.status == 'Scheduled') ...[
              Container(
                 width: double.infinity,
                 padding: AppSpacing.cardPadding,
                 margin: const EdgeInsets.only(bottom: AppSpacing.md),
                 decoration: BoxDecoration(
                   color: AppColors.surfaceVariant,
                   borderRadius: AppRadius.cardRadius,
                   border: Border.all(color: AppColors.scheduled),
                 ),
                 child: Column(
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         const Icon(Icons.schedule, color: AppColors.scheduled, size: 24),
                         AppSpacing.horizontalSM,
                         Text(
                           'Payment Scheduled',
                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
                             color: AppColors.scheduled,
                             fontWeight: FontWeight.w600,
                           ),
                         ),
                       ],
                     ),
                     if (bill.referenceId != null) ...[
                        AppSpacing.verticalXS,
                        Text(
                          'Ref: ${bill.referenceId}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                     ],
                   ],
                 ),
              ),

              PrimaryButton(
                label: 'Mark as Paid (Simulate)',
                icon: Icons.check_circle_outline,
                onPressed: () {
                   ConfirmationDialog.show(
                    context: context,
                    title: 'Complete Payment?',
                    message: 'This will simulate the completion of the scheduled payment for "${bill.payeeName}".',
                    confirmLabel: 'Complete',
                    onConfirm: () async {
                      final billsProvider = context.read<BillsProvider>();
                      final paymentProvider = context.read<PaymentProvider>();
                      final success = await paymentProvider.completeScheduledPayment(bill.id!);

                      if (!context.mounted) return;

                      if (success) {
                         _loadBill();
                         // Also reload bills provider to update list
                         billsProvider.loadBills();
                      } else {
                         Toast.show(context, paymentProvider.error ?? 'Failed to complete payment', type: ToastType.error);
                      }
                    },
                  );
                },
              ),
            ],

            if (bill.status == 'Paid') ...[
              Container(
                width: double.infinity,
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: AppRadius.cardRadius,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success, size: 24),
                    AppSpacing.horizontalSM,
                    Text(
                      'This bill has been paid',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            AppSpacing.verticalXL,
          ],
        ),
      ),
    );
  }
}
