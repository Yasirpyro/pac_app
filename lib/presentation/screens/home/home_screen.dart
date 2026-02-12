import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_radius.dart';
import '../../providers/bills_provider.dart';
import '../../providers/cashflow_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/bill_card.dart';
import '../../widgets/info_card.dart';
import '../../widgets/warning_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BillsProvider>().loadBills();
        context.read<CashflowProvider>().loadCashflow();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Assurance Copilot'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (!context.mounted) return;
          final billsProvider = context.read<BillsProvider>();
          final cashflowProvider = context.read<CashflowProvider>();

          await billsProvider.loadBills();
          if (context.mounted) {
            await cashflowProvider.loadCashflow();
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Maintenance mode warning
              Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  if (!settings.isMaintenanceMode) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: WarningBanner(
                      type: WarningType.maintenance,
                      title: 'Maintenance Mode Active',
                      message: 'Service resumes at 6:00 AM. You can queue payments.',
                      actionLabel: 'Go to Maintenance',
                      onAction: () => context.go('/maintenance'),
                    ),
                  );
                },
              ),

              // Queued Payments Review (Post-Maintenance)
              Consumer<BillsProvider>(
                builder: (context, bills, _) {
                  final queued = bills.queuedBills;
                  if (queued.isEmpty) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.maintenanceLight,
                        borderRadius: AppRadius.cardRadius,
                        border: Border.all(color: AppColors.maintenance),
                      ),
                      child: Padding(
                        padding: AppSpacing.cardPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.playlist_add_check, color: AppColors.maintenance),
                                AppSpacing.horizontalSM,
                                Text(
                                  'Queued payment intents',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.maintenance,
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.verticalSM,
                            Text(
                              'You queued these during maintenance. Review and pay now (simulated) or remove.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            AppSpacing.verticalMD,
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () => context.push('/maintenance/review'),
                                icon: const Icon(Icons.rate_review),
                                label: const Text('Review queued payments'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.maintenance,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // One-tap Pay for Due Today/Overdue
              Consumer<BillsProvider>(
                builder: (context, bills, _) {
                  final dueNow = bills.billsDueTodayOrOverdue;
                  if (dueNow.isEmpty) return const SizedBox.shrink();

                  final bill = dueNow.first;
                  final days = bill.dueDate.difference(DateTime.now()).inDays;
                  final dueText = days < 0 ? 'Overdue' : 'Due Today';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Card(
                      elevation: 4,
                      color: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
                      child: InkWell(
                        onTap: () => context.push('/payment/confirm/${bill.id}'),
                        borderRadius: AppRadius.cardRadius,
                        child: Padding(
                          padding: AppSpacing.cardPadding,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.flash_on, color: Colors.white),
                              ),
                              AppSpacing.horizontalMD,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pay in 1 tap',
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${bill.payeeName} ($dueText)',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      Formatters.formatCurrency(bill.amount),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Quick stats row
              Consumer<CashflowProvider>(
                builder: (context, cashflow, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: InfoCard(
                          title: 'Current Balance',
                          value: Formatters.formatCurrency(cashflow.currentBalance),
                          icon: Icons.account_balance_wallet,
                          color: AppColors.success,
                          onTap: () => context.push('/settings/cashflow'),
                        ),
                      ),
                      AppSpacing.horizontalSM,
                      Expanded(
                        child: InfoCard(
                          title: 'Next Payday',
                          value: Formatters.formatShortDate(cashflow.nextPayday),
                          icon: Icons.calendar_today,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  );
                },
              ),

              AppSpacing.verticalMD,

              // Bills needing attention
              Consumer<BillsProvider>(
                builder: (context, bills, _) {
                  final attention = bills.billsNeedingAttention;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bills Needing Attention',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (attention.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xxs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius: AppRadius.cardRadius,
                              ),
                              child: Text(
                                '${attention.length}',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      AppSpacing.verticalSM,

                      if (bills.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (attention.isEmpty)
                        Card(
                          child: Padding(
                            padding: AppSpacing.cardPadding,
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: AppColors.success, size: 32),
                                AppSpacing.horizontalMD,
                                Expanded(
                                  child: Text(
                                    'All caught up! No bills need attention right now.',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...attention.take(3).map((bill) => BillCard(
                          bill: {
                            'id': bill.id,
                            'payeeName': bill.payeeName,
                            'amount': bill.amount,
                            'dueDate': bill.dueDate,
                            'category': bill.category,
                            'status': bill.status,
                          },
                          onTap: () => context.push('/bills/${bill.id}'),
                        )),

                      if (attention.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: TextButton(
                            onPressed: () => context.go('/bills'),
                            child: Text('View all ${attention.length} bills'),
                          ),
                        ),
                    ],
                  );
                },
              ),

              AppSpacing.verticalLG,

              // Summary stats
              Consumer<BillsProvider>(
                builder: (context, bills, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Summary',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.verticalSM,
                      Column(
                        children: [
                          // Row 1: Pending (Full Width)
                          SizedBox(
                            width: double.infinity,
                            child: InfoCard(
                              title: 'Pending Bills',
                              value: Formatters.formatCurrency(bills.totalPendingAmount),
                              icon: Icons.receipt_long,
                              color: AppColors.warning,
                              onTap: () => context.go('/bills'),
                            ),
                          ),
                          AppSpacing.verticalSM,
                          // Row 2: Scheduled & Reminders (Split)
                          Row(
                            children: [
                              Expanded(
                                child: InfoCard(
                                  title: 'Scheduled',
                                  value: '${bills.scheduledBills.length}',
                                  icon: Icons.schedule,
                                  color: AppColors.scheduled,
                                  onTap: () {
                                    // Navigate to bills tab and switch to Scheduled tab (index 2)
                                    // Note: context.go('/bills') defaults to tab 0.
                                    // Ideally pass a query param or extra, but for now simple nav.
                                    context.go('/bills');
                                  },
                                ),
                              ),
                              AppSpacing.horizontalSM,
                              Expanded(
                                child: InfoCard(
                                  title: 'Reminders',
                                  value: '${bills.reminders.length}',
                                  icon: Icons.alarm,
                                  color: AppColors.info,
                                  onTap: () => context.go('/bills'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

              AppSpacing.verticalLG,

              // Demo disclaimer
              Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  if (!settings.isDemoMode) return const SizedBox.shrink();
                  return Container(
                    width: double.infinity,
                    padding: AppSpacing.cardPadding,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: AppRadius.cardRadius,
                    ),
                    child: Text(
                      'This is a demo. No real customer data or financial '
                      'transactions are involved.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),

              AppSpacing.verticalXL,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-bill'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Add Bill'),
      ),
    );
  }
}
