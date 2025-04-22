/// lib/main.dart

import 'dart:async';

import 'package:dz_bus_tracker/presentation/blocs/notification_list/mock_notification_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dz_bus_tracker/presentation/blocs/driver_bus/driver_bus_bloc.dart';
import 'package:dz_bus_tracker/presentation/blocs/driver_profile/driver_profile_bloc.dart';

import 'package:dz_bus_tracker/presentation/blocs/notification_list/notification_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For system UI overlay style
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'config/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/di/service_locator.dart' as di; // Service locator setup
import 'core/enums/language.dart';
import 'core/utils/date_utils.dart'; // For localization init
import 'core/utils/logger.dart'; // For logging setup
// Import global BLoCs/Cubits
import 'presentation/blocs/app_settings/app_settings_cubit.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/driver_dashboard/driver_dashboard_bloc.dart';
import 'presentation/blocs/favorites/favorites_bloc.dart';
import 'presentation/blocs/tracking_control/tracking_control_bloc.dart';
// Import Router
import 'presentation/routes/app_router.dart';

/// The main entry point for the DZ Bus Tracker application.
Future<void> main() async {
  // Wrap everything in runZonedGuarded for better error handling
  await runZonedGuarded<Future<void>>(
        () async {
      // Ensure Flutter bindings are initialized before using plugins
      WidgetsFlutterBinding.ensureInitialized();

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

      // Setup Service Locator for dependency injection
      try {
        await di.setupLocator();
        Log.i("Service Locator Initialized.");
      } catch (e, stackTrace) {
        Log.e("Error during service locator initialization", error: e, stackTrace: stackTrace);
        // Continue anyway - the service locator handles errors internally
      }

      // Initialize localization data for date formatting and timeago
      try {
        await DateUtil.initializeLocalization();
        Log.i("Date Utils Localization Initialized.");
      } catch (e, stackTrace) {
        Log.e("Error initializing date utils", error: e, stackTrace: stackTrace);
        // Continue anyway
      }

      // Optional: Customize system UI overlay style (status bar, navigation bar)
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Make status bar transparent
        statusBarIconBrightness: Brightness.dark, // Icons for light status bar
        statusBarBrightness: Brightness.light, // For iOS
        systemNavigationBarColor: Colors.white, // Match bottom nav bar maybe?
        systemNavigationBarIconBrightness: Brightness.dark,
      ));

      // Run the application
      runApp(MyApp(firebaseInitialized: firebaseInitialized));
    },
        (error, stackTrace) {
      // Log uncaught errors
      Log.e("Uncaught error in main", error: error, stackTrace: stackTrace);
    },
  );
}

/// The root widget of the application.
/// Now includes a flag for Firebase initialization status.
/// For main.dart, also update the MyApp class with the same nullable parameter:

class MyApp extends StatelessWidget {
  final bool? firebaseInitialized;


  const MyApp({super.key, this.firebaseInitialized});

  @override
  Widget build(BuildContext context) {
    // Provide global BLoCs that need to be accessible throughout the app
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>(),
          lazy: false, // Ensure AuthBloc is created immediately for redirects
        ),
        BlocProvider<AppSettingsCubit>(
          create: (context) => di.sl<AppSettingsCubit>(),
          lazy: false, // Load settings immediately
        ),
        BlocProvider<FavoritesBloc>(
          create: (context) => di.sl<FavoritesBloc>(),
          lazy: true, // Load on demand
        ),
        // Driver specific BLoCs - provide them here if the driver role is common
        BlocProvider<DriverDashboardBloc>(
          create: (context) => di.sl<DriverDashboardBloc>(),
          lazy: true, // Lazy load to avoid startup errors
        ),
        BlocProvider<TrackingControlBloc>(
          create: (context) => di.sl<TrackingControlBloc>(),
          lazy: true, // Lazy load to avoid startup errors
        ),
        BlocProvider<DriverBusBloc>(
          create: (context) => di.sl<DriverBusBloc>(),
          lazy: true,
        ),
        BlocProvider<DriverProfileBloc>(
          create: (context) => di.sl<DriverProfileBloc>(),
          lazy: true,
        ),

        // Conditionally provide NotificationListBloc based on Firebase availability
        if (firebaseInitialized == true)
          BlocProvider<NotificationListBloc>(
            create: (context) {
              try {
                return di.sl<NotificationListBloc>();
              } catch (e) {
                Log.w("Failed to create NotificationListBloc, using mock implementation", error: e);
                return MockNotificationListBloc(storageService: di.sl());
              }
            },
            lazy: true, // Use lazy loading to avoid startup errors
          ),
      ],
      // Use BlocBuilder to react to AppSettings changes (Theme, Locale)
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
            routerConfig: router, // Use the configured GoRouter

            // --- Theme Configuration ---
            themeMode: settingsState.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,

            // --- Localization Configuration ---
            locale: settingsState.locale,
            supportedLocales: Language.supportedLocales, // From Language enum
            localizationsDelegates: const [
              // TODO: Add AppLocalizations.delegate (or your chosen localization package delegate)
              // AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // --- App Information ---
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false, // Disable debug banner
          );
        },
      ),
    );
  }

  // Helper method to show error screen if router creation fails
  Widget _buildErrorApp() {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
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