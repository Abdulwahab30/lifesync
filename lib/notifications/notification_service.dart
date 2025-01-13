import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/screens/home_screen.dart';

bool _isRequestingPermission = false;

Future<void> requestExactAlarmPermission() async {
  // Check if a request is already in progress
  if (_isRequestingPermission) {
    return; // Exit if a request is ongoing
  }

  _isRequestingPermission = true; // Set the flag to true

  var status = await Permission.scheduleExactAlarm.request();

  if (status.isGranted) {
    // Permission granted, proceed with scheduling notifications
  } else if (status.isDenied) {
    // Handle the case where the permission is denied
  }

  _isRequestingPermission = false; // Reset the flag after handling the request
}

class NotificationService {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
              channelKey: "high_importance_channel",
              channelName: "Basic Notification",
              channelDescription:
                  "Notification Channel for basic notifications",
              channelGroupKey: 'high_importance_channel',
              defaultColor: const Color(0xFF607D8B),
              ledColor: Colors.white,
              importance: NotificationImportance.Max,
              channelShowBadge: true,
              onlyAlertOnce: true,
              playSound: true,
              criticalAlerts: true)
        ],
        channelGroups: [
          NotificationChannelGroup(
              channelGroupKey: "high_importance_channel",
              channelGroupName: "Group 1")
        ],
        debug: true);
    await AwesomeNotifications()
        .isNotificationAllowed()
        .then((isAllowed) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    await AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onNotificationCreatedMethod: onNotificationCreatedMethod,
        onNotificationDisplayedMethod: onNotificationDisplayedMethod,
        onDismissActionReceivedMethod: onDismissActionReceivedMethod);
  }

  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationCreatedMethod');
  }

  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationDisplayedMethod');
  }

  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onDismissActionReceivedMethod');
  }

  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onActionReceivedMethod');
    final payload = receivedAction.payload ?? {};
    if (payload["Navigate"] == "true") {
      MyApp.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    }
  }

  static Future<void> scheduleNotificationAtTime() async {
    final DateTime now = DateTime.now();
    final DateTime scheduleTime =
        DateTime(now.year, now.month, now.day, 16, 0, 0); // 4 PM today

    // If current time is past the scheduled time, schedule for the next day
    DateTime actualScheduleTime = scheduleTime;
    if (now.isAfter(scheduleTime)) {
      actualScheduleTime = scheduleTime.add(const Duration(days: 1));
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10, // Ensure this is a unique ID for each notification
        channelKey: 'high_importance_channel',
        title: 'Daily Reminder',
        body: 'Have You completed your tasks!?',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: actualScheduleTime.year,
        month: actualScheduleTime.month,
        day: actualScheduleTime.day,
        hour: actualScheduleTime.hour,
        minute: actualScheduleTime.minute,
        second: 0,
        millisecond: 0,
        repeats: true, // Set to true if you want this to repeat daily
      ),
    );
  }

  // Display a notification without checking for tasks
  static Future<void> showNotification({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final Duration? interval,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: 'high_importance_channel',
        title: title,
        body: body,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
      ),
      actionButtons: actionButtons,
    );
  }
}
