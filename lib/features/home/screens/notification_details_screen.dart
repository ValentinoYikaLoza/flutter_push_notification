import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_app_notification/features/home/models/push_message.dart';
import 'package:push_app_notification/features/home/providers/notifications_provider.dart';

class NotificationDetailsScreen extends ConsumerWidget {
  final String pushMessageId;

  const NotificationDetailsScreen({super.key, required this.pushMessageId});

  @override
  Widget build(BuildContext context, ref) {
    final PushMessage? message =
        ref.read(notificationsProvider.notifier).getMessageById(pushMessageId);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Detalles Push'),
        ),
        body: (message != null)
            ? _NotificationDetailsView(message: message)
            : const Center(child: Text('Notificación no existe')));
  }
}

class _NotificationDetailsView extends ConsumerWidget {
  final PushMessage message;

  const _NotificationDetailsView({required this.message});

  @override
  Widget build(BuildContext context, ref) {
    final textStyles = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          if (message.imageUrl != null) Image.network(message.imageUrl!),
          const SizedBox(height: 30),
          Text(message.title, style: textStyles.titleMedium),
          Text(message.body),
          const Divider(),
          Center(child: Text(message.data.toString())),
        ],
      ),
    );
  }
}
