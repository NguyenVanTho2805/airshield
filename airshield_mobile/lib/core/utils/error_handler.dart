import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Global Error Handler
/// 
/// Centralized error handling and logging

class ErrorHandler {
  // Singleton pattern
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// Initialize error handling
  static void initialize() {
    // Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _instance.logError(
        details.exception,
        details.stack,
        reason: details.context?.toString(),
      );
    };

    // Catch async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _instance.logError(error, stack);
      return true;
    };
  }

  /// Log error with details
  void logError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) {
    // In development, print to console
    if (kDebugMode) {
      developer.log(
        'Error: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'AirShield',
      );
      if (reason != null) {
        developer.log('Reason: $reason', name: 'AirShield');
      }
    }

    // In production, send to crash reporting service
    // Example: Firebase Crashlytics, Sentry, etc.
    if (kReleaseMode) {
      _sendToErrorReporting(error, stackTrace, reason: reason, fatal: fatal);
    }
  }

  /// Send error to Sentry (configured via SENTRY_DSN dart-define)
  void _sendToErrorReporting(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) {
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (reason != null) scope.setTag('reason', reason);
        if (fatal) scope.level = SentryLevel.fatal;
      },
    ).ignore();
  }

  /// Handle and log async operation errors
  Future<T?> handleAsync<T>(
    Future<T> Function() operation, {
    String? operationName,
    T? fallbackValue,
    void Function(Object error)? onError,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      logError(
        error,
        stackTrace,
        reason: operationName,
      );
      onError?.call(error);
      return fallbackValue;
    }
  }

  /// Wrap sync operation with error handling
  T? handleSync<T>(
    T Function() operation, {
    String? operationName,
    T? fallbackValue,
    void Function(Object error)? onError,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      logError(
        error,
        stackTrace,
        reason: operationName,
      );
      onError?.call(error);
      return fallbackValue;
    }
  }

  /// Get user-friendly error message
  String getUserMessage(Object error) {
    if (error is FormatException) {
      return 'Invalid data format. Please check your input.';
    } else if (error is TypeError) {
      return 'A technical error occurred. Please try again.';
    } else if (error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    } else if (error.toString().contains('Unauthorized') ||
        error.toString().contains('401')) {
      return 'Session expired. Please log in again.';
    } else if (error.toString().contains('404')) {
      return 'Requested resource not found.';
    } else if (error.toString().contains('500')) {
      return 'Server error. Please try again later.';
    }
    
    // Default message
    return 'An unexpected error occurred. Please try again.';
  }
}
