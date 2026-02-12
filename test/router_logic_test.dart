import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pac_app/data/models/bill_model.dart';
import 'package:pac_app/router/app_router.dart';
import 'package:pac_app/presentation/providers/settings_provider.dart';
import 'package:pac_app/presentation/providers/bills_provider.dart';
import 'package:pac_app/presentation/providers/cashflow_provider.dart';
import 'package:pac_app/presentation/providers/payment_provider.dart';
import 'package:pac_app/presentation/providers/recommendation_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:pac_app/presentation/screens/maintenance/maintenance_mode_screen.dart';
import 'package:pac_app/presentation/screens/maintenance/queue_payment_screen.dart';

// Mock Provider
class MockSettingsProvider extends ChangeNotifier implements SettingsProvider {
  bool _maintenance = false;

  @override
  bool get isMaintenanceMode => _maintenance;

  void setMaintenanceModeTest(bool value) {
    _maintenance = value;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Minimal mocks for other providers to prevent crashes
class MockBillsProvider extends ChangeNotifier implements BillsProvider {
  @override
  List<BillModel> get bills => [];
  @override
  List<BillModel> get pendingBills => [];
  @override
  List<BillModel> get queuedBills => [];

  @override
  Future<BillModel?> getBillById(int id) async {
    return BillModel(
      id: id,
      payeeName: 'Test Bill',
      amount: 100.0,
      dueDate: DateTime.now(),
      category: 'Utilities',
      status: 'Pending',
    );
  }

  @override
  Future<void> loadBills() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockCashflowProvider extends ChangeNotifier implements CashflowProvider {
  @override
  Future<void> loadCashflow() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockPaymentProvider extends ChangeNotifier implements PaymentProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockRecommendationProvider extends ChangeNotifier implements RecommendationProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channelSqflite = MethodChannel('com.tekartik.sqflite');
  const MethodChannel channelPathProvider = MethodChannel('plugins.flutter.io/path_provider');

  setUp(() {
    // Mock Sqflite and PathProvider to prevent DB crashes
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelSqflite, (MethodCall methodCall) async {
      if (methodCall.method == 'getDatabasesPath') return '.';
      if (methodCall.method == 'openDatabase') return 1;
      if (methodCall.method == 'query') return []; // Return empty list for queries
      return null;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelPathProvider, (MethodCall methodCall) async {
      return '.';
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelSqflite, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelPathProvider, null);
  });

  testWidgets('Router allows deep links to queue payment in Maintenance Mode', (WidgetTester tester) async {
    final mockSettings = MockSettingsProvider();

    // Create router instance here so we can access it directly
    final router = createAppRouter(mockSettings);

    // 1. Enable Maintenance Mode
    mockSettings.setMaintenanceModeTest(true);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(value: mockSettings),
          ChangeNotifierProvider<BillsProvider>(create: (_) => MockBillsProvider()),
          ChangeNotifierProvider<CashflowProvider>(create: (_) => MockCashflowProvider()),
          ChangeNotifierProvider<PaymentProvider>(create: (_) => MockPaymentProvider()),
          ChangeNotifierProvider<RecommendationProvider>(create: (_) => MockRecommendationProvider()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    // 2. Navigate to the Queue Payment screen using the router instance directly
    router.go('/maintenance/queue/123');

    await tester.pumpAndSettle();

    // 3. Verify we are on QueuePaymentScreen
    expect(find.byType(MaintenanceModeScreen), findsNothing);
    expect(find.byType(QueuePaymentScreen), findsOneWidget);
  });

  /*
  testWidgets('Router redirects unauthorized paths to Maintenance Screen', (WidgetTester tester) async {
    final mockSettings = MockSettingsProvider();
    final router = createAppRouter();

    mockSettings.setMaintenanceModeTest(true);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(value: mockSettings),
          ChangeNotifierProvider<BillsProvider>(create: (_) => MockBillsProvider()),
          ChangeNotifierProvider<CashflowProvider>(create: (_) => MockCashflowProvider()),
          ChangeNotifierProvider<PaymentProvider>(create: (_) => MockPaymentProvider()),
          ChangeNotifierProvider<RecommendationProvider>(create: (_) => MockRecommendationProvider()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    // Try to go to home
    router.go('/home');

    await tester.pumpAndSettle();

    // Should be redirected to MaintenanceModeScreen
    expect(find.byType(MaintenanceModeScreen), findsOneWidget);
  });
  */
}
