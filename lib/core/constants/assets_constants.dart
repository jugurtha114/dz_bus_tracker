/// lib/core/constants/assets_constants.dart

/// Defines constant strings for asset paths used throughout the application.
/// Helps prevent typos and centralizes asset management.
class AssetsConstants {
  // Private constructor to prevent instantiation
  AssetsConstants._();

  // --- Base Paths ---
  // Define base paths for different asset types.
  static const String _basePathImages = 'assets/images';
  static const String _basePathIcons = 'assets/icons';
  static const String _basePathFonts = 'assets/fonts';
  static const String _basePathMapStyles = 'assets/map_styles';
  static const String _basePathBackgrounds = '$_basePathImages/backgrounds'; // Added for backgrounds
  static const String _basePathTranslations = 'assets/i18n'; // For manual JSON loading if used

  // --- Images ---
  // App Logo
  static const String logo = '$_basePathImages/logo.png'; // App logo
  static const String logoDark = '$_basePathImages/logo_dark.png'; // Optional: Logo variant for dark theme

  // Backgrounds
  static const String authBackground = '$_basePathBackgrounds/auth_bg.jpg'; // Background for Login/Register
  static const String mainBackground = '$_basePathBackgrounds/main_bg.png'; // Optional main app background

  // Onboarding Screens
  static const String onboarding1 = '$_basePathImages/onboarding/screen_1.png';
  static const String onboarding2 = '$_basePathImages/onboarding/screen_2.png';
  static const String onboarding3 = '$_basePathImages/onboarding/screen_3.png';

  // Placeholders / Illustrations
  static const String emptyStateIllustration = '$_basePathImages/illustrations/empty_state.png';
  static const String errorIllustration = '$_basePathImages/illustrations/error.png';
  static const String noConnectionIllustration = '$_basePathImages/illustrations/no_connection.png';

  // Map Markers (Ensure these files exist in your assets/images folder)
  static const String mapPinBus = '$_basePathImages/map/bus_marker.png';
  static const String mapPinStop = '$_basePathImages/map/stop_marker.png';
  static const String mapPinUser = '$_basePathImages/map/user_location_marker.png';

  // --- Icons ---
  // Commonly used icons (assuming SVG or PNG format)
  static const String iconBus = '$_basePathIcons/bus.svg';
  static const String iconMap = '$_basePathIcons/map.svg';
  static const String iconList = '$_basePathIcons/list.svg';
  static const String iconFavorite = '$_basePathIcons/favorite.svg';
  static const String iconFavoriteFilled = '$_basePathIcons/favorite_filled.svg';
  static const String iconSettings = '$_basePathIcons/settings.svg';
  static const String iconProfile = '$_basePathIcons/profile.svg';
  static const String iconNotification = '$_basePathIcons/notification.svg';
  static const String iconDriver = '$_basePathIcons/driver.svg'; // Specific icon for driver role
  static const String iconPassenger = '$_basePathIcons/passenger.svg'; // Specific icon for passenger role
  static const String iconArrowRight = '$_basePathIcons/arrow_right.svg';
  static const String iconClock = '$_basePathIcons/clock.svg';
  static const String iconLocationPin = '$_basePathIcons/location_pin.svg';

  // --- Fonts ---
  // Define font family names (matching the declaration in pubspec.yaml)
  static const String fontPoppins = 'Poppins'; // Assumed font family name

  // --- Map Styles ---
  // JSON files for Google Maps custom styling
  static const String mapStyleLight = '$_basePathMapStyles/light_map_style.json';
  static const String mapStyleDark = '$_basePathMapStyles/dark_map_style.json';

  // --- Translations (if using manual JSON loading) ---
  static const String translationEn = '$_basePathTranslations/en.json';
  static const String translationFr = '$_basePathTranslations/fr.json';
  static const String translationAr = '$_basePathTranslations/ar.json';

}

// --- REMINDER ---
// Don't forget to declare all your asset folders (assets/images/, assets/icons/, etc.)
// including the new assets/images/backgrounds/ folder in your pubspec.yaml file.
