import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../providers/bills_provider.dart';
import '../../widgets/bill_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';

class BillListScreen extends StatefulWidget {
  const BillListScreen({super.key});

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BillsProvider>().loadBills();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bills'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.onPrimary,
          labelColor: AppColors.onPrimary,
          unselectedLabelColor: AppColors.onPrimary.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Scheduled'),
            Tab(text: 'Paid'),
          ],
        ),
      ),
      body: Consumer<BillsProvider>(
        builder: (context, bills, _) {
          if (bills.isLoading) {
            return const LoadingState(message: 'Loading bills...');
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBillList(bills.bills),
              _buildBillList(bills.pendingBills),
              _buildBillList(bills.scheduledBills),
              _buildBillList(bills.paidBills),
            ],
          );
        },
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

  Widget _buildBillList(List<dynamic> bills) {
    if (bills.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long,
        title: 'No bills found',
        message: 'Add a bill to get started with payment tracking.',
        actionLabel: 'Add Bill',
        onAction: () => context.push('/add-bill'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<BillsProvider>().loadBills(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        itemCount: bills.length,
        itemBuilder: (context, index) {
          final bill = bills[index];
          return BillCard(
            bill: {
              'id': bill.id,
              'payeeName': bill.payeeName,
              'amount': bill.amount,
              'dueDate': bill.dueDate,
              'category': bill.category,
              'status': bill.status,
            },
            onTap: () => context.push('/bills/${bill.id}'),
          );
        },
      ),
    );
  }
}
