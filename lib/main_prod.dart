/// lib/main_prod.dart

import 'dart:async'; // For runZonedGuarded

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For system UI overlay style
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// --- Error Reporting (Choose one or none) ---
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:sentry_flutter/sentry_flutter.dart'; // If using Sentry

import 'config/themes/app_theme.dart';
import 'core/constants/app_constants.dart'; // For App Name
import 'core/di/service_locator.dart' as di; // Service locator setup
import 'core/enums/language.dart';
import 'core/utils/date_utils.dart'; // For localization init
import 'core/utils/logger.dart'; // Logger setup handles prod level automatically
// Import global BLoCs/Cubits (ensure they exist and are registered in DI)
import 'presentation/blocs/app_settings/app_settings_cubit.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/driver_bus/driver_bus_bloc.dart';
import 'presentation/blocs/driver_dashboard/driver_dashboard_bloc.dart';
import 'presentation/blocs/driver_profile/driver_profile_bloc.dart';
import 'presentation/blocs/favorites/favorites_bloc.dart';
import 'presentation/blocs/line_details/line_details_bloc.dart'; // Needed if globally provided
import 'presentation/blocs/line_list/line_list_bloc.dart'; // Needed if globally provided
import 'presentation/blocs/notification_list/notification_list_bloc.dart';
import 'presentation/blocs/tracking_control/tracking_control_bloc.dart';
// Import Router
import 'presentation/routes/app_router.dart';

/// The main entry point for the PRODUCTION build of the application.
Future<void> main() async {
  // Use runZonedGuarded to catch errors that occur outside Flutter framework handlers
  await runZonedGuarded<Future<void>>(
    () async {
      // Ensure Flutter bindings are initialized before using plugins
      WidgetsFlutterBinding.ensureInitialized();

      // --- Production Specific Initializations ---

      // TODO: Initialize Firebase for Production (if used)
      // Use your production Firebase options file
      // await Firebase.initializeApp(
      //   // options: DefaultFirebaseOptions.currentPlatform, // Ensure correct options loaded
      // );

      // TODO: Configure Production Error Reporting (Choose one or adapt)
      // Option A: Firebase Crashlytics
      // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      // Option B: Sentry
      // await SentryFlutter.init(
      //   (options) {
      //     options.dsn = 'YOUR_PRODUCTION_SENTRY_DSN';
      //     options.tracesSampleRate = 0.2; // Adjust sample rate for performance
      //     options.environment = 'production';
      //   },
      //   appRunner: () => runApp(const MyApp()), // Wrap runApp for Sentry integration
      // );
      // If not using Sentry's appRunner, proceed normally after FlutterError.onError setup

      Log.i("Running PRODUCTION main entry point.");

      // Setup Service Locator for dependency injection
      await di.setupLocator(); // DI setup should handle environment internally if needed
      Log.i("Service Locator Initialized (Production Mode).");

      // Initialize localization data for date formatting and timeago
      await DateUtil.initializeLocalization();
      Log.i("Date Utils Localization Initialized.");

      // Optional: Configure preferred screen orientation
      // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

      // Configure system UI overlay style (status bar, nav bar)
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Adjust based on default theme (light)
        statusBarBrightness: Brightness.light, // For iOS
        systemNavigationBarColor: Colors.white, // Adjust as needed
        systemNavigationBarIconBrightness: Brightness.dark,
      ));

      // Run the application (only call runApp once)
      // If not using Sentry's appRunner:
      runApp(const MyApp());

    },
    // --- Zoned Error Handling ---
    (error, stackTrace) {
      // This catches errors outside Flutter's standard handling
      // Log.fatal("Unhandled error caught by runZonedGuarded", error: error, stackTrace: stackTrace);
      // TODO: Report error to your chosen production service
      // Example: Firebase Crashlytics
      // FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
      // Example: Sentry
      // Sentry.captureException(error, stackTrace: stackTrace);
    },
  );
}


/// The root widget of the application (Identical to main.dart).
/// Sets up global BLoC providers and the MaterialApp with GoRouter.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide global BLoCs that need to be accessible throughout the app
    return MultiBlocProvider(
      providers: [
        // --- Core BLoCs ---
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>(),
          lazy: false,
        ),
        BlocProvider<AppSettingsCubit>(
          create: (context) => di.sl<AppSettingsCubit>(),
          lazy: false,
        ),
         BlocProvider<NotificationListBloc>(
          create: (context) => di.sl<NotificationListBloc>(),
           lazy: false,
        ),
        // --- Feature BLoCs (Provide globally if frequently accessed or state needs preserving) ---
        BlocProvider<FavoritesBloc>(
          create: (context) => di.sl<FavoritesBloc>(),
          lazy: true, // Load only when favorites screen is accessed?
        ),
         BlocProvider<LineListBloc>( // For passenger lines list tab
          create: (context) => di.sl<LineListBloc>(),
          lazy: true,
        ),
        // Driver specific BLoCs
         BlocProvider<DriverDashboardBloc>(
          create: (context) => di.sl<DriverDashboardBloc>(),
          lazy: false, // Load dashboard state relatively early for driver
        ),
         BlocProvider<TrackingControlBloc>(
          create: (context) => di.sl<TrackingControlBloc>(),
           lazy: false, // Init check for active session early
        ),
         BlocProvider<DriverBusBloc>(
          create: (context) => di.sl<DriverBusBloc>(),
           lazy: true, // Load bus list only when needed
        ),
         BlocProvider<DriverProfileBloc>(
          create: (context) => di.sl<DriverProfileBloc>(),
           lazy: true, // Load profile only when needed
        ),
        // Note: BLoCs for specific pages (LineDetails, StopDetails, ChangePassword, Register, Feedback)
        // are often provided locally on those pages using BlocProvider, not globally here.
      ],
      // Use BlocBuilder to react to AppSettings changes (Theme, Locale)
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, settingsState) {
          return MaterialApp.router(
            // --- Router Configuration ---
            routerConfig: AppRouter.router, // Use the configured GoRouter

            // --- Theme Configuration ---
            themeMode: settingsState.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,

            // --- Localization Configuration ---
            locale: settingsState.locale,
            supportedLocales: Language.supportedLocales, // From Language enum
            localizationsDelegates: const [
              // TODO: Add AppLocalizations.delegate (or your chosen package delegate)
              // AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // --- App Information ---
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false, // Ensure this is false for prod builds
          );
        },
      ),
    );
  }
}

// Helper class for capitalization (move to string_utils.dart)
class StringUtil {
   static String capitalizeFirst(String s) { if (s.isEmpty) return ''; return "${s[0].toUpperCase()}${s.substring(1)}"; }
}
