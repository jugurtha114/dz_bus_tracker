/// lib/main_dev.dart

import 'dart:async'; // For runZonedGuarded

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For system UI overlay style
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart'; // For Firebase initialization
import 'package:go_router/go_router.dart';

import 'config/themes/app_theme.dart';
import 'core/constants/app_constants.dart'; // For App Name
import 'core/di/service_locator.dart' as di; // Service locator setup
import 'core/enums/language.dart';
import 'core/utils/date_utils.dart'; // For localization init
import 'core/utils/logger.dart'; // For logging
// Import global BLoCs/Cubits (ensure they exist and are registered in DI)
import 'presentation/blocs/app_settings/app_settings_cubit.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/driver_bus/driver_bus_bloc.dart';
import 'presentation/blocs/driver_dashboard/driver_dashboard_bloc.dart';
import 'presentation/blocs/driver_profile/driver_profile_bloc.dart';
import 'presentation/blocs/favorites/favorites_bloc.dart';
import 'presentation/blocs/line_details/line_details_bloc.dart'; // If globally provided
import 'presentation/blocs/line_list/line_list_bloc.dart'; // If globally provided
import 'presentation/blocs/notification_list/notification_list_bloc.dart';
import 'presentation/blocs/tracking_control/tracking_control_bloc.dart';
// Import Router
import 'presentation/routes/app_router.dart';

/// A simple BLoC observer for logging state changes and errors during development.
class SimpleBlocObserver extends BlocObserver {
  const SimpleBlocObserver();

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    Log.d('BLOC_OBSERVER: ${bloc.runtimeType} created');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    Log.d('BLOC_OBSERVER: ${bloc.runtimeType} event: $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is Cubit) {
      // Cubit doesn't have distinct events, just state changes
      Log.d('BLOC_OBSERVER: ${bloc.runtimeType} changed: ${change.nextState}');
    }
    // For Bloc, transition is more informative, handled below
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    Log.d('BLOC_OBSERVER: ${bloc.runtimeType} transition: ${transition.currentState.runtimeType} -> ${transition.nextState.runtimeType} (Event: ${transition.event.runtimeType})');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    // Log.e('BLOC_OBSERVER: ${bloc.runtimeType} error', error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    Log.d('BLOC_OBSERVER: ${bloc.runtimeType} closed');
  }
}


/// The main entry point for the DEVELOPMENT build of the application.
Future<void> main() async {
  // Use runZonedGuarded for consistency, though error reporting service might not be active
  await runZonedGuarded<Future<void>>(
        () async {
      // Ensure Flutter bindings are initialized
      WidgetsFlutterBinding.ensureInitialized();

      Log.i("Running DEVELOPMENT main entry point.");

      // Try to initialize Firebase, but proceed even if it fails
      bool firebaseInitialized = false;
      try {
        // Initialize Firebase (assumes you have configuration set up)
        await Firebase.initializeApp();
        Log.i("Firebase initialized successfully");
        firebaseInitialized = true;
      } catch (e, stackTrace) {
        Log.w("Failed to initialize Firebase, proceeding without it", error: e, stackTrace: stackTrace);
        // We'll continue without Firebase
      }

      // Setup Service Locator with Firebase status knowledge
      try {
        await di.setupLocator();
        Log.i("Service Locator Initialized (Development Mode).");
      } catch (e, stackTrace) {
        Log.e("Error during service locator initialization", error: e, stackTrace: stackTrace);
        // Continue anyway
      }

      // Initialize localization data
      try {
        await DateUtil.initializeLocalization();
        Log.i("Date Utils Localization Initialized.");
      } catch (e, stackTrace) {
        Log.e("Error initializing date utils", error: e, stackTrace: stackTrace);
        // Continue anyway
      }

      // Setup BLoC Observer for development logging
      Bloc.observer = const SimpleBlocObserver();
      Log.i("SimpleBlocObserver registered.");

      // Configure system UI overlay style (optional, can match prod or differ)
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));

      // Run the application
      runApp(MyApp(firebaseInitialized: firebaseInitialized));
    },
    // --- Zoned Error Handling (Dev) ---
        (error, stackTrace) {
      // Log fatal errors caught outside Flutter framework
      Log.e("Unhandled error caught by runZonedGuarded (Dev)", error: error, stackTrace: stackTrace);
      // In dev, usually just logging is sufficient, no need to send to Crashlytics/Sentry
    },
  );
}

/// The root widget of the application
/// Now includes a flag for Firebase initialization status
class MyApp extends StatelessWidget {
  final bool firebaseInitialized;

  const MyApp({super.key, this.firebaseInitialized = false});

  @override
  Widget build(BuildContext context) {
    // Provide global BLoCs that need to be accessible throughout the app
    return MultiBlocProvider(
      providers: [
        // Core BLoCs that don't depend on Firebase
        BlocProvider<AuthBloc>(create: (context) => di.sl<AuthBloc>(), lazy: false),
        BlocProvider<AppSettingsCubit>(create: (context) => di.sl<AppSettingsCubit>(), lazy: false),
        BlocProvider<FavoritesBloc>(create: (context) => di.sl<FavoritesBloc>(), lazy: true),
        BlocProvider<LineListBloc>(create: (context) => di.sl<LineListBloc>(), lazy: true),
        BlocProvider<DriverDashboardBloc>(create: (context) => di.sl<DriverDashboardBloc>(), lazy: true),
        BlocProvider<TrackingControlBloc>(create: (context) => di.sl<TrackingControlBloc>(), lazy: true),
        BlocProvider<DriverBusBloc>(create: (context) => di.sl<DriverBusBloc>(), lazy: true),
        BlocProvider<DriverProfileBloc>(create: (context) => di.sl<DriverProfileBloc>(), lazy: true),

        // Firebase-dependent BLoCs with conditional registration
        if (firebaseInitialized)
          BlocProvider<NotificationListBloc>(
              create: (context) => di.sl<NotificationListBloc>(),
              lazy: true // Use lazy loading to prevent startup errors
          ),
      ],
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, settingsState) {
          // Handle router creation errors
          GoRouter? router;
          try {
            router = AppRouter.router;
          } catch (e) {
            Log.e("Failed to create router", error: e);
            return _buildErrorApp();
          }

          return MaterialApp.router(
            // --- Router Configuration ---
            routerConfig: router,

            // --- Theme Configuration ---
            themeMode: settingsState.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,

            // --- Localization Configuration ---
            locale: settingsState.locale,
            supportedLocales: Language.supportedLocales,
            localizationsDelegates: const [
              // TODO: Add AppLocalizations.delegate
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // --- App Information ---
            title: '${AppConstants.appName} (Dev)', // Append (Dev) to title
            debugShowCheckedModeBanner: true, // Enable debug banner for dev builds
          );
        },
      ),
    );
  }

  // Helper method to show error screen if router creation fails
  Widget _buildErrorApp() {
    return MaterialApp(
      title: '${AppConstants.appName} (Dev)',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: true,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.error_outline, size: 80, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Router initialization failed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Please check your code and restart the app'),
            ],
          ),
        ),
      ),
    );
  }
}