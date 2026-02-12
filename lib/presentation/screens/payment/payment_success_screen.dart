import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_radius.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String referenceId;
  final double amount;
  final String payeeName;
  final DateTime scheduledDate;
  final bool isPayNow;
  final bool isQueued;

  const PaymentSuccessScreen({
    super.key,
    required this.referenceId,
    required this.amount,
    required this.payeeName,
    required this.scheduledDate,
    this.isPayNow = false,
    this.isQueued = false,
  });

  @override
  Widget build(BuildContext context) {
    String title = 'Payment Scheduled!';
    if (isPayNow) title = 'Payment Completed!';
    if (isQueued) title = 'Payment Queued';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isQueued ? AppColors.warningLight : AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isQueued ? Icons.hourglass_top : Icons.check_circle,
                  size: 80,
                  color: isQueued ? AppColors.warning : AppColors.success,
                ),
              ),

              AppSpacing.verticalLG,

              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isQueued ? AppColors.warning : AppColors.success,
                ),
              ),

              AppSpacing.verticalMD,

              Text(
                payeeName,
                style: Theme.of(context).textTheme.titleLarge,
              ),

              AppSpacing.verticalSM,

              Text(
                Formatters.formatCurrency(amount),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              AppSpacing.verticalSM,

              if (!isPayNow && !isQueued)
                Text(
                  'Scheduled for ${Formatters.formatDate(scheduledDate)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              if (isPayNow)
                 Text(
                  'Paid on ${Formatters.formatDate(DateTime.now())}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              if (isQueued)
                 Text(
                  'Queued for processing when maintenance ends',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

              AppSpacing.verticalLG,

              // Reference ID card
              Container(
                width: double.infinity,
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadius.cardRadius,
                ),
                child: Column(
                  children: [
                    Text(
                      'Reference ID',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppSpacing.verticalXS,
                    SelectableText(
                      referenceId,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action buttons
              PrimaryButton(
                label: 'View Pending Payments',
                icon: Icons.checklist,
                onPressed: () => context.go('/urgent'),
              ),
              AppSpacing.verticalSM,
              SecondaryButton(
                label: 'View Balance',
                onPressed: () => context.push('/settings/cashflow'),
              ),
              AppSpacing.verticalSM,
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Return Home'),
              ),

              AppSpacing.verticalLG,

              // Disclaimer
              Text(
                'This is a simulated payment. No real funds were transferred.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              AppSpacing.verticalMD,
            ],
          ),
        ),
      ),
    );
  }
}
