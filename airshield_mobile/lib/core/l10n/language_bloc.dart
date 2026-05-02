import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/preferences_storage.dart';

// ==================== EVENTS ====================

abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object?> get props => [];
}

/// Change language
class ChangeLanguage extends LanguageEvent {
  final Locale locale;

  const ChangeLanguage(this.locale);

  @override
  List<Object?> get props => [locale];
}

/// Load saved language
class LoadLanguage extends LanguageEvent {
  const LoadLanguage();
}

// ==================== STATES ====================

class LanguageState extends Equatable {
  final Locale locale;

  const LanguageState({this.locale = const Locale('en')});

  LanguageState copyWith({Locale? locale}) {
    return LanguageState(locale: locale ?? this.locale);
  }

  @override
  List<Object?> get props => [locale];
}

// ==================== BLOC ====================

/// Language BLoC
/// 
/// Manages language state and persistence
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final PreferencesStorage _storage;

  LanguageBloc({required PreferencesStorage storage})
      : _storage = storage,
        super(const LanguageState()) {
    on<LoadLanguage>(_onLoadLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
  }

  /// Load saved language preference
  Future<void> _onLoadLanguage(
    LoadLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    final savedLanguage = _storage.getLanguageCode();
    if (savedLanguage != null) {
      emit(state.copyWith(locale: Locale(savedLanguage)));
    }
  }

  /// Change language and persist
  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    emit(state.copyWith(locale: event.locale));
    await _storage.saveLanguageCode(event.locale.languageCode);
  }
}
