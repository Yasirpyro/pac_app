import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import 'data/database/database_helper.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/bills_provider.dart';
import 'presentation/providers/cashflow_provider.dart';
import 'presentation/providers/payment_provider.dart';
import 'presentation/providers/recommendation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await DatabaseHelper.instance.database;
  runApp(const PACApp());
}

class PACApp extends StatelessWidget {
  const PACApp({super.key});

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
          final router = createAppRouter();
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
