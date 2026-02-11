import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/settings_provider.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/bills/bill_list_screen.dart';
import '../presentation/screens/bills/bill_detail_screen.dart';
import '../presentation/screens/bills/add_bill_screen.dart';
import '../presentation/screens/bills/edit_bill_screen.dart';
import '../presentation/screens/payment/payment_confirmation_screen.dart';
import '../presentation/screens/payment/payment_success_screen.dart';
import '../presentation/screens/maintenance/maintenance_mode_screen.dart';
import '../presentation/screens/maintenance/queue_payment_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/settings/cashflow_inputs_screen.dart';
import '../presentation/screens/settings/audit_log_screen.dart';
import '../presentation/screens/settings/about_screen.dart';
import 'app_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final settingsProvider = context.read<SettingsProvider>();
      final isMaintenanceMode = settingsProvider.isMaintenanceMode;

      // Redirect to maintenance mode when active
      if (isMaintenanceMode) {
        const allowedInMaintenance = [
          '/maintenance',
          '/maintenance/queue',
          '/settings',
          '/settings/cashflow',
          '/settings/audit-log',
          '/settings/about',
        ];
        if (!allowedInMaintenance.contains(state.uri.path)) {
          return '/maintenance';
        }
      }
      return null;
    },
    routes: [
      // Shell route with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/bills',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BillListScreen(),
            ),
          ),
          GoRoute(
            path: '/maintenance',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MaintenanceModeScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
      // Full-screen routes (no bottom nav)
      GoRoute(
        path: '/bills/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return BillDetailScreen(billId: id);
        },
      ),
      GoRoute(
        path: '/add-bill',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddBillScreen(),
      ),
      GoRoute(
        path: '/edit-bill/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EditBillScreen(billId: id);
        },
      ),
      GoRoute(
        path: '/payment/confirm/:billId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final billId = int.parse(state.pathParameters['billId']!);
          final scheduledDate = state.uri.queryParameters['date'];
          return PaymentConfirmationScreen(
            billId: billId,
            scheduledDate: scheduledDate != null
                ? DateTime.parse(scheduledDate)
                : DateTime.now(),
          );
        },
      ),
      GoRoute(
        path: '/payment/success',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PaymentSuccessScreen(
            referenceId: extra['referenceId'] as String? ?? '',
            amount: extra['amount'] as double? ?? 0.0,
            payeeName: extra['payeeName'] as String? ?? '',
            scheduledDate: extra['scheduledDate'] as DateTime? ?? DateTime.now(),
          );
        },
      ),
      GoRoute(
        path: '/maintenance/queue/:billId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final billId = int.parse(state.pathParameters['billId']!);
          return QueuePaymentScreen(billId: billId);
        },
      ),
      GoRoute(
        path: '/settings/cashflow',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CashflowInputsScreen(),
      ),
      GoRoute(
        path: '/settings/audit-log',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuditLogScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
}
