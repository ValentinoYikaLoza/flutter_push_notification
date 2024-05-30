import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_app_notification/config/constants/environment.dart';
import 'package:push_app_notification/config/local_notifications/local_notifications.dart';
import 'package:push_app_notification/config/router/app_router.dart';
import 'package:push_app_notification/config/theme/app_theme.dart';
import 'package:push_app_notification/features/home/providers/notifications_provider.dart';

void main() async {
  await Environment.initEnvironment();
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationsNotifier.initializeFCM();
  await LocalNotifications.initializeLocalNotifications();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends ConsumerState<MainApp> {
  //! agregar si se quiere sesion con limpieza de token
  // @override
  // void initState() {
  //   super.initState();
  //   Future.microtask(() {
  //     ref.read(authProvider.notifier).logOut();
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      builder: (context, child) =>
          HandleNotificationInteractions(child: child!),
    );
  }
}

class HandleNotificationInteractions extends ConsumerStatefulWidget {
  final Widget child;
  const HandleNotificationInteractions({super.key, required this.child});

  @override
  HandleNotificationInteractionsState createState() =>
      HandleNotificationInteractionsState();
}

class HandleNotificationInteractionsState
    extends ConsumerState<HandleNotificationInteractions> {
      
  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) async {
    ref.read(notificationsProvider.notifier).handleRemoteMessage(message);
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
