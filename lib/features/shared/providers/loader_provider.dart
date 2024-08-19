import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Proveedor de estado para el cargador (loader)
final loaderProvider =
    StateNotifierProvider<LoaderNotifier, LoaderState>((ref) {
  return LoaderNotifier();
});

// Notificador de estado que maneja el estado de carga
class LoaderNotifier extends StateNotifier<LoaderState> {
  LoaderNotifier() : super(LoaderState());

  // Método para mostrar el loader
  mostrarLoader([String title = 'Cargando']) {
    if (state.loading) return;
    FocusManager.instance.primaryFocus?.unfocus();

    state = state.copyWith(
      loading: true,
      title: title,
    );
  }

  // Método para quitar el loader
  quitarLoader() {
    if (!state.loading) return;

    state = state.copyWith(
      loading: false,
    );
  }
}

// Clase que representa el estado del loader
class LoaderState {
  final bool loading;
  final String? title;

  LoaderState({
    this.loading = false,
    this.title,
  });

  // Método para copiar el estado y actualizar valores específicos
  LoaderState copyWith({
    bool? loading,
    String? title,
  }) =>
      LoaderState(
        loading: loading ?? this.loading,
        title: title ?? this.title,
      );
}
