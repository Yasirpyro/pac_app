import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_radius.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppSpacing.verticalXL,
            Icon(Icons.account_balance, size: 64, color: AppColors.primary),
            AppSpacing.verticalMD,
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSM,
            Text(
              'Version ${AppConstants.appVersion}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.verticalLG,
            Text(
              'AI-assisted utility bill payment timing recommendations '
              'with safety checks and maintenance mode continuity.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalLG,
            const Divider(),
            AppSpacing.verticalLG,
            Text(
              'PROCOM \'26 AI in Banking Hackathon',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.verticalXL,
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: AppRadius.cardRadius,
                border: Border.all(color: AppColors.warning),
              ),
              child: Text(
                'This is a prototype demo application. No real customer data, '
                'bank accounts, or financial transactions are involved. '
                'All data is synthetic and for demonstration purposes only.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
