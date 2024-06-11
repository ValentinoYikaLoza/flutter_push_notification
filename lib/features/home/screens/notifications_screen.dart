import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:push_app_notification/features/home/providers/notifications_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({
    super.key,
  });

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      setState(() {
        ref.read(notificationsProvider.notifier).getNotifications();
      });
    });
  }

  //agregar obtener notificaciones
  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    return Column(
      children: [
        const Text(
          'Notificaciones',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: notifications.notifications.length,
            itemBuilder: (BuildContext context, int index) {
              final notification = notifications.notifications[index];
              return ListTile(
                title: Text(notification.title),
                subtitle: Text(notification.body),
                leading: notification.imageUrl != null
                    ? Image.network(notification.imageUrl!)
                    : Image.asset('assets/imgs/image.png'),
                onTap: () {
                  if (notification.data != null) {
                    if (notification.data!['go'] == '10') {
                      if (notification.title != '') {
                        context.push('/chat-priv/${notification.title}');
                      } else {
                        context.push('/chat');
                      }
                    }
                    if (notification.data!['go'] == '11') {
                      context.push('/fotos');
                    }
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
