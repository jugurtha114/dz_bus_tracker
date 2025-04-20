/// lib/presentation/pages/driver/driver_bus_management_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/themes/app_theme.dart';
import '../../../core/di/service_locator.dart'; // To get BLoC
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/bus_entity.dart';
import '../../blocs/driver_bus/driver_bus_bloc.dart';
import '../../routes/route_names.dart';
import '../../widgets/bus/driver_bus_list_item.dart'; // Import list item
import '../../widgets/common/empty_list_indicator.dart';
import '../../widgets/common/error_display.dart';
import '../../widgets/common/loading_indicator.dart';


/// Page for drivers to view and manage their associated buses.
class DriverBusManagementPage extends StatelessWidget {
  const DriverBusManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the BLoC scoped to this page instance
    return BlocProvider(
      create: (context) => DriverBusBloc(
        getDriverBusesUseCase: sl(),
        addBusUseCase: sl(),
        updateBusUseCase: sl(),
      )..add(const LoadDriverBuses()), // Initial event
      child: const _DriverBusManagementView(),
    );
  }
}

// CORRECTED: Changed to StatefulWidget to handle ScrollController and mounted checks
class _DriverBusManagementView extends StatefulWidget {
  const _DriverBusManagementView();

  @override
  State<_DriverBusManagementView> createState() => _DriverBusManagementViewState();
}

class _DriverBusManagementViewState extends State<_DriverBusManagementView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Listener not needed here as pagination isn't implemented for this list yet
    // _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // void _onScroll() { ... } // Add pagination logic here if needed later

  /// Refreshes the list by fetching the first page again.
  Future<void> _refreshList(BuildContext context) async {
    Log.d("DriverBusManagementPage: Refreshing list.");
    context.read<DriverBusBloc>().add(const LoadDriverBuses());
    // Use Completer with RefreshIndicator if needed for more control
  }

  @override
  Widget build(BuildContext context) {
    // Placeholder for localization
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('my_buses')), // TODO: Localize
        leading: const BackButton(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Log.i('Add Bus FAB pressed.');
          context.pushNamed(RouteNames.driverAddBus);
        },
        icon: const Icon(Icons.add),
        label: Text(tr('add_bus')), // TODO: Localize
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      // CORRECTED: Use BlocConsumer for cleaner separation of listener and builder
      body: BlocConsumer<DriverBusBloc, DriverBusState>(
        listener: (context, state) {
          // Show snackbar only for errors that occur *after* initial load
          if (state is DriverBusError && state.previousBuses != null) {
            Helpers.showSnackBar(context, message: state.message, isError: true);
          }
          // Could add success snackbars for add/update here if needed
        },
        builder: (context, state) {
          // --- Loading State (only show full screen loader on initial load) ---
          if (state is DriverBusInitial || (state is DriverBusLoading && state.currentBuses == null)) {
            return const Center(child: LoadingIndicator(message: 'Loading Buses...')); // TODO: Localize
          }
          // --- Error State (only show full screen error on initial load failure) ---
          if (state is DriverBusError && state.previousBuses == null) {
            return Center(
              child: ErrorDisplay(
                message: state.message,
                onRetry: () => _refreshList(context),
              ),
            );
          }

          // --- Determine list data and loading status ---
          List<BusEntity> busesToShow = [];
          // Loading more isn't implemented here, but flag is useful if added
          bool isLoadingMore = false; // (state is DriverBusLoading && state.currentBuses != null);
          bool hasErrorOccurred = state is DriverBusError; // Track if last operation failed

          if (state is DriverBusLoaded) {
            busesToShow = state.buses;
          } else if (state is DriverBusLoading && state.currentBuses != null) {
            // Show previous list while loading/submitting action
            busesToShow = state.currentBuses!;
          } else if (state is DriverBusError && state.previousBuses != null) {
            // Show previous list even if last action failed (error shown by listener)
            busesToShow = state.previousBuses!;
          }

          // --- Empty State ---
          // Show empty state only if NOT loading initially and list is empty
          if (busesToShow.isEmpty && !(state is DriverBusLoading && state.currentBuses == null)) {
            return RefreshIndicator(
              onRefresh: () => _refreshList(context),
              child: LayoutBuilder( builder: (context, constraints) => SingleChildScrollView( physics: const AlwaysScrollableScrollPhysics(), child: ConstrainedBox( constraints: BoxConstraints(minHeight: constraints.maxHeight), child: EmptyListIndicator( message: 'You haven\'t added any buses yet. Tap the button below to add one.', iconData: Icons.directions_bus_outlined, onRetry: () => context.pushNamed(RouteNames.driverAddBus), retryButtonText: tr('add_bus'),), ), ), ), ); // TODO: Localize
          }

          // --- Display List ---
          return RefreshIndicator(
            onRefresh: () => _refreshList(context),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 80.0, top: AppTheme.spacingSmall), // Add top padding
              itemCount: busesToShow.length + (isLoadingMore ? 1 : 0), // Add space for loader
              itemBuilder: (context, index) {
                if (index >= busesToShow.length) {
                  // Bottom loading indicator for pagination (if implemented)
                  return const Padding( padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium), child: Center(child: LoadingIndicator(size: 24)), );
                }

                final bus = busesToShow[index];
                return DriverBusListItem(
                  bus: bus,
                  onTap: () {
                    Log.i('Tapped on bus: ${bus.matricule} (ID: ${bus.id})');
                    // Navigate to Edit Bus page, passing the bus ID
                    context.pushNamed(
                      RouteNames.driverEditBus,
                      pathParameters: {'busId': bus.id},
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Helper class for capitalization (move to string_utils.dart if not already done)
class StringUtil { static String capitalizeFirst(String s) { if (s.isEmpty) return ''; return "${s[0].toUpperCase()}${s.substring(1)}"; } }