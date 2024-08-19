import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:push_app_notification/config/constants/storage_keys.dart';
import 'package:push_app_notification/config/router/app_router.dart';
import 'package:push_app_notification/features/auth/models/auth_response.dart';
import 'package:push_app_notification/features/auth/services/auth_service.dart';
import 'package:push_app_notification/features/auth/services/device_service.dart';
import 'package:push_app_notification/features/auth/services/user_service.dart';
import 'package:push_app_notification/features/home/providers/notifications_provider.dart';
import 'package:push_app_notification/features/shared/providers/loader_provider.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';
import 'package:push_app_notification/features/shared/services/snackbar_service.dart';
import 'package:push_app_notification/features/shared/services/storage_service.dart';

// Proveedor de estado para la autenticación
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

// Clase que maneja el estado y las acciones de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this.ref) : super(AuthState());
  final StateNotifierProviderRef ref;

  // Método para obtener el usuario autenticado
  getUser() async {
    ref.read(loaderProvider.notifier).mostrarLoader();

    try {
      final AuthResponse response = await UserService.getUser();

      await StorageService.set<String>(
          StorageKeys.username, response.user.username);

      state = state.copyWith(
        fingerprintEnabled: response.hasFingerprintToken,
      );

      setuser(response.user);
    } on ServiceException catch (e) {
      SnackbarService.showSnackbar(message: e.message);
    }
    ref.read(loaderProvider.notifier).quitarLoader();
  }

  // Método para añadir un dispositivo
  addDevice() async {
    final deviceToken =
        await ref.read(notificationsProvider.notifier).getFCMToken();

    if (deviceToken == null) return;

    ref.read(loaderProvider.notifier).mostrarLoader();
    try {
      final response = await DeviceService.addDevice(
        deviceToken: deviceToken,
      );

      if (response.status == 201) {
        print('nuevo dispositivo registrado');
      } else {
        print('dispositivo ya ha sido registrado');
      }
    } on ServiceException catch (e) {
      SnackbarService.showSnackbar(message: e.message);
    }
    ref.read(loaderProvider.notifier).quitarLoader();
  }

  // Método para establecer el usuario en el estado
  setuser(User user) {
    state = state.copyWith(
      username: user.username,
      userId: user.id,
    );
  }

  Timer? timer; // Temporizador para el cierre de sesión automático

  // Inicializar el cierre de sesión automático
  initAutoLogout() async {
    cancelTimer();
    final (validToken, timeRemainingInSeconds) =
        await AuthService.verifyToken();

    if (validToken) {
      timer = Timer(Duration(seconds: timeRemainingInSeconds), () {
        logOut();
      });
    }
  }

  // Método para cerrar sesión
  logOut() async {
    await ref.read(notificationsProvider.notifier).deleteFMCToken();

    await StorageService.remove('userToken');
    cancelTimer();
    appRouter.go('/login');
  }

  // Método para cancelar el temporizador
  cancelTimer() {
    if (timer != null) {
      timer!.cancel();
    }
  }
}

//Modelo o entidad de AuthState
class AuthState {
  final String username;
  final int userId;
  final bool fingerprintEnabled;

  AuthState({
    this.username = '',
    this.userId = 0,
    this.fingerprintEnabled = false,
  });

  // Método para copiar el estado y actualizar valores específicos
  AuthState copyWith({
    String? username,
    int? userId,
    bool? fingerprintEnabled,
  }) {
    return AuthState(
      username: username ?? this.username,
      userId: userId ?? this.userId,
      fingerprintEnabled: fingerprintEnabled ?? this.fingerprintEnabled,
    );
  }
}
