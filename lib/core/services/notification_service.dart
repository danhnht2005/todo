import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Singleton service quản lý tất cả thông báo local
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ─── Channel Android ───
  static const _channelId = 'todo_reminder_channel';
  static const _channelName = 'Nhắc nhở tác vụ';
  static const _channelDesc = 'Thông báo nhắc nhở khi đến giờ làm việc';

  /// Khởi tạo plugin. Phải gọi trước khi dùng bất kỳ method nào.
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    // Android settings
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/macOS settings
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(initSettings);

    // Tạo notification channel cho Android 8+
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Xin quyền hiển thị thông báo (Android 13+)
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // Xin quyền lên lịch chính xác
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    }

    _initialized = true;
  }

  /// Lên lịch thông báo nhắc nhở tại thời điểm [reminderAt].
  /// [taskId] dùng để cancel sau này, [title] là tiêu đề tác vụ.
  Future<void> scheduleReminder({
    required String taskId,
    required String title,
    required DateTime reminderAt,
  }) async {
    await initialize();

    // Bỏ qua nếu thời gian đã qua
    if (reminderAt.isBefore(DateTime.now())) return;

    final id = _idFromTaskId(taskId);

    final tzReminderAt = tz.TZDateTime.from(reminderAt, tz.local);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      '⏰ Nhắc nhở tác vụ',
      title,
      tzReminderAt,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Huỷ thông báo của task [taskId].
  Future<void> cancelReminder(String taskId) async {
    await initialize();
    await _plugin.cancel(_idFromTaskId(taskId));
  }

  /// Huỷ tất cả thông báo.
  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  /// Chuyển taskId (String UUID) thành int notification ID.
  int _idFromTaskId(String taskId) {
    return taskId.hashCode.abs() % 2147483647; // Java int max
  }
}
