import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:push_app_notification/features/shared/services/snackbar_service.dart';

// Proveedor de estado para el almacenamiento biométrico
final biometricStorageProvider =
    StateNotifierProvider<BiometricStorageNotifier, BiometricStorageState>(
        (ref) {
  return BiometricStorageNotifier(ref);
});

// Clase que maneja el estado y las acciones del almacenamiento biométrico
class BiometricStorageNotifier extends StateNotifier<BiometricStorageState> {
  BiometricStorageNotifier(this.ref) : super(BiometricStorageState());

  final StateNotifierProviderRef ref;

  // Método para verificar el soporte biométrico del dispositivo
  checkBiometricSupport() async {
    final canAuthenticate = await BiometricStorage().canAuthenticate();
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

  // Método para almacenar datos biométricos
  storeData(String key, String data) async {
    try {
      final storageFile = await BiometricStorage().getStorage(key,
          promptInfo: const PromptInfo(
              androidPromptInfo:
                  AndroidPromptInfo(title: 'Authenticate to store data'),
              iosPromptInfo:
                  IosPromptInfo(saveTitle: 'Authenticate to store data')),
          options: StorageFileInitOptions(authenticationRequired: false));
      print('Comenzó');
      await storageFile.write(data);
      print('Finalizó');
    } on BiometricStorageException catch (e) {
      SnackbarService.showSnackbar(message: e.message);
    } catch (e) {
      throw Exception('Error reading data: $e');
    }
  }

  // Método para leer datos biométricos
  readData(String key) async {
    try {
      final storageFile = await BiometricStorage().getStorage(
        key,
        promptInfo: const PromptInfo(
            androidPromptInfo:
                AndroidPromptInfo(title: 'Authenticate to read data'),
            iosPromptInfo:
                IosPromptInfo(saveTitle: 'Authenticate to read data')),
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

  // Método para eliminar datos biométricos
  deleteData(String key) async {
    try {
      final storageFile = await BiometricStorage().getStorage(key,
          promptInfo: const PromptInfo(
            androidPromptInfo:
                AndroidPromptInfo(title: 'Authenticate to delete data'),
            iosPromptInfo:
                IosPromptInfo(saveTitle: 'Authenticate to delete data'),
          ),
          options: StorageFileInitOptions(authenticationRequired: true));
      await storageFile.delete();
    } on BiometricStorageException catch (e) {
      SnackbarService.showSnackbar(message: e.message);
    } catch (e) {
      throw Exception('Error reading data: $e');
    }
  }
}

// Modelo o entidad de BiometricStorageState
class BiometricStorageState {
  final bool canAuthenticate;
  final String message;
  BiometricStorageState({
    this.canAuthenticate = false,
    this.message = '',
  });

  // Método para copiar el estado y actualizar valores específicos
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
