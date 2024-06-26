import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:push_app_notification/config/constants/storage_keys.dart';
import 'package:push_app_notification/config/router/app_router.dart';
import 'package:push_app_notification/features/auth/models/login_response.dart';
import 'package:push_app_notification/features/auth/providers/auth_provider.dart';
import 'package:push_app_notification/features/auth/services/auth_service.dart';
import 'package:push_app_notification/features/home/providers/notifications_provider.dart';
import 'package:push_app_notification/features/shared/providers/loader_provider.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';
import 'package:push_app_notification/features/shared/services/snackbar_service.dart';
import 'package:push_app_notification/features/shared/services/storage_service.dart';
import 'package:push_app_notification/features/shared/widgets/form_wydnex.dart';

final registerProvider =
    StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
  return RegisterNotifier(ref);
});

class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier(this.ref)
      : super(
          RegisterState(
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
              ],
              formatters: [
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            repeatedPassword: FormWydnex<String>(
              value: '',
              validators: [
                const ValidatorWydnex(ValidatorsWydnex.required),
              ],
              formatters: [
                LengthLimitingTextInputFormatter(10),
              ],
            ),
          ),
        );
  final StateNotifierProviderRef ref;

  register() async {
    FocusManager.instance.primaryFocus
        ?.unfocus(); //hacer que el teclado se quite

    final user = FormWydnex(value: state.user.value);
    final password = FormWydnex(value: state.password.value);
    final repeatedPassword = FormWydnex(value: state.repeatedPassword.value);

    state = state.copyWith(
      user: user,
      password: password,
      repeatedPassword: repeatedPassword,
    );

    if (!state.isFormValid) return;
    if (state.password.value != state.repeatedPassword.value) return;
    ref.read(loaderProvider.notifier).mostrarLoader();

    try {
      await AuthService.register(
        user: state.user.value.toLowerCase(),
        password: state.password.value,
      );

      final LoginResponse loginResponse = await AuthService.login(
        user: state.user.value.toLowerCase(),
        password: state.password.value,
      );

      await StorageService.set<String>(
          StorageKeys.userToken, loginResponse.token);

      ref.read(authProvider.notifier).initAutoLogout();

      ref.read(authProvider.notifier).getUser();
      ref.read(authProvider.notifier).addDevice();
      ref.read(notificationsProvider.notifier).getNotifications();

      appRouter.go('/home');
    } on ServiceException catch (e) {
      SnackbarService.showSnackbar(message: e.message);
    }
    ref.read(loaderProvider.notifier).quitarLoader();
  }

  signUpWithFacebook() async {
    // Cerrar sesión antes de iniciar sesión nuevamente
    await FacebookAuth.instance.logOut();

    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final AccessToken accessToken = result.accessToken!;
      // print(accessToken);

      ref.read(loaderProvider.notifier).mostrarLoader();

      try {
        // Registrar el usuario con el token de acceso de Facebook
        await AuthService.registerFacebookAccount(
            accessToken: accessToken.tokenString);

        // Iniciar sesión con el mismo token de acceso
        final LoginResponse loginResponse =
            await AuthService.loginFacebookAccount(
          accessToken: accessToken.tokenString,
        );

        await StorageService.set<String>(
            StorageKeys.userToken, loginResponse.token);

        ref.read(authProvider.notifier).getUser();
        ref.read(authProvider.notifier).addDevice();
        ref.read(notificationsProvider.notifier).getNotifications();

        ref.read(authProvider.notifier).initAutoLogout();

        appRouter.go('/home');
      } on ServiceException catch (e) {
        SnackbarService.showSnackbar(message: e.message);
      }
      ref.read(loaderProvider.notifier).quitarLoader();
    } else {
      SnackbarService.showSnackbar(
          message: result.message ?? 'Error desconocido');
    }
  }

  signUpWithGoogle() async {
    // Cerrar sesión antes de iniciar sesión nuevamente
    await GoogleSignIn().signOut();

    // Iniciar sesión con Google
    GoogleSignInAccount? googleUsers = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? googleAuth = await googleUsers?.authentication;

    if (googleAuth == null) return;

    ref.read(loaderProvider.notifier).mostrarLoader();

    try {
      await AuthService.registerGoogleAccount(idToken: googleAuth.idToken!);

      final LoginResponse loginResponse = await AuthService.loginGoogleAccount(
        idToken: googleAuth.idToken!,
      );

      await StorageService.set<String>(
          StorageKeys.userToken, loginResponse.token);

      ref.read(authProvider.notifier).getUser();
      ref.read(authProvider.notifier).addDevice();
      ref.read(notificationsProvider.notifier).getNotifications();

      ref.read(authProvider.notifier).initAutoLogout();

      appRouter.go('/home');
    } on ServiceException catch (e) {
      SnackbarService.showSnackbar(message: e.message);
    }
    ref.read(loaderProvider.notifier).quitarLoader();
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

  changeRepeatedPassword(FormWydnex<String> repeatedPassword) {
    state = state.copyWith(
      repeatedPassword: repeatedPassword,
    );
  }
}

class RegisterState {
  final FormWydnex<String> user;
  final FormWydnex<String> password;
  final FormWydnex<String> repeatedPassword;
  final bool loading;
  bool get isFormValid {
    return user.isValid && password.isValid && repeatedPassword.isValid;
  }

  RegisterState({
    required this.user,
    required this.password,
    required this.repeatedPassword,
    this.loading = false,
  });

  RegisterState copyWith({
    FormWydnex<String>? user,
    FormWydnex<String>? password,
    FormWydnex<String>? repeatedPassword,
    bool? loading,
  }) {
    return RegisterState(
      user: user ?? this.user,
      password: password ?? this.password,
      repeatedPassword: repeatedPassword ?? this.repeatedPassword,
      loading: loading ?? this.loading,
    );
  }
}
