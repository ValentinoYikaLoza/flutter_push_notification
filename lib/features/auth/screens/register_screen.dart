import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_app_notification/features/auth/providers/register_provider.dart';
import 'package:push_app_notification/features/auth/widgets/password_input.dart';
import 'package:push_app_notification/features/shared/widgets/custom_filled_button.dart';
import 'package:push_app_notification/features/shared/widgets/input_wydnex.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: RegisterView());
  }
}

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({
    super.key,
  });

  @override
  RegisterViewState createState() => RegisterViewState();
}

class RegisterViewState extends ConsumerState<RegisterView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'REGISTRO',
              style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 25,
                  fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            height: 150,
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Image.asset('assets/imgs/image.png', fit: BoxFit.cover)),
          ),
          const SizedBox(height: 30),
          InputWydnex(
            label: 'Usuario',
            value: registerState.user,
            keyboardType: TextInputType.name,
            onChanged: (value) {
              ref.read(registerProvider.notifier).changeUser(value);
            },
          ),
          const SizedBox(height: 30),
          PasswordInput(
            label: 'Contraseña',
            value: registerState.password,
            onChanged: (value) {
              ref.read(registerProvider.notifier).changePassword(value);
            },
          ),
          const SizedBox(height: 30),
          PasswordInput(
            label: 'Repetir contraseña',
            value: registerState.repeatedPassword,
            onChanged: (value) {
              ref.read(registerProvider.notifier).changeRepeatedPassword(value);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
              width: double.infinity,
              height: 60,
              child: CustomFilledButton(
                  buttonColor: Colors.blue,
                  textColor: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  child: const Text('Registrar'),
                  onPressed: () {
                    ref.read(registerProvider.notifier).register();
                  })),
        ],
      ),
    );
  }
}
