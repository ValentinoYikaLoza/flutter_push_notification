import 'package:flutter/material.dart';
import 'package:push_app_notification/config/router/app_router.dart';

class CustomUserBottomBar extends StatelessWidget {
  final int currentIndex;
  const CustomUserBottomBar({
    super.key,
    required this.currentIndex,
  });

  void onItemTapped(BuildContext context, int index) {
    // context.go('');
    switch (index) {
      case 0:
        appRouter.go('/home');
        break;

      case 1:
        appRouter.go('/notification');
        break;

      case 2:
        appRouter.go('/chat');
        break;

      case 3:
        appRouter.go('/fotos');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (value) => onItemTapped(context, value),
      elevation: 0,
      selectedItemColor: Colors.cyan,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_library),
          label: 'Fotos',
        ),
      ],
    );
  }
}
