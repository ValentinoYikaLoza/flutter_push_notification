import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:push_app_notification/features/auth/providers/login_provider.dart';
import 'package:push_app_notification/features/shared/widgets/custom_filled_button.dart';

class UsersDialog extends ConsumerWidget {
  const UsersDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);

    return Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Row(
              children: [
                Text(
                  'Usuario',
                  style: TextStyle(fontSize: 20),
                ),
                Spacer(),
                Text(
                  'Tipo de cuenta',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            SizedBox(
              height:
                  200, // Altura máxima para mostrar 4 distritos y permitir desplazamiento
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final user = loginState.users[index];
                        dynamic icon;
                        switch (user.accountType) {
                          case 'google':
                            icon = const CircleAvatar(
                              backgroundColor: Colors.red,
                              child: Icon(
                                FontAwesomeIcons.google,
                                color: Colors.white,
                                size: 20,
                              ),
                            );
                            break;
                          case 'facebook':
                            icon = const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(
                                FontAwesomeIcons.facebook,
                                color: Colors.white,
                                size: 20,
                              ),
                            );
                            break;
                          default:
                            icon = const CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Image(
                                image: AssetImage('assets/imgs/image.png'),
                                height: 20,
                              ),
                            );
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: CustomFilledButton(
                            buttonColor: Colors.green,
                            textColor: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 20,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      user.username.toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                icon,
                                const SizedBox(width: 20),
                                const Icon(FontAwesomeIcons.fingerprint),
                                const SizedBox(width: 20),
                              ],
                            ),
                            onPressed: () {
                              ref
                                  .read(loginProvider.notifier)
                                  .signInWithFingerprint(user.username);
                            },
                          ),
                        );
                      },
                      childCount: loginState.users.length,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Center(
              child: TextButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
