import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_app_notification/features/auth/providers/auth_provider.dart';
import 'package:push_app_notification/features/auth/providers/login_provider.dart';

class CustomAppBar extends ConsumerWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final login = ref.watch(loginProvider);
    return AppBar(
      title: Center(child: Text(login.user.value)),
      leading: const Padding(
        padding: EdgeInsets.only(left: 10),
        child: Image(
          image: AssetImage('assets/imgs/image.png'),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
              onPressed: () {
                ref.read(authProvider.notifier).logOut();
              },
              icon: const Icon(Icons.logout)),
        )
      ],
    );
  }
}
