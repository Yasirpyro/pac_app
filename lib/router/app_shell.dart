import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/settings_provider.dart';
import '../theme/app_colors.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/bills')) return 1;
    if (location.startsWith('/maintenance')) return 0;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();
    switch (index) {
      case 0:
        context.go(settingsProvider.isMaintenanceMode ? '/maintenance' : '/home');
        break;
      case 1:
        context.go('/bills');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isMaintenanceMode = settingsProvider.isMaintenanceMode;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        backgroundColor: AppColors.surface,
        elevation: 8,
        shadowColor: Colors.black26,
        destinations: [
          NavigationDestination(
            icon: Icon(isMaintenanceMode ? Icons.engineering_outlined : Icons.home_outlined),
            selectedIcon: Icon(isMaintenanceMode ? Icons.engineering : Icons.home),
            label: isMaintenanceMode ? 'Maintenance' : 'Home',
          ),
          if (!isMaintenanceMode)
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Bills',
            ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
