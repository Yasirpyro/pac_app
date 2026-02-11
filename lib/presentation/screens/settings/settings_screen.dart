import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/settings_provider.dart';
import '../../providers/cashflow_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/toast.dart';
import '../../widgets/destructive_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final cashflowProvider = context.watch<CashflowProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Cashflow Settings'),
          _buildListTile(
            context,
            title: 'Current Balance',
            subtitle: Formatters.formatCurrency(cashflowProvider.currentBalance),
            icon: Icons.account_balance_wallet,
            onTap: () => context.push('/settings/cashflow'),
          ),
          _buildListTile(
            context,
            title: 'Next Payday',
            subtitle: Formatters.formatDate(cashflowProvider.nextPayday),
            icon: Icons.calendar_today,
            onTap: () => context.push('/settings/cashflow'),
          ),
          _buildListTile(
            context,
            title: 'Safety Buffer',
            subtitle: Formatters.formatCurrency(cashflowProvider.safetyBuffer),
            icon: Icons.shield,
            onTap: () => context.push('/settings/cashflow'),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Payment Limits'),
          _buildListTile(
            context,
            title: 'Daily Payment Cap',
            subtitle: Formatters.formatCurrency(settingsProvider.dailyPaymentCap),
            icon: Icons.credit_card,
            onTap: () => _showDailyCapDialog(context, settingsProvider),
          ),
          const Divider(),
          _buildSectionHeader(context, 'System Settings'),
          SwitchListTile(
            title: const Text('Maintenance Mode'),
            subtitle: const Text('Toggle system maintenance simulation'),
            value: settingsProvider.isMaintenanceMode,
            onChanged: (value) => _toggleMaintenanceMode(context, value, settingsProvider),
            secondary: const Icon(Icons.engineering),
          ),
          SwitchListTile(
            title: const Text('Demo Mode'),
            subtitle: const Text('Use cached AI responses'),
            value: settingsProvider.isDemoMode,
            onChanged: (value) => settingsProvider.setDemoMode(value),
            secondary: const Icon(Icons.science),
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Enable payment reminders'),
            value: settingsProvider.notificationsEnabled,
            onChanged: (value) => settingsProvider.setNotificationsEnabled(value),
            secondary: const Icon(Icons.notifications),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Data & Privacy'),
          _buildListTile(
            context,
            title: 'View Audit Log',
            subtitle: 'See all app activity',
            icon: Icons.history,
            onTap: () => context.push('/settings/audit-log'),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: DestructiveButton(
              label: 'Reset Demo Data',
              onPressed: () => _resetDemoData(context, settingsProvider),
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Help & About'),
          _buildListTile(
            context,
            title: 'About This App',
            subtitle: 'Version 1.0.0 (Demo)',
            icon: Icons.info,
            onTap: () => context.push('/settings/about'),
          ),
          AppSpacing.verticalXL,
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _toggleMaintenanceMode(
    BuildContext context,
    bool value,
    SettingsProvider settingsProvider,
  ) {
    if (value) {
      ConfirmationDialog.show(
        context: context,
        title: 'Enable Maintenance Mode?',
        message:
            'This will simulate system maintenance. Payment actions will be limited to queueing only.',
        confirmLabel: 'Enable',
        onConfirm: () {
          settingsProvider.setMaintenanceMode(true);
          Toast.show(
            context,
            'Maintenance mode enabled',
            type: ToastType.info,
          );
        },
      );
    } else {
      settingsProvider.setMaintenanceMode(false);
      Toast.show(
        context,
        'Maintenance mode disabled',
        type: ToastType.success,
      );
    }
  }

  void _showDailyCapDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    final controller = TextEditingController(
      text: settingsProvider.dailyPaymentCap.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Payment Cap'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Maximum amount per day',
            prefixText: '\$',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value >= 100 && value <= 10000) {
                settingsProvider.setDailyPaymentCap(value);
                Navigator.pop(context);
                Toast.show(
                  context,
                  'Daily payment cap updated',
                  type: ToastType.success,
                );
              } else {
                Toast.show(
                  context,
                  'Enter a value between \$100 and \$10,000',
                  type: ToastType.error,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _resetDemoData(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    ConfirmationDialog.show(
      context: context,
      title: 'Reset Demo Data?',
      message:
          'This will delete all bills, payments, and logs. This action cannot be undone.',
      confirmLabel: 'Reset',
      isDestructive: true,
      onConfirm: () async {
        try {
          await settingsProvider.resetDemoData();
          if (context.mounted) {
            Toast.show(
              context,
              'Demo data reset successfully',
              type: ToastType.success,
            );
            context.go('/');
          }
        } catch (e) {
          if (context.mounted) {
            Toast.show(
              context,
              'Failed to reset data: $e',
              type: ToastType.error,
            );
          }
        }
      },
    );
  }
}
