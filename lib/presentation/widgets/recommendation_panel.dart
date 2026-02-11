import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import 'primary_button.dart';

class RecommendationPanel extends StatelessWidget {
  final String recommendation;
  final String rationale;
  final VoidCallback onAccept;
  final VoidCallback? onDismiss;

  const RecommendationPanel({
    super.key,
    required this.recommendation,
    required this.rationale,
    required this.onAccept,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              AppSpacing.horizontalSM,
              Text(
                'AI Recommendation',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppColors.textSecondary,
                ),
            ],
          ),

          AppSpacing.verticalMD,

          // Recommendation
          Text(
            recommendation,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),

          AppSpacing.verticalSM,

          // Rationale
          Text(
            rationale,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),

          AppSpacing.verticalMD,

          // Action Button
          PrimaryButton(
            label: recommendation.contains('Schedule')
                ? 'Schedule Payment'
                : 'Pay Now',
            icon: recommendation.contains('Schedule')
                ? Icons.schedule
                : Icons.payment,
            onPressed: onAccept,
          ),

          AppSpacing.verticalSM,

          // Disclaimer
          Text(
            'This is a suggestion. You decide what\'s best for your finances.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textHint,
                  fontStyle: FontStyle.italic,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
