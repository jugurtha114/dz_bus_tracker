// lib/widgets/widgets.dart

/// Widget library for DZ Bus Tracker
/// 
/// This is the main entry point for all UI components in the app.
/// It provides a clean, organized way to import widgets following
/// Material You design principles.
/// 
/// Usage:
/// ```dart
/// import 'package:dz_bus_tracker/widgets/widgets.dart';
/// 
/// // Use any widget from the library
/// AppButton(text: 'Click me', onPressed: () {});
/// AppCard(child: Text('Content'));
/// ```

library widgets;

// Foundation widgets - core UI components
export 'foundation/foundation.dart';

// Layout widgets - page structure and responsive design
export 'layout/layout.dart';

// Common widgets - reusable components
export 'common/common.dart';

// Feature widgets - business logic specific components
export 'features/features.dart';