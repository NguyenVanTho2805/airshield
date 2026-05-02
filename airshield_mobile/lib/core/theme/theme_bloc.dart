import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/preferences_storage.dart';

// ==================== EVENTS ====================

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Change theme mode
class ChangeTheme extends ThemeEvent {
  final ThemeMode themeMode;

  const ChangeTheme(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

/// Load saved theme
class LoadTheme extends ThemeEvent {
  const LoadTheme();
}

// ==================== STATES ====================

class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({this.themeMode = ThemeMode.dark});

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }

  @override
  List<Object?> get props => [themeMode];
}

// ==================== BLOC ====================

/// Theme BLoC
/// 
/// Manages theme state and persistence
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final PreferencesStorage _storage;

  ThemeBloc({required PreferencesStorage storage})
      : _storage = storage,
        super(const ThemeState()) {
    on<LoadTheme>(_onLoadTheme);
    on<ChangeTheme>(_onChangeTheme);
  }

  /// Load saved theme preference
  Future<void> _onLoadTheme(
    LoadTheme event,
    Emitter<ThemeState> emit,
  ) async {
    final savedTheme = _storage.getThemeMode();
    if (savedTheme != null) {
      final themeMode = _themeModeFromString(savedTheme);
      emit(state.copyWith(themeMode: themeMode));
    }
  }

  /// Change theme and persist
  Future<void> _onChangeTheme(
    ChangeTheme event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(themeMode: event.themeMode));
    await _storage.saveThemeMode(_themeModeToString(event.themeMode));
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
