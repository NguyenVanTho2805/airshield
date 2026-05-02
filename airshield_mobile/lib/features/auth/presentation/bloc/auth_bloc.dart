import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

// ==================== EVENTS ====================

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if user is already logged in
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

/// Login with email and password
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Register new account
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

/// Logout current user
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Skip auth — enter demo mode with a mock user (dev/presentation only)
class DemoLoginRequested extends AuthEvent {
  const DemoLoginRequested();
}

// ==================== STATES ====================

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - checking auth status
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during auth operations
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state with user data
class Authenticated extends AuthState {
  final User user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Not authenticated
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Auth error state
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

/// Auth BLoC
/// 
/// Manages authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc({required AuthRepository repository})
      : _repository = repository,
        super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<DemoLoginRequested>(_onDemoLoginRequested);
  }

  /// Check if user is already logged in
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await _repository.isLoggedIn();
    
    if (isLoggedIn) {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(const Unauthenticated());
      }
    } else {
      emit(const Unauthenticated());
    }
  }

  /// Handle login request
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final response = await _repository.login(
        LoginRequest(email: event.email, password: event.password),
      );
      emit(Authenticated(user: response.user));
    } on AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Login failed: ${e.toString()}'));
    }
  }

  /// Handle register request
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final response = await _repository.register(
        RegisterRequest(
          name: event.name,
          email: event.email,
          password: event.password,
        ),
      );
      emit(Authenticated(user: response.user));
    } on AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Registration failed: ${e.toString()}'));
    }
  }

  /// Demo mode — emit Authenticated with a mock user, no network call
  Future<void> _onDemoLoginRequested(
    DemoLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    const mockUser = User(
      id: 'demo-user-001',
      email: 'demo@airshield.app',
      name: 'Demo User',
      aqiSensitivityLevel: 3,
      customAqiThreshold: 100,
    );
    emit(const Authenticated(user: mockUser));
  }

  /// Handle logout request
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    emit(const Unauthenticated());
  }
}
