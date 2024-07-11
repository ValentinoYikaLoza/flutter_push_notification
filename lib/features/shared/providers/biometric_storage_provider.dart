import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:push_app_notification/features/shared/services/snackbar_service.dart';

final biometricStorageProvider =
    StateNotifierProvider<BiometricStorageNotifier, BiometricStorageState>(
        (ref) {
  return BiometricStorageNotifier(ref);
});

class BiometricStorageNotifier extends StateNotifier<BiometricStorageState> {
  BiometricStorageNotifier(this.ref) : super(BiometricStorageState());

  final StateNotifierProviderRef ref;

  checkBiometricSupport() async {
    final canAuthenticate = await  BiometricStorage().canAuthenticate();
    print('Biometrics: $canAuthenticate');
    if (canAuthenticate != CanAuthenticateResponse.success) {
      state = state.copyWith(
        canAuthenticate: false,
        message: 'El dispositivo no admite autenticación biométrica.',
      );
      SnackbarService.showSnackbar(message: state.message);
    } else {
      state = state.copyWith(
        canAuthenticate: true,
        message: '',
      );
      SnackbarService.showSnackbar(message: state.message);
    }
  }

  storeData(String key, String data, [bool authRequired = true]) async {
    try {
      final storageFile = await BiometricStorage().getStorage(
        key,
        options: StorageFileInitOptions(authenticationRequired: authRequired),
      );
      print('Comenzó');
      await storageFile.write(
        data,
        promptInfo: const PromptInfo(
          androidPromptInfo:
              AndroidPromptInfo(title: 'Authenticate to store data'),
          iosPromptInfo: IosPromptInfo(saveTitle: 'Authenticate to store data'),
        ),
      );
      print('Finalizó');
    } on BiometricStorageException catch (e) {
      SnackbarService.showSnackbar(message: e.message);
    } catch (e) {
      throw Exception('Error reading data: $e');
    }
  }

  readData(String key, [bool authRequired = true]) async {
    try {
      final storageFile = await BiometricStorage().getStorage(
        key,
        promptInfo: const PromptInfo(
          androidPromptInfo:
              AndroidPromptInfo(title: 'Authenticate to access'),
          iosPromptInfo:
              IosPromptInfo(saveTitle: 'Authenticate to access'),
        ),
      );
      final String? data = await storageFile.read();
      print('data: $data');
      return data;
    } on BiometricStorageException catch (e) {
      SnackbarService.showSnackbar(message: e.message);
    } catch (e) {
      throw Exception('Error reading data: $e');
    }
  }

  deleteData(String key, [bool authRequired = true]) async {
    try {
      final storageFile = await BiometricStorage().getStorage(
        key,
        options: StorageFileInitOptions(authenticationRequired: authRequired),
      );
      await storageFile.delete(
        promptInfo: const PromptInfo(
          androidPromptInfo:
              AndroidPromptInfo(title: 'Authenticate to delete data'),
          iosPromptInfo:
              IosPromptInfo(saveTitle: 'Authenticate to delete data'),
        ),
      );
    } on BiometricStorageException catch (e) {
      SnackbarService.showSnackbar(message: e.message);
    } catch (e) {
      throw Exception('Error reading data: $e');
    }
  }
}

class BiometricStorageState {
  final bool canAuthenticate;
  final String message;
  BiometricStorageState({
    this.canAuthenticate = false,
    this.message = '',
  });

  BiometricStorageState copyWith({
    bool? canAuthenticate,
    String? message,
  }) {
    return BiometricStorageState(
      canAuthenticate: canAuthenticate ?? this.canAuthenticate,
      message: message ?? this.message,
    );
  }
}
