import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_app_notification/features/auth/models/auth_user.dart';
import 'package:push_app_notification/features/auth/services/auth_service.dart';
import 'package:push_app_notification/features/shared/services/storage_service.dart';

import '../../../config/router/app_router.dart';



//hace la verificación del token
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this.ref) : super(AuthState());
  final StateNotifierProviderRef ref;
  
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
  final AuthUser? user;

  AuthState({
    this.user,
  });

  AuthState copyWith({
    ValueGetter<AuthUser?>? user,
  }) =>
      AuthState(
        user: user != null ? user() : this.user,
      );
}
