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

  const PaymentSuccessScreen({
    super.key,
    required this.referenceId,
    required this.amount,
    required this.payeeName,
    required this.scheduledDate,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppColors.success,
                ),
              ),

              AppSpacing.verticalLG,

              Text(
                'Payment Scheduled!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
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

              Text(
                'Scheduled for ${Formatters.formatDate(scheduledDate)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
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
                label: 'Return Home',
                icon: Icons.home,
                onPressed: () => context.go('/home'),
              ),
              AppSpacing.verticalSM,
              SecondaryButton(
                label: 'View All Bills',
                onPressed: () => context.go('/bills'),
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
