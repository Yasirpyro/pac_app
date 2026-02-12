import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../core/utils/formatters.dart';
import 'category_icon.dart';
import 'status_badge.dart';

class BillCard extends StatelessWidget {
  final Map<String, dynamic> bill;
  final VoidCallback onTap;

  const BillCard({
    super.key,
    required this.bill,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String payeeName = bill['payeeName'] as String;
    final double amount = bill['amount'] as double;
    final DateTime dueDate = bill['dueDate'] as DateTime;
    final String category = bill['category'] as String;
    final String status = bill['status'] as String;
    final DateTime? reminderDate = bill['reminderDate'] as DateTime?;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardRadius,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            children: [
              // Category Icon
              CategoryIcon(category: category),
              AppSpacing.horizontalMD,

              // Bill Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payeeName,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.verticalXS,
                    Text(
                      'Due ${Formatters.formatDate(dueDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    if (reminderDate != null) ...[
                      AppSpacing.verticalXS,
                      Row(
                        children: [
                          const Icon(Icons.alarm, size: 12, color: AppColors.info),
                          const SizedBox(width: 4),
                          Text(
                            'Remind: ${Formatters.formatDate(reminderDate)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.info,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Amount + Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCurrency(amount),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  AppSpacing.verticalXS,
                  StatusBadge(status: status, dueDate: dueDate),
                ],
              ),

              AppSpacing.horizontalSM,

              // Chevron
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
