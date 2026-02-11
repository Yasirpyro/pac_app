import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';

enum WarningType { warning, error, info, maintenance }

class WarningBanner extends StatelessWidget {
  final WarningType type;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  const WarningBanner({
    super.key,
    required this.type,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(config.icon, color: config.iconColor, size: 20),
              AppSpacing.horizontalSM,
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: config.iconColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          if (message != null) ...[
            AppSpacing.verticalSM,
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            AppSpacing.verticalSM,
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: config.iconColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _WarningConfig _getConfig() {
    switch (type) {
      case WarningType.warning:
        return _WarningConfig(
          backgroundColor: AppColors.warningLight,
          borderColor: AppColors.warning,
          iconColor: AppColors.warning,
          icon: Icons.warning_amber,
        );
      case WarningType.error:
        return _WarningConfig(
          backgroundColor: AppColors.errorLight,
          borderColor: AppColors.error,
          iconColor: AppColors.error,
          icon: Icons.error_outline,
        );
      case WarningType.info:
        return _WarningConfig(
          backgroundColor: AppColors.infoLight,
          borderColor: AppColors.info,
          iconColor: AppColors.info,
          icon: Icons.info_outline,
        );
      case WarningType.maintenance:
        return _WarningConfig(
          backgroundColor: AppColors.maintenanceLight,
          borderColor: AppColors.maintenance,
          iconColor: AppColors.maintenance,
          icon: Icons.engineering,
        );
    }
  }
}

class _WarningConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;

  _WarningConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.icon,
  });
}
