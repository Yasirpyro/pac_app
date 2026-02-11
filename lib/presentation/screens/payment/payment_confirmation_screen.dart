import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/bill_model.dart';
import '../../../data/models/cashflow_input_model.dart';
import '../../../data/services/safety_check_service.dart';
import '../../../data/services/recommendation_service.dart';
import '../../../data/services/ai_service.dart';
import '../../../data/database/dao/bill_history_dao.dart';
import '../../../data/database/dao/payment_dao.dart';
import '../../../data/database/dao/settings_dao.dart';
import '../../../domain/entities/recommendation.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_radius.dart';
import '../../providers/bills_provider.dart';
import '../../providers/cashflow_provider.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/warning_banner.dart';
import '../../widgets/recommendation_panel.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/toast.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final int billId;
  final DateTime scheduledDate;

  const PaymentConfirmationScreen({
    super.key,
    required this.billId,
    required this.scheduledDate,
  });

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  BillModel? _bill;
  SafetyCheckResult? _safetyCheck;
  Recommendation? _recommendation;
  String? _rationale;
  bool _isLoading = true;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final bill = await context.read<BillsProvider>().getBillById(widget.billId);
    if (bill == null || !mounted) return;

    final cashflow = context.read<CashflowProvider>();

    // Build cashflow model for services
    final cashflowModel = CashflowInputModel(
      currentBalance: cashflow.currentBalance,
      nextPaydayDate: cashflow.nextPayday,
      safetyBuffer: cashflow.safetyBuffer,
    );

    // Run safety checks
    final safetyService = SafetyCheckService(
      historyDao: BillHistoryDao(),
      paymentDao: PaymentDao(),
      settingsDao: SettingsDao(),
    );
    final safetyResult = await safetyService.checkPaymentSafety(
      billAmount: bill.amount,
      payeeName: bill.payeeName,
      scheduledDate: widget.scheduledDate,
      cashflow: cashflowModel,
    );

    // Get recommendation
    final recommendationService = RecommendationService();
    final recommendation = recommendationService.getRecommendation(
      bill: bill,
      cashflow: cashflowModel,
    );

    // Get AI rationale
    final aiService = AIService(settingsDao: SettingsDao());
    final rationale = await aiService.generateRationale(
      payee: bill.payeeName,
      amount: bill.amount,
      dueDate: bill.dueDate.toIso8601String().split('T')[0],
      currentBalance: cashflow.currentBalance,
      nextPayday: cashflow.nextPayday.toIso8601String().split('T')[0],
      safetyBuffer: cashflow.safetyBuffer,
      recommendation: recommendation.type.name,
    );

    if (mounted) {
      setState(() {
        _bill = bill;
        _safetyCheck = safetyResult;
        _recommendation = recommendation;
        _rationale = rationale;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Confirm Payment')),
        body: const LoadingState(message: 'Analyzing payment...'),
      );
    }

    if (_bill == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Confirm Payment')),
        body: const Center(child: Text('Bill not found')),
      );
    }

    final bill = _bill!;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Payment')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment summary card
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  children: [
                    Icon(Icons.payment, size: 48, color: AppColors.primary),
                    AppSpacing.verticalMD,
                    Text(
                      'Pay ${bill.payeeName}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    AppSpacing.verticalSM,
                    Text(
                      Formatters.formatCurrency(bill.amount),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    AppSpacing.verticalSM,
                    Text(
                      'Scheduled for ${Formatters.formatDate(widget.scheduledDate)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            AppSpacing.verticalMD,

            // Safety warnings
            if (_safetyCheck != null && _safetyCheck!.hasWarnings)
              ..._safetyCheck!.messages.map((msg) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: WarningBanner(
                  type: _safetyCheck!.hasInsufficientFunds
                      ? WarningType.error
                      : WarningType.warning,
                  title: 'Safety Check',
                  message: msg,
                ),
              )),

            AppSpacing.verticalSM,

            // AI Recommendation
            if (_recommendation != null)
              RecommendationPanel(
                recommendation: _recommendation!.displayText,
                rationale: _rationale ?? '',
                onAccept: () {},
              ),

            AppSpacing.verticalLG,

            // Balance impact
            Consumer<CashflowProvider>(
              builder: (context, cashflow, _) {
                final newBalance = cashflow.currentBalance - bill.amount;
                final isLow = newBalance < cashflow.safetyBuffer;
                return Card(
                  child: Padding(
                    padding: AppSpacing.cardPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Balance Impact',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppSpacing.verticalSM,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Current Balance'),
                            Text(Formatters.formatCurrency(cashflow.currentBalance)),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Payment Amount'),
                            Text(
                              '- ${Formatters.formatCurrency(bill.amount)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Remaining',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              Formatters.formatCurrency(newBalance),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isLow ? AppColors.error : AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            AppSpacing.verticalXL,

            // Action buttons
            PrimaryButton(
              label: 'Authenticate & Pay',
              icon: Icons.fingerprint,
              isLoading: _isAuthenticating,
              onPressed: _processPayment,
            ),
            AppSpacing.verticalSM,
            SecondaryButton(
              label: 'Cancel',
              onPressed: () => context.pop(),
            ),

            AppSpacing.verticalMD,

            // Disclaimer
            Container(
              width: double.infinity,
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadius.cardRadius,
              ),
              child: Text(
                'This is a simulated payment. No real funds will be transferred.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            AppSpacing.verticalXL,
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isAuthenticating = true);

    final paymentProvider = context.read<PaymentProvider>();
    final authenticated = await paymentProvider.authenticate();

    if (!authenticated) {
      if (mounted) {
        setState(() => _isAuthenticating = false);
        Toast.show(context, 'Authentication failed', type: ToastType.error);
      }
      return;
    }

    final success = await paymentProvider.schedulePayment(
      billId: widget.billId,
      scheduledDate: widget.scheduledDate,
    );

    if (mounted) {
      setState(() => _isAuthenticating = false);

      if (success) {
        // Reload bills and cashflow
        context.read<BillsProvider>().loadBills();
        context.read<CashflowProvider>().loadCashflow();

        context.go('/payment/success', extra: {
          'referenceId': paymentProvider.lastReferenceId,
          'amount': _bill!.amount,
          'payeeName': _bill!.payeeName,
          'scheduledDate': widget.scheduledDate,
        });
      } else {
        Toast.show(context, paymentProvider.error ?? 'Payment failed', type: ToastType.error);
      }
    }
  }
}
