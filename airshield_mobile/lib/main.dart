import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Core
import 'core/network/api_client.dart';
import 'core/services/location_service.dart';
import 'core/storage/preferences_storage.dart';
import 'core/storage/secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_bloc.dart';
import 'core/l10n/app_localizations.dart';
import 'core/l10n/language_bloc.dart';
import 'core/utils/error_handler.dart';
import 'core/widgets/error_boundary.dart';

// Auth Feature
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';

// Dashboard Feature
import 'features/dashboard/data/repositories/dashboard_repository.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';

// Notifications Feature
import 'features/notifications/data/services/notification_service.dart';
import 'features/notifications/presentation/bloc/notifications_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferencesStorage = PreferencesStorage();
  await preferencesStorage.init();

  const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.environment = kReleaseMode ? 'production' : 'development';
        options.tracesSampleRate = kReleaseMode ? 0.2 : 1.0;
      },
      appRunner: () {
        ErrorHandler.initialize();
        runApp(AirShieldApp(preferencesStorage: preferencesStorage));
      },
    );
  } else {
    ErrorHandler.initialize();
    runApp(AirShieldApp(preferencesStorage: preferencesStorage));
  }
}

class AirShieldApp extends StatefulWidget {
  final PreferencesStorage preferencesStorage;

  const AirShieldApp({
    super.key,
    required this.preferencesStorage,
  });

  @override
  State<AirShieldApp> createState() => _AirShieldAppState();
}

class _AirShieldAppState extends State<AirShieldApp> {
  late final SecureStorageService _secureStorage;
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final LocationService _locationService;
  late final DashboardRepository _dashboardRepository;
  late final NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _secureStorage = SecureStorageService();
    _apiClient = ApiClient(storage: _secureStorage);
    _authRepository = AuthRepository(apiClient: _apiClient, storage: _secureStorage);
    _locationService = LocationService();
    _dashboardRepository = DashboardRepository(
      apiClient: _apiClient,
      locationService: _locationService,
    );
    _notificationService = NotificationService();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(repository: _authRepository)
            ..add(const CheckAuthStatus()),
        ),
        BlocProvider(create: (_) => DashboardBloc(repository: _dashboardRepository)),
        RepositoryProvider<ApiClient>.value(value: _apiClient),
        BlocProvider(
          create: (_) => ThemeBloc(storage: widget.preferencesStorage)
            ..add(const LoadTheme()),
        ),
        BlocProvider(
          create: (_) => LanguageBloc(storage: widget.preferencesStorage)
            ..add(const LoadLanguage()),
        ),
        BlocProvider(
          create: (_) => NotificationsBloc(service: _notificationService)
            ..add(const LoadNotifications()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, languageState) {
              return ErrorBoundary(
                child: MaterialApp(
                  title: 'AirShield',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeState.themeMode,
                  locale: languageState.locale,
                  localizationsDelegates: [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('en'),
                    Locale('vi'),
                  ],
                  home: const AuthWrapper(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Auth Wrapper
/// 
/// Controls navigation between Login and Dashboard based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Load dashboard data when authenticated
        if (state is Authenticated) {
          context.read<DashboardBloc>().add(const LoadDashboardData());
        }
      },
      builder: (context, state) {
        // Show loading while checking auth status
        if (state is AuthInitial) {
          return const Scaffold(
            backgroundColor: Color(0xFF1A1A2E),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
              ),
            ),
          );
        }

        // Show dashboard if authenticated
        if (state is Authenticated) {
          return DashboardPage(
            apiClient: context.read<ApiClient>(),
          );
        }

        // Show login page if not authenticated (or error)
        return const LoginPage();
      },
    );
  }
}