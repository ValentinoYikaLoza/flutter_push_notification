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

// Clase que maneja el estado y las acciones del login
class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier(this.ref)
      : super(
          LoginState(
            // Inicialización de los campos del formulario de login
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

  final StateNotifierProviderRef ref; // Referencia al proveedor
  final LocalAuthentication auth =
      LocalAuthentication(); // Objeto para autenticación local
  final Uuid uuid = const Uuid(); // Generador de UUIDs
  final DeviceUuid deviceUuid =
      DeviceUuid(); // Objeto para obtener el UUID del dispositivo

  // Inicialización de datos
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

  // Método para iniciar sesión
  signIn() async {
    FocusManager.instance.primaryFocus?.unfocus();

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

  // Método para iniciar sesión con Facebook
  signInWithFacebook() async {
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

  // Método para iniciar sesión con Google
  signInWithGoogle() async {
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

  // Método para iniciar sesión con huella dactilar
  signInWithFingerprint(String username) async {
    final deviceInfo = await generateDeviceInfo();
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
      SnackbarService.showSnackbar(
          message:
              'Huella no registrada, ingresa para registrar la nueva huella');
    }
  }

  // Generar información del dispositivo
  generateDeviceInfo() async {
    try {
      DeviceUuid deviceUuid = DeviceUuid();
      String? deviceId = await deviceUuid.getUUID();
      if (deviceId == null) return;
      if (Platform.isAndroid) {
        ref
            .read(biometricStorageProvider.notifier)
            .storeData('deviceInfo', 'Android-$deviceId');
        return 'Android-$deviceId';
      } else if (Platform.isIOS) {
        ref
            .read(biometricStorageProvider.notifier)
            .storeData('deviceInfo', 'iOS-$deviceId');
        return 'iOS-$deviceId';
      } else {
        throw UnsupportedError('Platform not supported');
      }
    } catch (e) {
      print('Error getting device info: $e');
      return null;
    }
  }

  // Alternar estado de la huella dactilar
  toggleFingerprint() async {
    final storage = ref.read(biometricStorageProvider);
    final bool canAuthenticate = storage.canAuthenticate;
    try {
      if (canAuthenticate) {
        final deviceInfo = await ref
            .read(biometricStorageProvider.notifier)
            .readData('deviceInfo');
        if (deviceInfo != null) {
          final deviceInfoToken = uuid.v5(Uuid.NAMESPACE_URL, deviceInfo);
          ref.read(loaderProvider.notifier).mostrarLoader();
          try {
            await UserService.toggleFingerprint(
              deviceInfoToken: deviceInfoToken,
            );
            await ref.read(authProvider.notifier).getUser();
            ref.read(loaderProvider.notifier).quitarLoader();
          } on ServiceException catch (e) {
            SnackbarService.showSnackbar(message: e.message);
          }
          ref.read(loaderProvider.notifier).quitarLoader();
        } else {
          SnackbarService.showSnackbar(
              message:
                  'Huella no registrada, ingresa para registrar la nueva huella');
        }
      } else {
        SnackbarService.showSnackbar(
            message: 'La autenticación biométrica no está disponible.');
      }
    } on PlatformException catch (e) {
      SnackbarService.showSnackbar(message: 'Error: ${e.message}');
    } catch (e) {
      SnackbarService.showSnackbar(
          message: 'Autenticación cancelada o fallida: $e');
    }
  }

  // Autenticar huella dactilar
  authenticateFingerprint() async {
    final storage = ref.watch(biometricStorageProvider);
    try {
      final bool canAuthenticate = storage.canAuthenticate;
      if (canAuthenticate) {
        final deviceInfo = await ref
            .read(biometricStorageProvider.notifier)
            .readData('deviceInfo');
        state = state.copyWith(
          fingerprintEnabled: deviceInfo != null,
        );
        if (deviceInfo != null) {
          print('Dispositivo: $deviceInfo');
          print('Fingerprint enabled: ${state.fingerprintEnabled}');
          final deviceInfoToken = uuid.v5(Uuid.NAMESPACE_URL, deviceInfo);
          print('Dispositivo encriptado: $deviceInfoToken');
          ref.read(loaderProvider.notifier).mostrarLoader();
          try {
            final FingerprintUsersResponse response =
                await AuthService.getUsersWithFingerprintToken(
              deviceInfoToken: deviceInfoToken,
            );
            state = state.copyWith(
              users: response.users,
            );
          } on ServiceException catch (e) {
            SnackbarService.showSnackbar(message: e.message);
          }
          ref.read(loaderProvider.notifier).quitarLoader();
        } else {
          SnackbarService.showSnackbar(
              message:
                  'Huella no registrada, ingresa para registrar la nueva huella');
        }
      } else {
        SnackbarService.showSnackbar(message: 'No autenticado');
      }
    } on PlatformException catch (e) {
      SnackbarService.showSnackbar(message: 'Error: ${e.message}');
    }
  }

  // Guardar la preferencia de recordar usuario
  setRemember() async {
    await StorageService.set<bool>(StorageKeys.rememberMe, state.rememberMe);
  }

  // Cambiar el valor del usuario en el formulario
  changeUser(FormWydnex<String> user) {
    state = state.copyWith(
      user: user,
    );
  }

  // Cambiar el valor de la contraseña en el formulario
  changePassword(FormWydnex<String> password) {
    state = state.copyWith(
      password: password,
    );
  }

  // Alternar la preferencia de recordar usuario
  toggleRememberMe() {
    state = state.copyWith(
      rememberMe: !state.rememberMe,
    );
  }
}

// Estado del login
class LoginState {
  final FormWydnex<String> user; // Campo de usuario del formulario
  final FormWydnex<String> password; // Campo de contraseña del formulario
  final bool loading; // Indicador de carga
  final bool rememberMe; // Preferencia de recordar usuario
  bool get isFormValid {
    return user.isValid && password.isValid;
  }

  final List<User> users; // Lista de usuarios
  final bool fingerprintEnabled; // Indicador de huella dactilar habilitada

  LoginState({
    required this.user,
    required this.password,
    this.loading = false,
    this.rememberMe = false,
    this.users = const [],
    this.fingerprintEnabled = false,
  });

  // Método para copiar el estado y actualizar valores específicos
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