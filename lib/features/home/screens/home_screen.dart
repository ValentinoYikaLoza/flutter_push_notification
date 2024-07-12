import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:push_app_notification/features/auth/providers/auth_provider.dart';
import 'package:push_app_notification/features/auth/providers/login_provider.dart';
import 'package:push_app_notification/features/home/providers/notifications_provider.dart';
import 'package:push_app_notification/features/shared/widgets/custom_filled_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  Color iconColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    final notification = ref.watch(notificationsProvider);
    final user = ref.watch(authProvider);
    final isFingerprintToken = user.fingerprintEnabled;
    if (isFingerprintToken) {
      iconColor = Colors.red;
    } else {
      iconColor = Colors.black;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/imgs/image.png'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                notification.status.toString() ==
                        'AuthorizationStatus.authorized'
                    ? 'Notificaciones habilitadas'
                    : 'Notificaciones deshabilitadas',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              CustomFilledButton(
                buttonColor: Colors.transparent,
                textColor: Colors.black,
                borderRadius: BorderRadius.circular(20),
                child: const Icon(Icons.settings),
                onPressed: () {
                  ref.read(notificationsProvider.notifier).requestPermission();
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isFingerprintToken
                    ? 'Deshabilitar huella digital'
                    : 'Habilitar huella digital',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 10),
              CustomFilledButton(
                buttonColor: Colors.transparent,
                textColor: iconColor,
                borderRadius: BorderRadius.circular(20),
                child: const Icon(FontAwesomeIcons.fingerprint),
                onPressed: () {
                  setState(() {
                    ref.read(loginProvider.notifier).toggleFingerprint();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
