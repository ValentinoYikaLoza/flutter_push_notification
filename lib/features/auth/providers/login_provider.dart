import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_app_notification/config/constants/storage_keys.dart';
import 'package:push_app_notification/config/router/app_router.dart';
import 'package:push_app_notification/features/auth/models/login_response.dart';
import 'package:push_app_notification/features/auth/providers/auth_provider.dart';
import 'package:push_app_notification/features/auth/services/auth_service.dart';
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
    final user = await StorageService.get<String>(StorageKeys.user) ?? '';

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

    // ref.read(loaderProvider.notifier).mostrarLoader('Atenticando');

    try {
      final LoginResponse loginResponse = await AuthService.login(
        user: state.user.value,
        password: state.password.value,
      );
      await StorageService.set<String>(
          StorageKeys.userToken, loginResponse.token);
      await StorageService.set<int>(
          StorageKeys.userId, loginResponse.userId);

      setRemember();
      //cada vez que inicia sesion habilita las notificaciones
      //ref.read(notificationProvider.notifier).enableNotifications();
      ref.read(authProvider.notifier).initAutoLogout();

      appRouter.go('/home');
    } on ServiceException catch (e) {
      SnackbarService.showSnackbar(message: e.message);
    }

    // ref.read(loaderProvider.notifier).quitarLoader();
  }

  setRemember() async {
    if (state.rememberMe) {
      await StorageService.set<String>(StorageKeys.user, state.user.value);
    }
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
