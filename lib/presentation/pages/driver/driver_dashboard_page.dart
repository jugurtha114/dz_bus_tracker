/// lib/presentation/pages/driver/driver_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart'; // If needed for navigation

import '../../../config/themes/app_theme.dart';
import '../../../core/enums/tracking_status.dart';
import '../../../core/utils/helpers.dart'; // For snackbars
import '../../../core/utils/logger.dart';
import '../../../domain/entities/tracking_session_entity.dart';
// Import BLoCs and States
import '../../blocs/driver_dashboard/driver_dashboard_bloc.dart';
import '../../blocs/tracking_control/tracking_control_bloc.dart';
// Import Widgets
import '../../widgets/common/error_display.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/themed_button.dart';

/// Main dashboard screen for the Driver role.
/// Displays current tracking status and provides controls to manage tracking sessions.
class DriverDashboardPage extends StatelessWidget {
  // Optional: Assume these are passed if a selection process happened before reaching here.
  final String? selectedBusId;
  final String? selectedLineId;

  const DriverDashboardPage({
    super.key,
    this.selectedBusId,
    this.selectedLineId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // Placeholder for localization
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');


    return Scaffold(
      appBar: AppBar(
        title: Text(tr('driver_dashboard')), // TODO: Localize
        // Potentially add driver-specific actions like viewing profile/earnings
        actions: [
           IconButton(
              icon: const Icon(Icons.directions_bus_outlined),
              tooltip: 'Manage My Buses', // TODO: Localize
              onPressed: () {
                 // TODO: Navigate to Driver Bus Management Page
                 // context.pushNamed(RouteNames.driverBusManagement);
                 Log.i('Navigate to Manage Buses page (Not Implemented)');
              },
           ),
           IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              tooltip: 'My Profile', // TODO: Localize
              onPressed: () {
                 // TODO: Navigate to Driver Profile Page
                 // context.pushNamed(RouteNames.driverProfile);
                  Log.i('Navigate to Driver Profile page (Not Implemented)');
              },
           ),
        ],
      ),
      // Listen to TrackingControlBloc for feedback on actions
      body: BlocListener<TrackingControlBloc, TrackingControlState>(
        listener: (context, trackingState) {
          // Show feedback Snackbars based on tracking control actions
          if (trackingState is TrackingControlError) {
            Helpers.showSnackBar(context, message: trackingState.message, isError: true);
          } else if (trackingState is TrackingControlIdle && ModalRoute.of(context)?.isCurrent == true) {
            // Optionally show success after stopping, if needed
            // Helpers.showSnackBar(context, message: 'Tracking Stopped');
          }
          // Add listeners for other states if needed (e.g., success messages)
        },
        // Build UI based on DriverDashboardBloc state (which reflects active session)
        child: BlocBuilder<DriverDashboardBloc, DriverDashboardState>(
          builder: (context, dashboardState) {
            // Determine overall loading state (either dashboard loading or tracking action)
            final bool isControlLoading = context.select((TrackingControlBloc bloc) =>
               bloc.state is TrackingStarting ||
               bloc.state is TrackingStopping ||
               bloc.state is TrackingPausing ||
               bloc.state is TrackingResuming
            );
            final bool isDashboardLoading = dashboardState is DriverDashboardLoading || dashboardState is DriverDashboardInitial;


            if (isDashboardLoading && !isControlLoading) { // Show loading only if not already covered by action loading
              return const Center(child: LoadingIndicator(message: 'Loading Dashboard...')); // TODO: Localize
            }

            if (dashboardState is DriverDashboardError) {
              return Center(
                child: ErrorDisplay(
                  message: dashboardState.message,
                  onRetry: () => context.read<DriverDashboardBloc>().add(const LoadDriverDashboard()),
                ),
              );
            }

            if (dashboardState is DriverDashboardLoaded) {
              final activeSession = dashboardState.activeSession;

              return Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Status Display ---
                    _buildStatusCard(context, activeSession, isControlLoading),
                    const SizedBox(height: AppTheme.spacingLarge),

                    // --- Action Buttons ---
                    if (activeSession == null) // If Idle / No Session
                      _buildStartTrackingSection(context, isControlLoading)
                    else // If Active or Paused
                      _buildActiveSessionControls(context, activeSession, isControlLoading),

                    const Spacer(), // Push controls towards center/bottom if desired
                  ],
                ),
              );
            }

            // Fallback / Should not happen if states are handled
            return const Center(child: Text('Error: Invalid dashboard state.')); // TODO: Localize
          },
        ),
      ),
    );
  }


  /// Builds the card displaying the current tracking status.
  Widget _buildStatusCard(BuildContext context, TrackingSessionEntity? session, bool isControlLoading) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    String statusText;
    String detailText;
    IconData statusIcon;
    Color statusColor;

    final controlState = context.watch<TrackingControlBloc>().state; // Watch for more granular updates

     if (controlState is TrackingStarting) { statusText = 'Starting...'; detailText = 'Initiating session...'; statusIcon = Icons.play_arrow_outlined; statusColor = Colors.orange; }
     else if (controlState is TrackingStopping) { statusText = 'Stopping...'; detailText = 'Ending session...'; statusIcon = Icons.stop_outlined; statusColor = Colors.orange; }
     else if (controlState is TrackingPausing) { statusText = 'Pausing...'; detailText = 'Pausing session...'; statusIcon = Icons.pause_outlined; statusColor = Colors.orange; }
     else if (controlState is TrackingResuming) { statusText = 'Resuming...'; detailText = 'Resuming session...'; statusIcon = Icons.play_arrow_outlined; statusColor = Colors.orange; }
    else if (session?.status == TrackingStatus.active) { statusText = 'Tracking Active'; detailText = 'Line: ${session!.lineDetails.name}\nBus: ${session.busDetails.matricule}'; statusIcon = Icons.check_circle; statusColor = AppTheme.successColor; }
    else if (session?.status == TrackingStatus.paused) { statusText = 'Tracking Paused'; detailText = 'Line: ${session!.lineDetails.name}\nBus: ${session.busDetails.matricule}'; statusIcon = Icons.pause_circle_filled; statusColor = AppTheme.warningColor; }
    else { statusText = 'Not Tracking'; detailText = 'Select a Bus and Line to start tracking.'; statusIcon = Icons.not_listed_location; statusColor = AppTheme.neutralMedium; }
     // TODO: Localize status/detail texts

    return Card(
      elevation: AppTheme.elevationSmall,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Row(
          children: [
            Icon(statusIcon, size: 48, color: statusColor),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(statusText, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: statusColor)),
                  const SizedBox(height: AppTheme.spacingXSmall),
                  Text(detailText, style: textTheme.bodyMedium?.copyWith(color: AppTheme.neutralMedium)),
                ],
              ),
            ),
             // Show spinner if loading an action
            if (isControlLoading) const SizedBox(width: AppTheme.spacingSmall),
            if (isControlLoading) const LoadingIndicator(size: 24),
          ],
        ),
      ),
    );
  }

  /// Builds the section shown when the driver is not tracking.
  Widget _buildStartTrackingSection(BuildContext context, bool isLoading) {
     final textTheme = Theme.of(context).textTheme;
      // Placeholder for localization
     String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');

     // Only enable Start button if bus/line are selected (passed as args)
     final canStart = selectedBusId != null && selectedLineId != null;

    return Column(
       children: [
           if (!canStart)
              Padding(
                 padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
                 child: Text(
                    'Please select your Bus and Line first from the management screen.', // TODO: Localize
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(color: AppTheme.neutralMedium),
                 ),
              ),
          ThemedButton(
            text: tr('start_tracking'), // TODO: Localize
            icon: Icons.play_arrow_rounded,
            isLoading: isLoading,
            // Disable if no bus/line selected OR if currently loading
            onPressed: (!canStart || isLoading) ? null : () {
               context.read<TrackingControlBloc>().add(StartTrackingRequested(
                  busId: selectedBusId!,
                  lineId: selectedLineId!,
                  // scheduleId: null, // Pass if available
               ));
            },
            isFullWidth: true,
             style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium + 2),
                 backgroundColor: AppTheme.successColor, // Use success color for start
                 foregroundColor: Colors.white,
                 textStyle: textTheme.labelLarge?.copyWith(fontSize: 16)
             ),
          ),
       ],
    );
  }

   /// Builds the control buttons shown when a session is active or paused.
  Widget _buildActiveSessionControls(BuildContext context, TrackingSessionEntity session, bool isLoading) {
     final textTheme = Theme.of(context).textTheme;
      // Placeholder for localization
     String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');


     bool isActive = session.status == TrackingStatus.active;
     bool isPaused = session.status == TrackingStatus.paused;

    return Column(
       children: [
           // Pause/Resume Button
          if (isActive)
             ThemedButton(
                text: tr('pause_tracking'), // TODO: Localize
                icon: Icons.pause_rounded,
                isLoading: isLoading, // Disable if any action is loading
                onPressed: isLoading ? null : () {
                   context.read<TrackingControlBloc>().add(PauseTrackingRequested(sessionId: session.id));
                },
                 isFullWidth: true,
                  style: ElevatedButton.styleFrom(
                   padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
                   backgroundColor: AppTheme.warningColor, // Warning color for pause
                   foregroundColor: Colors.black87,
                    textStyle: textTheme.labelLarge?.copyWith(fontSize: 16)
                ),
             )
           else if (isPaused)
             ThemedButton(
                text: tr('resume_tracking'), // TODO: Localize
                icon: Icons.play_arrow_rounded,
                isLoading: isLoading,
                 onPressed: isLoading ? null : () {
                    context.read<TrackingControlBloc>().add(ResumeTrackingRequested(sessionId: session.id));
                 },
                 isFullWidth: true,
                  style: ElevatedButton.styleFrom(
                   padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
                   backgroundColor: AppTheme.successColor, // Success color for resume
                   foregroundColor: Colors.white,
                    textStyle: textTheme.labelLarge?.copyWith(fontSize: 16)
                ),
             ),
           const SizedBox(height: AppTheme.spacingMedium),
           // Stop Button (Always shown if active or paused)
           ThemedButton(
             text: tr('stop_tracking'), // TODO: Localize
             icon: Icons.stop_rounded,
             isLoading: isLoading,
              onPressed: isLoading ? null : () {
                 context.read<TrackingControlBloc>().add(StopTrackingRequested(sessionId: session.id));
              },
              isFullWidth: true,
              style: ElevatedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
                 backgroundColor: AppTheme.errorColor, // Error color for stop
                 foregroundColor: Colors.white,
                  textStyle: textTheme.labelLarge?.copyWith(fontSize: 16)
             ),
           ),
       ],
    );
  }
}


/// Helper class for capitalization (move to string_utils.dart if not already done)
class StringUtil {
   static String capitalizeFirst(String s) {
    if (s.isEmpty) return '';
    return "${s[0].toUpperCase()}${s.substring(1)}";
  }
}
