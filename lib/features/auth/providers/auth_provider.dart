import 'dart:async';

import 'package:flutter/material.dart';
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

//hace la verificación del token
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this.ref) : super(AuthState());
  final StateNotifierProviderRef ref;

  getUser() async {
    ref.read(loaderProvider.notifier).mostrarLoader();

    try {
      final AuthResponse response = await UserService.getUser();

      await StorageService.set<String>(
          StorageKeys.username, response.user.username);

      setuser(response.user);
    } on ServiceException catch (e) {
      SnackbarService.showSnackbar(message: e.message);
    }
    ref.read(loaderProvider.notifier).quitarLoader();
  }

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

  setuser(User? user) {
    state = state.copyWith(
      user: () => user,
    );
  }

  Timer? timer;

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

  logOut() async {
    await ref.read(notificationsProvider.notifier).deleteFMCToken();

    await StorageService.remove('userToken');
    cancelTimer();
    appRouter.go('/login');
  }

  cancelTimer() {
    if (timer != null) {
      timer!.cancel();
    }
  }
}

//Modelo o entidad de AuthState
class AuthState {
  final User? user;

  AuthState({
    this.user,
  });

  AuthState copyWith({
    ValueGetter<User?>? user,
  }) =>
      AuthState(
        user: user != null ? user() : this.user,
      );
}
