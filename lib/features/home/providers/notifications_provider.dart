import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_app_notification/config/local_notifications/local_notifications.dart';
import 'package:push_app_notification/features/home/models/get_notifications_model.dart';
import 'package:push_app_notification/features/home/models/push_message.dart';
import 'package:push_app_notification/features/home/services/get_notifications_service.dart';
import 'package:push_app_notification/features/shared/providers/loader_provider.dart';
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

  // Inicializa Firebase Cloud Messaging (FCM)
  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Verifica el estado inicial de las notificaciones
  Future<void> initialStatusCheck() async {
    final settings = await messaging.getNotificationSettings();
    _notificationStatusChanged(settings.authorizationStatus);
  }

  // Actualiza el estado de autorización de notificaciones
  void _notificationStatusChanged(AuthorizationStatus status) {
    state = state.copyWith(status: status);
  }

  // Elimina el token de FCM
  deleteFMCToken() async {
    await messaging.deleteToken();
  }

  // Obtiene el token de FCM
  getFCMToken() async {
    final deviceToken = await messaging.getToken();

    return deviceToken;
  }

  // Maneja mensajes remotos
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

  // Obtiene las notificaciones
  void getNotifications() async {
    LoaderNotifier().mostrarLoader();

    final GetNotificationsResponse response =
        await GetNotificationsService.getNotifications();
    
    LoaderNotifier().quitarLoader();

    if (response.notifications == null) return;

    state = state.copyWith(
      notifications: response.notifications,
    );

  }

  // Escucha mensajes en primer plano
  void onForegroundMessage() async {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
    getNotifications();
  }

  // Solicita permiso para las notificaciones
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

// Manejador para mensajes en background
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
