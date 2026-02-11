import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final DateTime dueDate;

  const StatusBadge({
    super.key,
    required this.status,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getBadgeConfig();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: AppRadius.badgeRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (config.icon != null) ...[
            Icon(config.icon, size: 12, color: config.textColor),
            AppSpacing.horizontalXS,
          ],
          Text(
            config.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: config.textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _getBadgeConfig() {
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;

    // Check for overdue first
    if (status == 'Pending' && daysUntilDue < 0) {
      return _BadgeConfig(
        label: 'OVERDUE',
        backgroundColor: AppColors.errorLight,
        textColor: AppColors.error,
        icon: Icons.warning,
      );
    }

    switch (status) {
      case 'Paid':
        return _BadgeConfig(
          label: 'PAID',
          backgroundColor: AppColors.successLight,
          textColor: AppColors.success,
          icon: Icons.check,
        );
      case 'Scheduled':
        return _BadgeConfig(
          label: 'SCHEDULED',
          backgroundColor: AppColors.scheduledLight,
          textColor: AppColors.scheduled,
          icon: Icons.schedule,
        );
      case 'Queued':
        return _BadgeConfig(
          label: 'QUEUED',
          backgroundColor: AppColors.infoLight,
          textColor: AppColors.info,
          icon: Icons.hourglass_empty,
        );
      case 'Pending':
        if (daysUntilDue <= 3) {
          return _BadgeConfig(
            label: 'DUE SOON',
            backgroundColor: AppColors.warningLight,
            textColor: AppColors.warning,
            icon: null,
          );
        } else if (daysUntilDue <= 7) {
          return _BadgeConfig(
            label: '$daysUntilDue DAYS',
            backgroundColor: AppColors.infoLight,
            textColor: AppColors.info,
            icon: null,
          );
        }
        return _BadgeConfig(
          label: 'PENDING',
          backgroundColor: AppColors.surfaceVariant,
          textColor: AppColors.textSecondary,
          icon: null,
        );
      default:
        return _BadgeConfig(
          label: status.toUpperCase(),
          backgroundColor: AppColors.surfaceVariant,
          textColor: AppColors.textSecondary,
          icon: null,
        );
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  _BadgeConfig({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });
}
