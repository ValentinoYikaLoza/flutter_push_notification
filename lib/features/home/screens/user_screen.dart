import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_app_notification/config/router/app_router.dart';
import 'package:push_app_notification/features/auth/providers/auth_provider.dart';
import 'package:push_app_notification/features/auth/providers/login_provider.dart';
import 'package:push_app_notification/features/home/providers/get_api_key_provider.dart';
import 'package:push_app_notification/features/home/screens/album_photos_screen.dart';
import 'package:push_app_notification/features/home/screens/chat_screen.dart';
import 'package:push_app_notification/features/home/screens/home_screen.dart';
import 'package:push_app_notification/features/home/screens/notifications_screen.dart';
import 'package:push_app_notification/features/shared/widgets/custom_bottom_bar.dart';

class UserScreen extends ConsumerStatefulWidget {
  final int index;
  const UserScreen({
    super.key,
    required this.index,
  });

  @override
  UserScreenState createState() => UserScreenState();
}

class UserScreenState extends ConsumerState<UserScreen> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      setState(() {
        ref.read(getApiKeyProvider.notifier).getApiKey();
      });
    });
    _selectedIndex = widget.index;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final login = ref.watch(loginProvider);
    return Scaffold(
        appBar: AppBar(
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
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: const [
            HomeScreen(),
            NotificationScreen(),
            ChatScreen(),
            PhotoAlbumScreen(),
          ],
        ),
        bottomNavigationBar: CustomBottomBar(
          currentIndex: _selectedIndex,
        ));
  }
}
