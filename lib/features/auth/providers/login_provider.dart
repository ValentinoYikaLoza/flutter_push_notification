import 'dart:io';

import 'package:device_uuid/device_uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:push_app_notification/features/shared/providers/biometric_storage_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:push_app_notification/config/constants/storage_keys.dart';
import 'package:push_app_notification/config/router/app_router.dart';
import 'package:push_app_notification/features/auth/models/fingerprint_users_response.dart';
import 'package:push_app_notification/features/auth/models/login_response.dart';
import 'package:push_app_notification/features/auth/providers/auth_provider.dart';
import 'package:push_app_notification/features/auth/services/auth_service.dart';
import 'package:push_app_notification/features/auth/services/user_service.dart';
import 'package:push_app_notification/features/home/providers/notifications_provider.dart';
import 'package:push_app_notification/features/shared/providers/loader_provider.dart';
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
  final LocalAuthentication auth = LocalAuthentication();
  final Uuid uuid = const Uuid();
  final DeviceUuid deviceUuid = DeviceUuid();

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

  signIn() async {
    //PONER EL LOGOUT DE FIREBASE
    FocusManager.instance.primaryFocus
        ?.unfocus(); //hacer que el teclado se quite

    final user = FormWydnex(value: state.user.value);
    final password = FormWydnex(value: state.password.value);
    state = state.copyWith(
      user: user,
      password: password,
    );

    if (!state.isFormValid) return;

    ref.read(loaderProvider.notifier).mostrarLoader();

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

    ref.read(loaderProvider.notifier).quitarLoader();
  }

  signInWithFacebook() async {
    // Cerrar sesión antes de iniciar sesión nuevamente
    await FacebookAuth.instance.logOut();

    final LoginResult result = await FacebookAuth.instance.login(
      permissions: const ['email', 'public_profile'],
    );

    if (result.status == LoginStatus.success) {
      final AccessToken accessToken = result.accessToken!;
      print(accessToken.tokenString);

      ref.read(loaderProvider.notifier).mostrarLoader();

      try {
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

  signInWithGoogle() async {
    // Cerrar sesión antes de iniciar sesión nuevamente
    await GoogleSignIn().signOut();

    GoogleSignInAccount? googleUsers = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? googleAuth = await googleUsers?.authentication;

    if (googleAuth == null) return;

    ref.read(loaderProvider.notifier).mostrarLoader();

    try {
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

  prueba() async {
    await ref
        .read(biometricStorageProvider.notifier)
        .storeData('deviceInfo', 'gato');
  }

  prueba2() async {
    await ref
        .read(biometricStorageProvider.notifier)
        .readData('deviceInfo');
  }

  signInWithFingerprint(String username) async {
    final deviceInfo = await ref
        .read(biometricStorageProvider.notifier)
        .readData('deviceInfo');
    if (deviceInfo != null) {
      print('Dispositivo: $deviceInfo');
      final deviceInfoToken = uuid.v5(Uuid.NAMESPACE_URL, deviceInfo);
      print('Dispositivo encriptado: $deviceInfoToken');

      ref.read(loaderProvider.notifier).mostrarLoader();
      try {
        final LoginResponse loginResponse =
            await AuthService.loginWithFingerprint(
          username: username,
          deviceInfoToken: deviceInfoToken,
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
      print('No se pudo obtener la información del dispositivo.');
    }
  }

  generateDeviceInfo() async {
    try {
      DeviceUuid deviceUuid = DeviceUuid();
      String? deviceId = await deviceUuid.getUUID();
      if (deviceId == null) return;
      if (Platform.isAndroid) {
        ref
            .read(biometricStorageProvider.notifier)
            .storeData('deviceInfo', 'Android-$deviceId');
      } else if (Platform.isIOS) {
        ref
            .read(biometricStorageProvider.notifier)
            .storeData('deviceInfo', 'iOS-$deviceId');
      } else {
        throw UnsupportedError('Platform not supported');
      }
    } catch (e) {
      print('Error getting device info: $e');
      return null;
    }
  }

  toggleFingerprint() async {
    final storage = ref.read(biometricStorageProvider);
    final bool canAuthenticate = storage.canAuthenticate;
    try {
      if (canAuthenticate) {
        await generateDeviceInfo();
        final deviceInfo = await ref
            .read(biometricStorageProvider.notifier)
            .readData('deviceInfo');
        if (deviceInfo != null) {
          print('Dispositivo: $deviceInfo');
          final deviceInfoToken = uuid.v5(Uuid.NAMESPACE_URL, deviceInfo);
          print('Dispositivo encriptado: $deviceInfoToken');

          ref.read(loaderProvider.notifier).mostrarLoader();
          try {
            await UserService.toggleFingerprint(
              deviceInfoToken: deviceInfoToken,
            );
            ref.read(authProvider.notifier).getUser();
            ref.read(loaderProvider.notifier).quitarLoader();
          } on ServiceException catch (e) {
            SnackbarService.showSnackbar(message: e.message);
          }
          ref.read(loaderProvider.notifier).quitarLoader();
        } else {
          print('No se pudo obtener la información del dispositivo.');
        }
      }
    } on PlatformException catch (e) {
      SnackbarService.showSnackbar(message: 'Error: ${e.message}');
    }
  }

  authenticateFingerprint() async {
    final storage = ref.watch(biometricStorageProvider);
    try {
      final bool didAuthenticate = storage.canAuthenticate;
      if (didAuthenticate) {
        final deviceInfo = await ref
            .read(biometricStorageProvider.notifier)
            .readData('deviceInfo');
        if (deviceInfo != null) {
          print('Dispositivo: $deviceInfo');
          final deviceInfoToken = uuid.v5(Uuid.NAMESPACE_URL, deviceInfo);
          print('Dispositivo encriptado: $deviceInfoToken');
          ref.read(loaderProvider.notifier).mostrarLoader();
          try {
            final FingerprintUsersResponse response =
                await AuthService.getUsersWithFingerprintToken(
              deviceInfoToken: deviceInfoToken,
            );

            state = state.copyWith(
              fingerprintEnabled: didAuthenticate,
              users: response.users,
            );
          } on ServiceException catch (e) {
            SnackbarService.showSnackbar(message: e.message);
          }
          ref.read(loaderProvider.notifier).quitarLoader();
        } else {
          print('No se pudo obtener la información del dispositivo.');
        }
      } else {
        SnackbarService.showSnackbar(message: 'No autenticado');
      }
    } on PlatformException catch (e) {
      SnackbarService.showSnackbar(message: 'Error: ${e.message}');
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

  final List<User> users;
  final bool fingerprintEnabled;

  LoginState({
    required this.user,
    required this.password,
    this.loading = false,
    this.rememberMe = false,
    this.users = const [],
    this.fingerprintEnabled = false,
  });

  LoginState copyWith({
    FormWydnex<String>? user,
    FormWydnex<String>? password,
    bool? loading,
    bool? rememberMe,
    List<User>? users,
    bool? fingerprintEnabled,
  }) =>
      LoginState(
        user: user ?? this.user,
        password: password ?? this.password,
        loading: loading ?? this.loading,
        rememberMe: rememberMe ?? this.rememberMe,
        users: users ?? this.users,
        fingerprintEnabled: fingerprintEnabled ?? this.fingerprintEnabled,
      );
}
