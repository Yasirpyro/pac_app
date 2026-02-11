import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import 'data/database/database_helper.dart';
import 'data/services/notification_service.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/bills_provider.dart';
import 'presentation/providers/cashflow_provider.dart';
import 'presentation/providers/payment_provider.dart';
import 'presentation/providers/recommendation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await DatabaseHelper.instance.database;

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(const PACApp());
}

class PACApp extends StatefulWidget {
  const PACApp({super.key});

  @override
  State<PACApp> createState() => _PACAppState();
}

class _PACAppState extends State<PACApp> {
  @override
  void initState() {
    super.initState();
    _setupNotificationHandling();
  }

  void _setupNotificationHandling() {
    // Listen to notification taps (foreground/background running)
    NotificationService().selectNotificationStream.stream.listen((payload) {
      _handleNotificationPayload(payload);
    });

    // Check if app was launched from notification (terminated state)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final payload = await NotificationService().getLaunchPayload();
      if (payload != null) {
        _handleNotificationPayload(payload);
      }
    });
  }

  void _handleNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    debugPrint('Notification tapped with payload: $payload');

    if (payload == 'test') {
      // Just open the app (default behavior)
      return;
    }

    final billId = int.tryParse(payload);
    if (billId != null) {
      // Navigate to payment confirmation using the global navigator key
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        // We use push to allow user to go back to home
        context.push('/payment/confirm/$billId');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
        ChangeNotifierProvider(create: (_) => BillsProvider()..loadBills()),
        ChangeNotifierProvider(create: (_) => CashflowProvider()..loadCashflow()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
      ],
      child: Builder(
        builder: (context) {
          final settingsProvider = context.read<SettingsProvider>();
          final router = createAppRouter(settingsProvider);
          return MaterialApp.router(
            title: 'Payment Assurance Copilot',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
