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
import '../presentation/screens/maintenance/queued_payments_review_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/settings/cashflow_inputs_screen.dart';
import '../presentation/screens/settings/audit_log_screen.dart';
import '../presentation/screens/settings/about_screen.dart';
import '../presentation/screens/bills/urgent_bills_screen.dart';
import 'app_shell.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(Listenable settingsListenable) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: settingsListenable,
    redirect: (context, state) {
      final settingsProvider = context.read<SettingsProvider>();
      final isMaintenanceMode = settingsProvider.isMaintenanceMode;

      // Redirect to maintenance mode when active
      if (isMaintenanceMode) {
        const allowedInMaintenance = [
          '/maintenance',
          '/maintenance/queue',
          '/payment/success',
          '/settings',
          '/settings/cashflow',
          '/settings/audit-log',
          '/settings/about',
          '/bills', // Allow viewing list
        ];

        final path = state.uri.path;
        final isAllowed = allowedInMaintenance.any((allowed) =>
            path == allowed || path.startsWith('$allowed/')); // Handles /bills/:id

        if (!isAllowed) {
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
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
      // Full-screen routes (no bottom nav)
      GoRoute(
        path: '/maintenance',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MaintenanceModeScreen(),
        ),
      ),
      GoRoute(
        path: '/bills/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return BillDetailScreen(billId: id);
        },
      ),
      GoRoute(
        path: '/add-bill',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AddBillScreen(),
      ),
      GoRoute(
        path: '/edit-bill/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EditBillScreen(billId: id);
        },
      ),
      GoRoute(
        path: '/payment/confirm/:billId',
        parentNavigatorKey: rootNavigatorKey,
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
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PaymentSuccessScreen(
            referenceId: extra['referenceId'] as String? ?? '',
            amount: extra['amount'] as double? ?? 0.0,
            payeeName: extra['payeeName'] as String? ?? '',
            scheduledDate: extra['scheduledDate'] as DateTime? ?? DateTime.now(),
            isPayNow: extra['isPayNow'] as bool? ?? false,
            isQueued: extra['isQueued'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: '/maintenance/queue/:billId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final billId = int.parse(state.pathParameters['billId']!);
          return QueuePaymentScreen(billId: billId);
        },
      ),
      GoRoute(
        path: '/maintenance/review',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const QueuedPaymentsReviewScreen(),
      ),
      GoRoute(
        path: '/urgent',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const UrgentBillsScreen(),
      ),
      GoRoute(
        path: '/settings/cashflow',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CashflowInputsScreen(),
      ),
      GoRoute(
        path: '/settings/audit-log',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AuditLogScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
}
