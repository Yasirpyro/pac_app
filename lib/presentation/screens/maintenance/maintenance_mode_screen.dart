import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/bills_provider.dart';
import '../../../data/database/dao/payment_dao.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/models/bill_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_radius.dart';
import '../../../core/utils/formatters.dart';
import '../../widgets/warning_banner.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/info_card.dart';
import '../../widgets/category_icon.dart';

class MaintenanceModeScreen extends StatefulWidget {
  const MaintenanceModeScreen({super.key});

  @override
  State<MaintenanceModeScreen> createState() => _MaintenanceModeScreenState();
}

class _MaintenanceModeScreenState extends State<MaintenanceModeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PaymentDao _paymentDao = PaymentDao();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billsProvider = context.watch<BillsProvider>();
    final queuedBills = billsProvider.queuedBills;
    final pendingBills = billsProvider.pendingBills;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Maintenance Mode'),
        backgroundColor: AppColors.maintenance,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Queued Payments'),
            Tab(text: 'Emergency Options'),
          ],
        ),
      ),
      body: Column(
        children: [
          WarningBanner(
            type: WarningType.maintenance,
            title: 'Maintenance Mode Active',
            message:
                'Limited service - Payments cannot be processed immediately. You can queue payment intents.',
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQueuedPaymentsTab(queuedBills),
                _buildEmergencyOptionsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0 && pendingBills.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showBillSelectionDialog(context, pendingBills),
              backgroundColor: AppColors.maintenance,
              icon: const Icon(Icons.add),
              label: const Text('Queue Payment'),
            )
          : null,
    );
  }

  Widget _buildQueuedPaymentsTab(List<BillModel> queuedBills) {
    return FutureBuilder<List<PaymentModel>>(
      future: _paymentDao.getQueuedPayments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final queuedPayments = snapshot.data!;

        if (queuedPayments.isEmpty) {
          return EmptyState(
            icon: Icons.playlist_add_check,
            title: 'No Queued Payments',
            message: 'No bills are queued during maintenance period.',
          );
        }

        return ListView.builder(
          padding: AppSpacing.screenPadding,
          itemCount: queuedPayments.length,
          itemBuilder: (context, index) {
            final payment = queuedPayments[index];
            return FutureBuilder<BillModel?>(
              future: context.read<BillsProvider>().getBillById(payment.billId),
              builder: (context, billSnapshot) {
                if (!billSnapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final bill = billSnapshot.data!;

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.maintenanceLight,
                      child: Icon(
                        Icons.receipt_long,
                        color: AppColors.maintenance,
                      ),
                    ),
                    title: Text(
                      bill.payeeName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Due: ${Formatters.formatDate(bill.dueDate)}\nRef: ${payment.referenceId}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatters.formatCurrency(payment.amount),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.maintenanceLight,
                            borderRadius: AppRadius.cardRadius,
                          ),
                          child: Text(
                            'Queued',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.maintenance,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmergencyOptionsTab() {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        AppSpacing.verticalMD,
        Text(
          'Need Help Right Now?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        AppSpacing.verticalLG,
        InfoCard(
          title: '24/7 Support',
          value: '1-800-BANK-HELP',
          icon: Icons.phone,
          color: AppColors.info,
          onTap: () {},
        ),
        AppSpacing.verticalMD,
        InfoCard(
          title: 'Find ATM',
          value: 'Locate nearby ATMs',
          icon: Icons.atm,
          color: AppColors.primary,
          onTap: () {},
        ),
        AppSpacing.verticalMD,
        InfoCard(
          title: 'Branch Hours',
          value: 'Mon-Fri: 9 AM - 5 PM',
          icon: Icons.business,
          color: AppColors.success,
        ),
        AppSpacing.verticalLG,
        Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(color: AppColors.info),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.info),
              AppSpacing.horizontalSM,
              Expanded(
                child: Text(
                  'Queued payments are INTENTS only. They will process automatically when service resumes.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBillSelectionDialog(BuildContext context, List<BillModel> bills) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Bill to Queue',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return ListTile(
                    leading: CategoryIcon(
                      category: bill.category,
                      size: 20,
                    ),
                    title: Text(
                      bill.payeeName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Due ${Formatters.formatDate(bill.dueDate)} • ${bill.category}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Formatters.formatCurrency(bill.amount),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close bottom sheet
                      context.push('/maintenance/queue/${bill.id}');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
