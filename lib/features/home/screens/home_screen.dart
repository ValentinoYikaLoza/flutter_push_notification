import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_app_notification/features/home/providers/notifications_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final notification = ref.watch(notificationsProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/imgs/image.png'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                notification.status.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              IconButton(
                  onPressed: () {
                    ref
                        .read(notificationsProvider.notifier)
                        .requestPermission();
                  },
                  icon: const Icon(Icons.settings)),
            ],
          ),
        ],
      ),
    );
  }
}
