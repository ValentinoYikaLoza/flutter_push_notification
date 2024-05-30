import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_app_notification/config/constants/storage_keys.dart';
import 'package:push_app_notification/config/local_notifications/local_notifications.dart';
import 'package:push_app_notification/features/home/models/get_notifications_model.dart';
import 'package:push_app_notification/features/home/models/push_message.dart';
import 'package:push_app_notification/features/home/services/get_notifications_service.dart';
import 'package:push_app_notification/features/shared/services/storage_service.dart';
import 'package:push_app_notification/firebase_options.dart';

// Proveedor de Riverpod
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier();
});

// Proveedor de estado
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier() : super(NotificationsState()) {
    initialStatusCheck();
    onForegroundMessage();
  }

  int pushNumberId = 0;

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  Future<void> initialStatusCheck() async {
    final settings = await messaging.getNotificationSettings();
    _notificationStatusChanged(settings.authorizationStatus);
  }

  void _notificationStatusChanged(AuthorizationStatus status) {
    state = state.copyWith(status: status);
  }

  getFCMToken() async {
    final deviceToken = await messaging.getToken();

    return deviceToken;
  }

  void handleRemoteMessage(RemoteMessage message) async {
    
    if (message.notification == null) return;

    LocalNotifications.showLocalNotification(
      id: ++pushNumberId,
      title: message.notification!.title ?? '',
      body: message.notification!.body ?? '',
      data: message.data.toString(),
    );

    getNotifications();
  }

  void getNotifications() async {
    final userId = await StorageService.get<int>(StorageKeys.userId);

    if (userId == null) return;

    final GetNotificationsResponse response =
        await GetNotificationsService.getNotifications(userId: userId);

    if (response.notifications == null) return;

    state = state.copyWith(
      notifications: response.notifications,
    );
  }

  void onForegroundMessage() async {
    final userToken = await StorageService.get<String>(StorageKeys.userToken);
    if (userToken != null || userToken == '') {
      FirebaseMessaging.onMessage.listen(handleRemoteMessage);
      getNotifications();
    }
  }

  Future<void> requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    await LocalNotifications.requestPermissionLocalNotifications();

    _notificationStatusChanged(settings.authorizationStatus);
  }
}

// Definir el estado
class NotificationsState {
  final AuthorizationStatus status;
  final List<PushMessage> notifications;

  NotificationsState({
    this.status = AuthorizationStatus.notDetermined,
    this.notifications = const [],
  });

  NotificationsState copyWith({
    AuthorizationStatus? status,
    List<PushMessage>? notifications,
  }) =>
      NotificationsState(
        status: status ?? this.status,
        notifications: notifications ?? this.notifications,
      );
}

// Handler para mensajes en background
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
