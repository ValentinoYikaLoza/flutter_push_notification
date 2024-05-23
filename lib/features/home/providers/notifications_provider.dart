import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_app_notification/config/constants/storage_keys.dart';
import 'package:push_app_notification/features/home/models/push_message.dart';
import 'package:push_app_notification/features/home/models/saved_notification_model.dart';
import 'package:push_app_notification/features/home/services/handle_notification_service.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';
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
    getFCMToken();
  }

  Future<void> getFCMToken() async {
    if (state.status != AuthorizationStatus.authorized) return;

    final token = await messaging.getToken();

    final tokenFormatter = token.toString().replaceAll('"', '');

    // Guarda el token en el almacenamiento local
    await StorageService.set<String>(StorageKeys.deviceToken, tokenFormatter);
    print('> token: $tokenFormatter');
  }

  void handleRemoteMessage(RemoteMessage message) async {
    if (message.notification == null) return;

    final notification = PushMessage(
      messageId:
          message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '',
      title: message.notification!.title ?? '',
      body: message.notification!.body ?? '',
      sentDate: message.sentTime ?? DateTime.now(),
      data: message.data,
      imageUrl: Platform.isAndroid
          ? message.notification!.android?.imageUrl
          : message.notification!.apple?.imageUrl,
    );

    _onPushMessageReceived(notification);
    _saveNotification(notification);
  }

  void _saveNotification(
    PushMessage notification,
  ) async {
    try {
      final userId = await StorageService.get<int>(StorageKeys.userId);
      final SavedNotificationResponse response =
          await SaveNotificationService.saveNotification(
        userId: userId!,
        message: notification,
      );

      print(response.message);
    } catch (e) {
      // Maneja errores de manera adecuada
      throw ServiceException('Algo salió mal.');
    }
  }

  void onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void _onPushMessageReceived(PushMessage pushMessage) {
    state = state.copyWith(
      notifications: [pushMessage, ...state.notifications],
    );
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

    _notificationStatusChanged(settings.authorizationStatus);
  }

  PushMessage? getMessageById(String pushMessageId) {
    final exist = state.notifications
        .any((element) => element.messageId == pushMessageId);
    if (!exist) return null;

    return state.notifications
        .firstWhere((element) => element.messageId == pushMessageId);
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
  print("Handling a background message: ${message.messageId}");
}
