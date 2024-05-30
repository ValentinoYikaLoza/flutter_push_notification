import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_app_notification/config/constants/storage_keys.dart';
import 'package:push_app_notification/config/router/app_router.dart';
import 'package:push_app_notification/features/auth/models/auth_response.dart';
import 'package:push_app_notification/features/auth/services/auth_service.dart';
import 'package:push_app_notification/features/home/models/get_devices_model.dart';
import 'package:push_app_notification/features/home/providers/notifications_provider.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';
import 'package:push_app_notification/features/shared/services/storage_service.dart';

//hace la verificación del token
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this.ref) : super(AuthState());
  final StateNotifierProviderRef ref;

  getUser() async {
    try {
      final AuthResponse response = await AuthService.getUser();

      await StorageService.set<String>(
          StorageKeys.username, response.user.username);
      await StorageService.set<int>(StorageKeys.userId, response.user.id);

      setuser(response.user);
    } on ServiceException catch (e) {
      throw ServiceException(e.message);
    }
  }

  getDevice() async {
    final deviceToken =
        await ref.read(notificationsProvider.notifier).getFCMToken();

    final userId = await StorageService.get<int>(StorageKeys.userId);

    if (userId == null || deviceToken == null) return;

    final GetDevicesResponse response = await GetDevicesService.getDevices(
      userId: userId,
    );

    // Check if devices exist
    if (response.status == 404) {
      await AddDeviceService.addDevice(
        userId: userId,
        deviceToken: deviceToken,
      );
      print('nuevo dispositivo registrado');
    } else {
      for (var device in response.devices!) {
        if (deviceToken == device.deviceToken) {
          print('dispositivo ya ha sido registrado');
          break;
        }
      }
    }
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
