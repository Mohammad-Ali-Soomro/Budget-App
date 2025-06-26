import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Android initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
  }

  // Show immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'budget_app_channel',
      'Budget App Notifications',
      channelDescription: 'Notifications for budget app reminders and alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Schedule notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'budget_app_scheduled',
      'Scheduled Notifications',
      channelDescription: 'Scheduled notifications for bill reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // Schedule repeating notification
  static Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'budget_app_repeating',
      'Repeating Notifications',
      channelDescription: 'Repeating notifications for recurring reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.periodicallyShow(
      id,
      title,
      body,
      repeatInterval,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // Cancel notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Get pending notifications
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Budget-specific notifications
  static Future<void> showBudgetExceededNotification({
    required String categoryName,
    required double amount,
    required double budgetLimit,
  }) async {
    await showNotification(
      id: 1001,
      title: 'Budget Exceeded!',
      body:
          'You have exceeded your $categoryName budget by Rs. ${(amount - budgetLimit).toStringAsFixed(0)}',
      payload: 'budget_exceeded',
    );
  }

  static Future<void> showBudgetWarningNotification({
    required String categoryName,
    required double percentage,
  }) async {
    await showNotification(
      id: 1002,
      title: 'Budget Warning',
      body:
          'You have used ${percentage.toStringAsFixed(0)}% of your $categoryName budget',
      payload: 'budget_warning',
    );
  }

  static Future<void> showBillReminderNotification({
    required String billName,
    required double amount,
    required DateTime dueDate,
  }) async {
    final daysLeft = dueDate.difference(DateTime.now()).inDays;
    await showNotification(
      id: 1003,
      title: 'Bill Reminder',
      body:
          '$billName payment of Rs. ${amount.toStringAsFixed(0)} is due in $daysLeft days',
      payload: 'bill_reminder',
    );
  }

  static Future<void> showGoalAchievedNotification({
    required String goalName,
    required double amount,
  }) async {
    await showNotification(
      id: 1004,
      title: 'Goal Achieved! 🎉',
      body:
          'Congratulations! You have achieved your $goalName goal of Rs. ${amount.toStringAsFixed(0)}',
      payload: 'goal_achieved',
    );
  }

  static Future<void> showGoalProgressNotification({
    required String goalName,
    required double percentage,
  }) async {
    await showNotification(
      id: 1005,
      title: 'Goal Progress Update',
      body:
          'You are ${percentage.toStringAsFixed(0)}% towards your $goalName goal',
      payload: 'goal_progress',
    );
  }
}
