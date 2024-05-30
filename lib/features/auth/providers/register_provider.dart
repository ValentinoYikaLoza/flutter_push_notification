import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:push_app_notification/config/router/app_router.dart';
import 'package:push_app_notification/features/auth/services/auth_service.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';
import 'package:push_app_notification/features/shared/services/snackbar_service.dart';
import 'package:push_app_notification/features/shared/widgets/form_wydnex.dart';

final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
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
      repeatedPassword: repeatedPassword
    );

    if (!state.isFormValid) return;
    if (state.password.value != state.repeatedPassword.value) return;

    try {
      await AuthService.register(
        user: state.user.value,
        password: state.password.value,
      );

      appRouter.go('/login');
    } on ServiceException catch (e) {
      SnackbarService.showSnackbar(message: e.message);
    }
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
