import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_app_notification/config/router/app_router.dart';
import 'package:push_app_notification/features/auth/screens/login_screen.dart';
import 'package:push_app_notification/features/auth/screens/register_screen.dart';
import 'package:push_app_notification/features/shared/widgets/custom_auth_bottom_bar.dart';

class LoginRegisterScreen extends ConsumerStatefulWidget {
  final int index;
  const LoginRegisterScreen({
    super.key,
    required this.index,
  });

  @override
  LoginRegisterScreenState createState() => LoginRegisterScreenState();
}

class LoginRegisterScreenState extends ConsumerState<LoginRegisterScreen> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Center(
                child: Text(
              'Bienvenido',
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.w300,
              ),
            )),
          ),
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: const [
            LoginScreen(),
            RegisterScreen(),
          ],
        ),
        bottomNavigationBar: CustomAuthBottomBar(
          currentIndex: _selectedIndex,
        ));
  }
}
