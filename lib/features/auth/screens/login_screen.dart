import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_app_notification/config/router/app_router.dart';
import 'package:push_app_notification/features/auth/providers/login_provider.dart';
import 'package:push_app_notification/features/auth/widgets/password_input.dart';
import 'package:push_app_notification/features/shared/widgets/checkbox.dart';
import 'package:push_app_notification/features/shared/widgets/custom_filled_button.dart';
import 'package:push_app_notification/features/shared/widgets/input_wydnex.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: LoginView());
  }
}

class LoginView extends ConsumerStatefulWidget {
  const LoginView({
    super.key,
  });

  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends ConsumerState<LoginView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(loginProvider.notifier).initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'INICIO DE SESION',
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
            value: loginState.user,
            keyboardType: TextInputType.name,
            onChanged: (value) {
              ref.read(loginProvider.notifier).changeUser(value);
            },
          ),
          const SizedBox(height: 30),
          PasswordInput(
            label: 'Contraseña',
            value: loginState.password,
            onChanged: (value) {
              ref.read(loginProvider.notifier).changePassword(value);
            },
          ),
          const SizedBox(height: 10),
          CustomCheckbox(
            value: loginState.rememberMe,
            onChanged: (value) {
              ref.read(loginProvider.notifier).toggleRememberMe();
            },
            label: 'Recuerdame',
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: CustomFilledButton(
              buttonColor: Colors.blue,
              textColor: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: const Text('Ingresar'),
              onPressed: () {
                ref.read(loginProvider.notifier).login();
              },
            ),
          ),
          const SizedBox(height: 10),
          //aqui irá el login por google
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿No tiengo cuenta? ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    appRouter.go('/register');
                  });
                },
                child: const Text(
                  'Registrarme',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
