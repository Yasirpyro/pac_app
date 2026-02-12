import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/bill_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_radius.dart';
import '../../providers/bills_provider.dart';
import '../../widgets/empty_state.dart';

class UrgentBillsScreen extends StatefulWidget {
  const UrgentBillsScreen({super.key});

  @override
  State<UrgentBillsScreen> createState() => _UrgentBillsScreenState();
}

class _UrgentBillsScreenState extends State<UrgentBillsScreen> {
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
        title: const Text('Urgent Attention Needed'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: Consumer<BillsProvider>(
        builder: (context, billsProvider, _) {
          // Filter logic: Due today or Overdue
          final urgentBills = billsProvider.billsDueTodayOrOverdue;

          // Sort: Overdue first, then Due Today
          urgentBills.sort((a, b) {
            final aDate = DateTime(a.dueDate.year, a.dueDate.month, a.dueDate.day);
            final bDate = DateTime(b.dueDate.year, b.dueDate.month, b.dueDate.day);

            return aDate.compareTo(bDate); // Older dates (overdue) first
          });

          if (billsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (urgentBills.isEmpty) {
            return EmptyState(
              icon: Icons.check_circle,
              title: 'No Urgent Bills',
              message: 'Great job! You have no bills due today or overdue.',
              actionLabel: 'Go to Dashboard',
              onAction: () => context.go('/home'),
            );
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: AppSpacing.cardPadding,
                color: AppColors.errorLight,
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                    AppSpacing.horizontalSM,
                    Expanded(
                      child: Text(
                        'These bills require immediate action to avoid late fees.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: AppSpacing.screenPadding,
                  itemCount: urgentBills.length,
                  itemBuilder: (context, index) {
                    final bill = urgentBills[index];
                    return _buildUrgentBillCard(context, bill);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUrgentBillCard(BuildContext context, BillModel bill) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(bill.dueDate.year, bill.dueDate.month, bill.dueDate.day);
    final isOverdue = dueDate.isBefore(today);

    final statusColor = isOverdue ? AppColors.error : AppColors.warning;
    final statusText = isOverdue ? 'OVERDUE' : 'DUE TODAY';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRadius,
        side: BorderSide(color: statusColor, width: 1.5),
      ),
      child: InkWell(
        onTap: () => context.push('/bills/${bill.id}'),
        borderRadius: AppRadius.cardRadius,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(bill.amount),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalMD,
              Row(
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
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
              const Divider(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.push('/payment/confirm/${bill.id}?isPayNow=true'),
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Pay Now (Simulated)'),
                  style: FilledButton.styleFrom(
                    backgroundColor: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
