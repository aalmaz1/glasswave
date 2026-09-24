import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    await init();
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final granted =
            await androidImplementation.requestNotificationsPermission() ?? false;
        await androidImplementation.requestExactAlarmsPermission();
        return granted;
      }
    } else if (Platform.isIOS || Platform.isMacOS) {
      final iosImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        return await iosImplementation.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    }
    return true;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    await requestPermissions();

    const androidDetails = AndroidNotificationDetails(
      'glasswave_reminders_v2',
      'Reminders',
      channelDescription: 'GlassWave note reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('glasswave_notification'),
      playSound: true,
      enableVibration: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      sound: 'glasswave_notification.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    final notificationId = id.abs() % 2147483647;

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    try {
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        title.isEmpty ? 'GlassWave 🌊' : title,
        body,
        tzScheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Fallback for devices where exact alarm scheduling is not granted by OS
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        title.isEmpty ? 'GlassWave 🌊' : title,
        body,
        tzScheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await init();
    final notificationId = id.abs() % 2147483647;
    await _notificationsPlugin.cancel(notificationId);
  }
}
