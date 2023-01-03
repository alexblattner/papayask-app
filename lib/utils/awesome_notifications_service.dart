import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class AwesomeNotificationsService {
  static void initialize() {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'app_notification',
          channelName: 'App notifications',
          channelDescription: 'Notification channel the app',
          defaultColor: const Color(0xffDC693F),
          ledColor: const Color(0xffBFD537),
        ),
      ],
      debug: true,
    );
  }

  static void showNotification({
    required String title,
    required String body,
    String? payload,
  }) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'app_notification',
        title: title,
        body: body,
        payload: {'data': payload},
      ),
    );
  }
}
