import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

enum ToastType { success, error, info, warning }

class Toast {
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final config = _getConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(config.icon, color: Colors.white, size: 20),
            AppSpacing.horizontalSM,
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: config.color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static _ToastConfig _getConfig(ToastType type) {
    switch (type) {
      case ToastType.success:
        return _ToastConfig(
          icon: Icons.check_circle,
          color: AppColors.success,
        );
      case ToastType.error:
        return _ToastConfig(
          icon: Icons.error,
          color: AppColors.error,
        );
      case ToastType.info:
        return _ToastConfig(
          icon: Icons.info,
          color: AppColors.info,
        );
      case ToastType.warning:
        return _ToastConfig(
          icon: Icons.warning,
          color: AppColors.warning,
        );
    }
  }
}

class _ToastConfig {
  final IconData icon;
  final Color color;

  _ToastConfig({
    required this.icon,
    required this.color,
  });
}
