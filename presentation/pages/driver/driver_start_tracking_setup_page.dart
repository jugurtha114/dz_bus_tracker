/// lib/presentation/pages/driver/driver_start_tracking_setup_page.dart

import 'dart:ui'; // For ImageFilter

// REMOVED: import 'package:dartz/dartz.dart'; // Causes State collision
// Import Either specifically if needed
import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // For context.read
import 'package:go_router/go_router.dart'; // For context.goNamed/pop

// CORRECTED: Import ThemeConstants directly
import '../../../core/constants/theme_constants.dart';
// import '../../../config/themes/app_theme.dart'; // Only if needed for Theme.of(context) access
import '../../../core/constants/assets_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/error/failures.dart'; // Still needed for Either type
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/bus_entity.dart';
import '../../../domain/entities/line_entity.dart';
import '../../../domain/entities/paginated_list_entity.dart'; // For use case result
import '../../../domain/usecases/base_usecase.dart'; // For NoParams
import '../../../domain/usecases/bus/get_driver_buses_usecase.dart';
import '../../../domain/usecases/line/get_lines_usecase.dart';
import '../../blocs/auth/auth_bloc.dart'; // To check if user is driver
import '../../routes/route_names.dart';
import '../../widgets/common/error_display.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/themed_button.dart';

/// Page for drivers to select the Bus and Line before starting a tracking session.
class DriverStartTrackingSetupPage extends StatefulWidget {
  const DriverStartTrackingSetupPage({super.key});

  @override
  // CORRECTED: Ensure return type matches exactly
  State<DriverStartTrackingSetupPage> createState() => _DriverStartTrackingSetupPageState();
}

// CORRECTED: Extends Flutter's State correctly now
class _DriverStartTrackingSetupPageState extends State<DriverStartTrackingSetupPage> {
  // Use cases obtained from Service Locator
  final GetDriverBusesUseCase _getDriverBusesUseCase = sl();
  final GetLinesUseCase _getLinesUseCase = sl();

  // State
  bool _isLoading = true;
  String? _errorMessage;
  List<BusEntity> _driverBuses = [];
  List<LineEntity> _availableLines = [];
  BusEntity? _selectedBus;
  LineEntity? _selectedLine;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  /// Fetches the driver's buses and available lines concurrently.
  Future<void> _fetchInitialData() async {
    // Use mounted check before setState
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authState = context.read<AuthBloc>().state; // context.read is valid here
    if (!(authState is AuthAuthenticated && authState.user.isDriver)) {
      Log.e("DriverStartTrackingSetupPage: User is not authenticated as a driver.");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Access denied: Not logged in as a driver.'; // TODO: Localize
      });
      return;
    }

    final results = await Future.wait([
      _getDriverBusesUseCase(const NoParams()),
      _getLinesUseCase(const GetLinesParams(page: 1, pageSize: 100, isActive: true)),
    ]);

    if (!mounted) return; // Check again after await

    List<BusEntity>? buses;
    List<LineEntity>? lines;
    String? errorMsg;

    (results[0] as Either<Failure, List<BusEntity>>).fold(
          (failure) { Log.e("Failed to fetch driver buses", error: failure); errorMsg = failure.message ?? 'Failed to load your buses.'; },
          (busList) => buses = busList,
    );
    (results[1] as Either<Failure, PaginatedListEntity<LineEntity>>).fold(
          (failure) { Log.e("Failed to fetch available lines", error: failure); errorMsg = errorMsg ?? failure.message ?? 'Failed to load available lines.'; },
          (paginatedList) => lines = paginatedList.items,
    );

    // Use mounted check before final setState
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
        _driverBuses = buses ?? [];
        _availableLines = lines ?? [];
        if (errorMsg != null || _driverBuses.isEmpty || _availableLines.isEmpty) {
          _selectedBus = null; _selectedLine = null;
        }
      });
    }
  }


  /// Proceeds to the dashboard after selection.
  void _confirmSelection() {
    if (_selectedBus != null && _selectedLine != null) {
      Log.i("Bus and Line selected: Bus ${_selectedBus!.matricule}, Line ${_selectedLine!.name}");
      // Navigate back to the dashboard
      context.goNamed(RouteNames.driverDashboard);
    } else {
      // Use mounted check before showing SnackBar if there was an await before this call
      if (mounted) {
        Helpers.showSnackBar(context, message: 'Please select both a bus and a line.', isError: true); // TODO: Localize
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.1), elevation: 0,
        flexibleSpace: ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), child: Container(color: Colors.transparent))),
        leading: BackButton(color: Colors.white, onPressed: () => context.pop()), // Use context.pop
        title: Text(tr('start_new_tracking'), style: textTheme.titleLarge?.copyWith(color: Colors.white)), // TODO: Localize
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset(AssetsConstants.authBackground, fit: BoxFit.cover, color: Colors.black.withOpacity(0.6), colorBlendMode: BlendMode.darken)),
          SafeArea(
            child: Center(
              child: _isLoading
                  ? const LoadingIndicator(message: 'Loading data...') // TODO: Localize
                  : _errorMessage != null
                  ? ErrorDisplay(message: _errorMessage!, onRetry: _fetchInitialData)
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(ThemeConstants.spacingLarge), // Use ThemeConstants
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: _buildGlassyForm(context, tr),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main form within the glassy container.
  Widget _buildGlassyForm(BuildContext context, String Function(String) tr) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusLarge), // Use ThemeConstants
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          padding: const EdgeInsets.all(ThemeConstants.spacingLarge), // Use ThemeConstants
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusLarge), // Use ThemeConstants
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text( tr('select_bus_and_line'), textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white.withOpacity(0.9)), ), // TODO: Localize
              const SizedBox(height: ThemeConstants.spacingLarge), // Use ThemeConstants
              // --- Bus Selector ---
              _buildDropdown<BusEntity>( context: context, label: tr('select_bus'), hint: tr('choose_your_bus'), value: _selectedBus, items: _driverBuses, itemAsString: (bus) => '${bus.matricule} (${bus.brand} ${bus.model})', onChanged: (bus) => setState(() => _selectedBus = bus), icon: Icons.directions_bus_filled_outlined, ), // TODO: Localize labels
              const SizedBox(height: ThemeConstants.spacingMedium), // Use ThemeConstants
              // --- Line Selector ---
              _buildDropdown<LineEntity>( context: context, label: tr('select_line'), hint: tr('choose_the_line'), value: _selectedLine, items: _availableLines, itemAsString: (line) => line.name, onChanged: (line) => setState(() => _selectedLine = line), icon: Icons.route_outlined, ), // TODO: Localize labels
              const SizedBox(height: ThemeConstants.spacingLarge * 1.5), // Use ThemeConstants
              // --- Confirm Button ---
              ThemedButton(
                text: tr('confirm_selection'), // TODO: Localize 'Confirm Selection'
                isLoading: _isLoading, // Disable button while form loads initially
                onPressed: (_selectedBus != null && _selectedLine != null && !_isLoading) ? _confirmSelection : null,
                isFullWidth: true,
                style: ElevatedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: ThemeConstants.spacingMedium + 2), backgroundColor: ThemeConstants.primaryColor.withOpacity(0.9), foregroundColor: Colors.white, textStyle: theme.textTheme.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold), ), // Use ThemeConstants
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Generic Dropdown Builder
  Widget _buildDropdown<T>({ required BuildContext context, required String label, required String hint, required T? value, required List<T> items, required String Function(T item) itemAsString, required ValueChanged<T?> onChanged, required IconData icon, }) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<T>(
      value: value,
      items: items.map((item) { return DropdownMenuItem<T>( value: item, child: Text(itemAsString(item), overflow: TextOverflow.ellipsis), ); }).toList(),
      onChanged: _isLoading ? null : onChanged, // Disable dropdown change while loading initial data
      isExpanded: true,
      decoration: _buildInputDecoration(labelText: label, hintText: items.isEmpty ? 'None available' : hint, prefixIcon: icon), // TODO: Localize 'None available'
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white.withOpacity(0.7),
      dropdownColor: ThemeConstants.neutralDark.withOpacity(0.95), // Use ThemeConstants, make darker
      validator: (v) => v == null ? '$label is required.' : null, // TODO: Localize validation
      hint: Text(items.isEmpty ? 'None available' : hint, style: TextStyle(color: Colors.white.withOpacity(0.5))), // TODO: Localize
    );
  }

  /// Helper to build consistent InputDecoration (copied/adapted)
  InputDecoration _buildInputDecoration({ required String labelText, String? hintText, required IconData prefixIcon,}) { return InputDecoration( labelText: labelText, hintText: hintText, prefixIcon: Icon(prefixIcon, color: Colors.white.withOpacity(0.7)), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder( borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMedium), borderSide: BorderSide.none, ), enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMedium), borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.0), ), focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMedium), borderSide: const BorderSide(color: Colors.white, width: 1.5), ), errorBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMedium), borderSide: BorderSide(color: ThemeConstants.errorColor.withOpacity(0.8), width: 1.0), ), focusedErrorBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMedium), borderSide: const BorderSide(color: ThemeConstants.errorColor, width: 1.5), ), labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)), hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), errorStyle: TextStyle(color: ThemeConstants.errorColor ?? ThemeConstants.errorColor, fontWeight: FontWeight.w500), ); } // Use ThemeConstants
}

/// Helper class for capitalization (move to string_utils.dart if not already done)
class StringUtil { static String capitalizeFirst(String s) { if (s.isEmpty) return ''; return "${s[0].toUpperCase()}${s.substring(1)}"; } }