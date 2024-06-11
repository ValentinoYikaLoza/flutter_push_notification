import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:push_app_notification/config/constants/storage_keys.dart';
import 'package:push_app_notification/config/router/app_router.dart';
import 'package:push_app_notification/features/auth/models/login_response.dart';
import 'package:push_app_notification/features/auth/providers/auth_provider.dart';
import 'package:push_app_notification/features/auth/services/auth_service.dart';
import 'package:push_app_notification/features/home/providers/notifications_provider.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';
import 'package:push_app_notification/features/shared/services/snackbar_service.dart';
import 'package:push_app_notification/features/shared/services/storage_service.dart';
import 'package:push_app_notification/features/shared/widgets/form_wydnex.dart';

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref);
});

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier(this.ref)
      : super(
          LoginState(
            user: FormWydnex<String>(
              value: '',
              validators: [
                const ValidatorWydnex(ValidatorsWydnex.required),
                const ValidatorWydnex(ValidatorsWydnex.firstName),
              ],
              formatters: [
                LengthLimitingTextInputFormatter(20),
              ],
            ),
            password: FormWydnex<String>(
              value: '',
              validators: [
                const ValidatorWydnex(ValidatorsWydnex.required),
                const ValidatorWydnex(ValidatorsWydnex.maxLength, value: 10),
              ],
              formatters: [
                LengthLimitingTextInputFormatter(10),
              ],
            ),
          ),
        );
  final StateNotifierProviderRef ref;

  initData() async {
    final user = await StorageService.get<String>(StorageKeys.username);
    if (user == null) return;

    final rememberMe =
        await StorageService.get<bool>(StorageKeys.rememberMe) ?? false;

    state = state.copyWith(
      user: rememberMe ? FormWydnex(value: user) : const FormWydnex(value: ''),
      password: const FormWydnex(value: ''),
      rememberMe: rememberMe,
    );
  }

  login() async {
    FocusManager.instance.primaryFocus
        ?.unfocus(); //hacer que el teclado se quite

    final user = FormWydnex(value: state.user.value);
    final password = FormWydnex(value: state.password.value);
    state = state.copyWith(
      user: user,
      password: password,
    );

    if (!state.isFormValid) return;

    try {
      final LoginResponse loginResponse = await AuthService.login(
        user: state.user.value.toLowerCase(),
        password: state.password.value,
      );
      await StorageService.set<String>(
          StorageKeys.userToken, loginResponse.token);

      ref.read(authProvider.notifier).getUser();
      ref.read(authProvider.notifier).addDevice();
      ref.read(notificationsProvider.notifier).getNotifications();

      setRemember();

      ref.read(authProvider.notifier).initAutoLogout();

      appRouter.go('/home');
    } on ServiceException catch (e) {
      SnackbarService.showSnackbar(message: e.message);
    }
  }

  signInWithFacebook() async {}

  signInWithGoogle() async {
    // Cerrar sesión antes de iniciar sesión nuevamente
    await GoogleSignIn().signOut();

    GoogleSignInAccount? googleUsers = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? googleAuth = await googleUsers?.authentication;

    if (googleAuth == null) return;

    try {
      final LoginResponse loginResponse = await AuthService.loginGoogleAccount(
        idToken: googleAuth.idToken!,
      );

      await StorageService.set<String>(
          StorageKeys.userToken, loginResponse.token);

      ref.read(authProvider.notifier).getUser();
      ref.read(authProvider.notifier).addDevice();

      setRemember();

      ref.read(authProvider.notifier).initAutoLogout();
      appRouter.go('/home');
    } on ServiceException catch (e) {
      SnackbarService.showSnackbar(message: e.message);
    }
  }

  setRemember() async {
    await StorageService.set<bool>(StorageKeys.rememberMe, state.rememberMe);
  }

  changeUser(FormWydnex<String> user) {
    state = state.copyWith(
      user: user,
    );
  }

  changePassword(FormWydnex<String> password) {
    state = state.copyWith(
      password: password,
    );
  }

  toggleRememberMe() {
    state = state.copyWith(
      rememberMe: !state.rememberMe,
    );
  }
}

class LoginState {
  final FormWydnex<String> user;
  final FormWydnex<String> password;
  final bool loading;
  final bool rememberMe;
  bool get isFormValid {
    return user.isValid && password.isValid;
  }

  LoginState({
    required this.user,
    required this.password,
    this.loading = false,
    this.rememberMe = false,
  });

  LoginState copyWith({
    FormWydnex<String>? user,
    FormWydnex<String>? password,
    bool? loading,
    bool? rememberMe,
  }) =>
      LoginState(
        user: user ?? this.user,
        password: password ?? this.password,
        loading: loading ?? this.loading,
        rememberMe: rememberMe ?? this.rememberMe,
      );
}
