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
import '../../providers/recommendation_provider.dart';
import '../../widgets/recommendation_panel.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/loading_state.dart';
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

            // Action buttons
            if (bill.status == 'Pending') ...[
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
