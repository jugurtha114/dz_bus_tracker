// lib/main.dart (updated)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import 'config/api_config.dart';
import 'config/app_config.dart';
import 'config/route_config.dart';
import 'config/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/storage_utils.dart';
import 'localization/app_localizations.dart';
import 'localization/localization_provider.dart';
import 'services/navigation_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/bus_provider.dart';
import 'providers/driver_provider.dart';
import 'providers/line_provider.dart';
import 'providers/location_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/passenger_provider.dart';
import 'providers/stop_provider.dart';
import 'providers/tracking_provider.dart';
import 'providers/theme_provider.dart';

/// Firebase background message handler
/// This must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');
  print('Message notification: ${message.notification?.title} - ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (check if already initialized)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase already initialized, continue
    if (e.toString().contains('duplicate-app')) {
      print('Firebase already initialized, continuing...');
    } else {
      print('Firebase initialization error: $e');
      rethrow;
    }
  }
  
  // Set Firebase background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize shared preferences
  await SharedPreferences.getInstance();

  // Run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme provider
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // Localization provider
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),

        // Auth provider (needed by other providers)
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Feature providers
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => BusProvider()),
        ChangeNotifierProvider(create: (_) => DriverProvider()),
        ChangeNotifierProvider(create: (_) => LineProvider()),
        ChangeNotifierProvider(create: (_) => StopProvider()),
        ChangeNotifierProvider(create: (_) => TrackingProvider()),
        ChangeNotifierProvider(create: (_) => PassengerProvider()),
      ],
      child: const AppWithLocalization(),
    );
  }
}

class AppWithLocalization extends StatefulWidget {
  const AppWithLocalization({Key? key}) : super(key: key);

  @override
  _AppWithLocalizationState createState() => _AppWithLocalizationState();
}

class _AppWithLocalizationState extends State<AppWithLocalization> {
  @override
  void initState() {
    super.initState();

    // Initialize providers after build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<LocalizationProvider>(context, listen: false).initialize();
      await Provider.of<AuthProvider>(context, listen: false).checkAuth();
      await Provider.of<NotificationProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current locale and theme from providers
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AnimatedTheme(
      duration: const Duration(milliseconds: 300),
      data: themeProvider.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _getThemeMode(themeProvider.themeMode),
      locale: localizationProvider.locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: !AppConfig.isProduction,
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
  
  ThemeMode _getThemeMode(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}