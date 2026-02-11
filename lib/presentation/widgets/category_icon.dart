import 'package:flutter/material.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

class CategoryIcon extends StatelessWidget {
  final String category;
  final double size;

  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color color;

    switch (category) {
      case 'Utilities':
        iconData = Icons.bolt;
        color = Colors.amber;
        break;
      case 'Insurance':
        iconData = Icons.shield;
        color = Colors.blue;
        break;
      case 'Subscriptions':
        iconData = Icons.subscriptions;
        color = Colors.purple;
        break;
      default:
        iconData = Icons.receipt_long;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Icon(iconData, size: size, color: color),
    );
  }
}
