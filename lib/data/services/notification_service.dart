import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../models/bill_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (e) {
      debugPrint('Failed to get local timezone: $e');
      // Fallback to UTC or a default if getting local fails
      try {
        tz.setLocalLocation(tz.getLocation('America/New_York'));
      } catch (_) {
        // If even that fails, we leave it as UTC (default)
      }
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Note: iOS not required per constraints, but good practice to have empty config
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        selectNotificationStream.add(notificationResponse.payload);
      },
    );

    _isInitialized = true;
    _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'pac_reminders', // id
      'Bill Reminders', // title
      description: 'Reminders for upcoming and due bills',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<bool?> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestNotificationsPermission();
      // On Android 12+, we need to request exact alarm permission to schedule precisely
      await androidImplementation?.requestExactAlarmsPermission();
      return granted;
    }
    return true; // iOS permission logic omitted for hackathon
  }

  /// Schedules 5-day and Due-Today notifications for a bill
  Future<void> scheduleNotificationsForBill(BillModel bill) async {
    if (bill.status != 'Pending') {
      await cancelNotificationsForBill(bill.id!);
      return;
    }

    // ID Scheme:
    // 5-day reminder: billId * 10 + 1
    // Due-day reminder: billId * 10 + 2
    final int id5Day = bill.id! * 10 + 1;
    final int idDueDay = bill.id! * 10 + 2;

    // 1. Schedule 5-day reminder (only if amount >= 50)
    if (bill.amount >= 50) {
      final scheduledDate5Day = bill.dueDate.subtract(const Duration(days: 5));
      final now = DateTime.now();

      // Only schedule if it's in the future
      if (scheduledDate5Day.isAfter(now)) {
        await _scheduleNotification(
          id: id5Day,
          title: 'Bill due soon: ${bill.payeeName}',
          body: '\$${bill.amount} due on ${bill.dueDate.toString().split(' ')[0]}. Tap to pay now (simulated).',
          payload: '${bill.id}',
          scheduledDate: scheduledDate5Day,
        );
      }
    }

    // 2. Schedule Due-Today reminder (Morning of due date, e.g., 9 AM)
    final dueDayMorning = DateTime(
      bill.dueDate.year,
      bill.dueDate.month,
      bill.dueDate.day,
      9, // 9:00 AM
      0,
    );

    if (dueDayMorning.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: idDueDay,
        title: 'Bill due today: ${bill.payeeName}',
        body: 'Due today. Tap to pay now (simulated).',
        payload: '${bill.id}',
        scheduledDate: dueDayMorning,
      );
    }
  }

  /// Schedules a user-defined custom reminder
  Future<void> scheduleUserReminder(BillModel bill, DateTime reminderDate) async {
    // ID Scheme: billId * 10 + 3
    final int idCustom = bill.id! * 10 + 3;

    if (reminderDate.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: idCustom,
        title: 'Reminder: ${bill.payeeName}',
        body: 'You asked to be reminded about this bill today.',
        payload: '${bill.id}',
        scheduledDate: reminderDate,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    required DateTime scheduledDate,
  }) async {
    try {
      final scheduledTz = scheduledDate is tz.TZDateTime
          ? scheduledDate as tz.TZDateTime
          : tz.TZDateTime.from(scheduledDate, tz.local);
      debugPrint('Scheduling notification $id for input: $scheduledDate');
      debugPrint('Converted to TZDateTime: $scheduledTz (Location: ${scheduledTz.location.name})');

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTz,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'pac_reminders',
            'Bill Reminders',
            channelDescription: 'Reminders for upcoming and due bills',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
      debugPrint('Scheduled notification $id for $scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> cancelNotificationsForBill(int billId) async {
    await flutterLocalNotificationsPlugin.cancel(id: billId * 10 + 1);
    await flutterLocalNotificationsPlugin.cancel(id: billId * 10 + 2);
    await flutterLocalNotificationsPlugin.cancel(id: billId * 10 + 3); // Cancel custom reminder too
  }

  Future<void> cancelUserReminder(int billId) async {
    await flutterLocalNotificationsPlugin.cancel(id: billId * 10 + 3);
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Helper for manual testing
  Future<void> scheduleTestNotification() async {
    final now = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
    await _scheduleNotification(
      id: 99999,
      title: 'Test Notification',
      body: 'This is a test reminder. Tap to open app.',
      payload: 'test',
      scheduledDate: now,
    );
  }

  /// Helper for Urgent Demo (T-2 Hours Plan)
  Future<void> scheduleUrgentDemoNotification() async {
    final now = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
    await _scheduleNotification(
      id: 88888,
      title: 'Urgent: Bills Due Today',
      body: 'Today is the last day for pending bills. Tap to review and pay (simulated) in one tap.',
      payload: '/urgent', // Simple route payload
      scheduledDate: now,
    );
  }

  Future<String?> getLaunchPayload() async {
    final details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      return details.notificationResponse?.payload;
    }
    return null;
  }
}
