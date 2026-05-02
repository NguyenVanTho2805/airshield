import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Error Boundary Widget
/// 
/// Catches errors in widget tree and displays fallback UI

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final VoidCallback? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Set up error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() {
        _error = details.exception;
        _stackTrace = details.stack;
      });
      widget.onError?.call();
    };
  }

  void _reset() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace) ??
          _DefaultErrorWidget(
            error: _error!,
            stackTrace: _stackTrace,
            onReset: _reset,
          );
    }

    return widget.child;
  }
}

/// Default Error Widget
class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onReset;

  const _DefaultErrorWidget({
    required this.error,
    this.stackTrace,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We encountered an unexpected error. Please try again.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh),
                label: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // In production, this would send error report
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error report sent. Thank you!',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  );
                },
                child: Text(
                  'Report Issue',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// BLoC Error Handler Widget
/// 
/// Wraps BLoC widgets and handles errors in state

class BlocErrorHandler<B extends BlocBase<S>, S> extends StatelessWidget {
  final Widget child;
  final bool Function(S state)? isError;
  final String Function(S state)? errorMessage;
  final VoidCallback? onRetry;

  const BlocErrorHandler({
    super.key,
    required this.child,
    this.isError,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      builder: (context, state) {
        // Check if state is an error state
        if (isError?.call(state) ?? false) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage?.call(state) ?? 'An error occurred',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        'Retry',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return child;
      },
    );
  }
}
