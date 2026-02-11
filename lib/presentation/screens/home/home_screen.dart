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
                      Row(
                        children: [
                          Expanded(
                            child: InfoCard(
                              title: 'Total Pending',
                              value: Formatters.formatCurrency(bills.totalPendingAmount),
                              icon: Icons.receipt_long,
                              color: AppColors.warning,
                            ),
                          ),
                          AppSpacing.horizontalSM,
                          Expanded(
                            child: InfoCard(
                              title: 'Scheduled',
                              value: '${bills.scheduledBills.length}',
                              icon: Icons.schedule,
                              color: AppColors.scheduled,
                            ),
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
