// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_theme.dart';

enum AppThemeMode { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  AppThemeMode _themeMode = AppThemeMode.system;
  SharedPreferences? _prefs;
  bool _isAnimating = false;

  AppThemeMode get themeMode => _themeMode;
  bool get isAnimating => _isAnimating;
  
  ThemeData get lightTheme => AppTheme.lightTheme;
  ThemeData get darkTheme => AppTheme.darkTheme;
  
  bool get isDarkMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
  }

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    _prefs = await SharedPreferences.getInstance();
    final savedThemeIndex = _prefs?.getInt(_themeKey) ?? 0;
    _themeMode = AppThemeMode.values[savedThemeIndex];
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    
    _isAnimating = true;
    notifyListeners();
    
    // Add a small delay for animation
    await Future.delayed(const Duration(milliseconds: 100));
    
    _themeMode = themeMode;
    await _prefs?.setInt(_themeKey, themeMode.index);
    
    // Complete animation
    await Future.delayed(const Duration(milliseconds: 200));
    _isAnimating = false;
    notifyListeners();
  }

  void toggleTheme() {
    switch (_themeMode) {
      case AppThemeMode.light:
        setThemeMode(AppThemeMode.dark);
        break;
      case AppThemeMode.dark:
        setThemeMode(AppThemeMode.system);
        break;
      case AppThemeMode.system:
        setThemeMode(AppThemeMode.light);
        break;
    }
  }

  String get currentThemeName {
    switch (_themeMode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  IconData get currentThemeIcon {
    switch (_themeMode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}