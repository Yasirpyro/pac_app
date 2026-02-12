import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pac_app/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterLocalNotificationsPlatform
    extends FlutterLocalNotificationsPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() async {
    return const NotificationAppLaunchDetails(false);
  }

  @override
  Future<void> cancel({required int id, String? tag}) async {}

  @override
  Future<void> cancelAll() async {}

  // @override
  // Future<bool?> initialize(
  //   InitializationSettings? initializationSettings, {
  //   void Function(NotificationResponse)? onDidReceiveNotificationResponse,
  //   void Function(NotificationResponse)? onDidReceiveBackgroundNotificationResponse,
  // }) async {
  //   return true;
  // }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channelPathProvider =
      MethodChannel('plugins.flutter.io/path_provider');
  const MethodChannel channelSqflite = MethodChannel('com.tekartik.sqflite');

  setUp(() async {
    // Mock Local Notifications Platform
    FlutterLocalNotificationsPlatform.instance =
        MockFlutterLocalNotificationsPlatform();

    // Mock Path Provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelPathProvider, (MethodCall methodCall) async {
      return '.';
    });

    // Mock Sqflite
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelSqflite, (MethodCall methodCall) async {
      if (methodCall.method == 'getDatabasesPath') {
        return '.';
      }
      if (methodCall.method == 'openDatabase') {
        return 1;
      }
      if (methodCall.method == 'query') {
        return <Map<String, Object?>>[];
      }
      if (methodCall.method == 'execute') {
        return null;
      }
      return null;
    });

    // Mock Asset Bundle for .env
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      return const StringCodec().encodeMessage('GEMINI_API_KEY=test_key');
    });

    await dotenv.load(fileName: ".env");
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelPathProvider, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelSqflite, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const PACApp());
    await tester.pump();

    expect(find.text('Payment Assurance Copilot'), findsOneWidget);
  });
}
