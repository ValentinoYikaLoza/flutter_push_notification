import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_app_notification/config/constants/storage_keys.dart';
import 'package:push_app_notification/features/home/services/get_api_key_service.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';
import 'package:push_app_notification/features/shared/services/storage_service.dart';


final getApiKeyProvider =
    StateNotifierProvider<GetApiKeyNotifier, GetApiKeyState>((ref) {
  return GetApiKeyNotifier(ref);
});

class GetApiKeyNotifier extends StateNotifier<GetApiKeyState> {
  GetApiKeyNotifier(this.ref) : super(GetApiKeyState());
  final StateNotifierProviderRef ref;

  getApiKey() async {
    try {
      // Llama al servicio para obtener el token
      final apiKey = await GetApiKeyService().getApiKey();

      final apiKeyFormatter = apiKey.replaceAll('"','');

      //Guarda el token en el almacenamiento local
      await StorageService.set<String>(StorageKeys.apiKey, apiKeyFormatter);

      // Actualiza el estado para reflejar que se ha obtenido el token correctamente
      state = state.copyWith(
        apiKey: apiKeyFormatter,
      );
    } catch (e) {
      // Maneja errores de manera adecuada
      throw ServiceException('Algo salió mal.');
    }
  }
}

class GetApiKeyState {
  final String apiKey;

  GetApiKeyState({
    this.apiKey = '',
  });

  GetApiKeyState copyWith({
    String? apiKey,
  }) {
    return GetApiKeyState(
      apiKey: apiKey ?? this.apiKey,
    );
  }
}
