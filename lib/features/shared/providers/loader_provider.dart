import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loaderProvider =
    StateNotifierProvider<LoaderNotifier, LoaderState>((ref) {
  return LoaderNotifier();
});

class LoaderNotifier extends StateNotifier<LoaderState> {
  LoaderNotifier() : super(LoaderState());

  mostrarLoader([String title = 'Cargando']) {
    if (state.loading) return;
    FocusManager.instance.primaryFocus?.unfocus();

    state = state.copyWith(
      loading: true,
      title: title,
    );
  }

  quitarLoader() {
    if (!state.loading) return;

    state = state.copyWith(
      loading: false,
    );
  }
}

class LoaderState {
  final bool loading;
  final String? title;

  LoaderState({
    this.loading = false,
    this.title,
  });

  LoaderState copyWith({
    bool? loading,
    String? title,
  }) =>
      LoaderState(
        loading: loading ?? this.loading,
        title: title ?? this.title,
      );
}
