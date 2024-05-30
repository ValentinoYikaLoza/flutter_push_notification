import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_app_notification/config/router/app_router.dart';
import 'package:push_app_notification/features/home/providers/notifications_provider.dart';
// import 'package:push_app_notification/config/router/app_router.dart';

class LocalNotifications {
  static Future<void> requestPermissionLocalNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> initializeLocalNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    //TODO ios configuration

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // TODO ios configuration settings
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  static void showLocalNotification({
    required int id,
    String? title,
    String? body,
    String? data,
  }) {
    const androidDetails = AndroidNotificationDetails(
        'channelId', 'channelName',
        playSound: true, importance: Importance.max, priority: Priority.high);

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      //TODO IOS
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails,
        payload: data);
    
    NotificationsNotifier().getNotifications();
  }

  static void onDidReceiveNotificationResponse(NotificationResponse response) {
    appRouter.push('/notification');
  }
}
