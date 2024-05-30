import 'package:flutter/material.dart';
import 'package:push_app_notification/config/router/app_router.dart';

class CustomAuthBottomBar extends StatelessWidget {
  final int currentIndex;
  const CustomAuthBottomBar({
    super.key,
    required this.currentIndex,
  });

  void onItemTapped(BuildContext context, int index) {
    // context.go('');
    switch (index) {
      case 0:
        appRouter.go('/login');
        break;

      case 1:
        appRouter.go('/register');
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
          icon: Icon(Icons.person),
          label: 'Login',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_add),
          label: 'Register',
        ),
      ],
    );
  }
}
