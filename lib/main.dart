// lib/main.dart (updated)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/api_config.dart';
import 'config/app_config.dart';
import 'config/route_config.dart';
import 'config/theme_config.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/storage_utils.dart';
import 'localization/app_localizations.dart';
import 'localization/localization_provider.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    // Get the current locale from the provider
    final localizationProvider = Provider.of<LocalizationProvider>(context);

    return MaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      locale: localizationProvider.locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: !AppConfig.isProduction,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}