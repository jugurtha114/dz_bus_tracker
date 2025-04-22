/// lib/presentation/pages/passenger/stop_details_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // For navigation

import '../../../config/themes/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/eta_entity.dart';
import '../../blocs/stop_details/stop_details_bloc.dart'; // Import the BLoC
import '../../routes/route_names.dart';
import '../../widgets/common/error_display.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/eta/eta_list_item.dart'; // Import ETA list item
import '../../widgets/line/line_list_item.dart'; // Import Line list item


/// Page displaying detailed information about a specific bus stop.
class StopDetailsPage extends StatelessWidget {
  /// The unique identifier of the stop to display. Passed via route parameter.
  final String stopId;
  /// Optional: Filter ETAs/Lines for a specific line ID at this stop.
  final String? filterByLineId;

  const StopDetailsPage({
    super.key,
    required this.stopId,
    this.filterByLineId,
  });

  @override
  Widget build(BuildContext context) {
    // Provide the BLoC scoped to this page instance
    return BlocProvider(
      create: (context) => StopDetailsBloc(
        getStopDetailsUseCase: sl(),
        getLinesForStopUseCase: sl(),
        getEtasForStopUseCase: sl(),
      )..add(LoadStopDetails(stopId: stopId, filterByLineId: filterByLineId)), // Initial event
      child: _StopDetailsView(stopId: stopId, filterByLineId: filterByLineId),
    );
  }
}

/// The main view widget for the Stop Details page.
class _StopDetailsView extends StatefulWidget {
  final String stopId;
  final String? filterByLineId;

  const _StopDetailsView({required this.stopId, this.filterByLineId});

  @override
  State<_StopDetailsView> createState() => __StopDetailsViewState();
}

class __StopDetailsViewState extends State<_StopDetailsView> {
    Timer? _etaRefreshTimer;

   @override
   void initState() {
      super.initState();
      _startEtaRefreshTimer();
   }

    @override
    void dispose() {
      _stopEtaRefreshTimer();
      super.dispose();
    }

   /// Starts a timer to periodically refresh ETAs.
   void _startEtaRefreshTimer() {
      _stopEtaRefreshTimer(); // Cancel existing timer
      Log.d('StopDetailsPage: Starting ETA refresh timer.');
       // Refresh frequently, e.g., every 30 seconds
      _etaRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
         if (mounted) { // Check if widget is still visible
            context.read<StopDetailsBloc>().add(RefreshStopEtas(
               stopId: widget.stopId,
               filterByLineId: widget.filterByLineId,
            ));
         } else {
            _stopEtaRefreshTimer(); // Stop if widget disposed
         }
      });
   }

   /// Stops the ETA refresh timer.
   void _stopEtaRefreshTimer() {
      if (_etaRefreshTimer?.isActive ?? false) {
          Log.d('StopDetailsPage: Stopping ETA refresh timer.');
         _etaRefreshTimer?.cancel();
      }
       _etaRefreshTimer = null;
   }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: BlocBuilder<StopDetailsBloc, StopDetailsState>(
        builder: (context, state) {
          if (state is StopDetailsLoading || state is StopDetailsInitial) {
            return const Center(child: LoadingIndicator());
          }

          if (state is StopDetailsError) {
            return Center(
              child: ErrorDisplay(
                message: state.message,
                onRetry: () => context.read<StopDetailsBloc>().add(
                    LoadStopDetails(stopId: widget.stopId, filterByLineId: widget.filterByLineId)),
              ),
            );
          }

          if (state is StopDetailsLoaded) {
            final stop = state.stopDetails;
            final lines = state.servingLines;
            final etas = state.etas;

            // Sort ETAs by arrival time for display
            final sortedEtas = List<EtaEntity>.from(etas)
                ..sort((a, b) => a.estimatedArrivalTime.compareTo(b.estimatedArrivalTime));

            return CustomScrollView(
              slivers: [
                // AppBar showing Stop Name
                SliverAppBar(
                  title: Text(stop.name),
                  pinned: true,
                  floating: true,
                  // Add background/styling as desired
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  elevation: 1.0,
                  // Optional: Add image in flexible space
                  // expandedHeight: stop.imageUrl != null ? 200 : kToolbarHeight,
                  // flexibleSpace: stop.imageUrl != null
                  //     ? FlexibleSpaceBar(
                  //         background: Image.network(stop.imageUrl!, fit: BoxFit.cover),
                  //       )
                  //     : null,
                ),

                // Stop Details Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (stop.code != null && stop.code!.isNotEmpty)
                          Text('Stop Code: ${stop.code}', style: textTheme.bodyLarge), // TODO: Localize
                        if (stop.address != null && stop.address!.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacingSmall),
                           Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Icon(Icons.location_on_outlined, size: 18, color: AppTheme.neutralMedium),
                               const SizedBox(width: AppTheme.spacingSmall),
                               Expanded(child: Text(stop.address!, style: textTheme.bodyMedium?.copyWith(color: AppTheme.neutralMedium))),
                             ],
                           ),
                        ],
                        // Add other details like description if needed
                      ],
                    ),
                  ),
                ),

                // Upcoming Arrivals Header
                 SliverPersistentHeader(
                   pinned: true,
                   delegate: _SectionHeaderDelegate('Upcoming Arrivals'), // TODO: Localize
                 ),

                 // ETAs List
                 if (sortedEtas.isEmpty)
                    const SliverToBoxAdapter(
                       child: Padding(
                          padding: EdgeInsets.symmetric(vertical: AppTheme.spacingLarge, horizontal: AppTheme.spacingMedium),
                          child: Center(child: Text('No upcoming arrivals estimated at this time.')), // TODO: Localize
                       ),
                    )
                 else
                   SliverList(
                      delegate: SliverChildBuilderDelegate(
                         (context, index) {
                            final eta = sortedEtas[index];
                            return EtaListItem(
                               eta: eta,
                               onTap: () {
                                  Log.i('Tapped ETA for Line ${eta.lineName ?? eta.lineId}, Bus ${eta.busMatricule ?? eta.busId}');
                                   // Optionally navigate to LineDetails or BusDetails?
                                    context.pushNamed(
                                        RouteNames.lineDetails,
                                        pathParameters: {'lineId': eta.lineId},
                                     );
                               },
                            );
                         },
                         childCount: sortedEtas.length,
                      ),
                   ),

                 // Lines Header
                  SliverPersistentHeader(
                   pinned: true,
                   delegate: _SectionHeaderDelegate('Lines Serving This Stop'), // TODO: Localize
                 ),

                 // Lines List
                 if (lines.isEmpty)
                    const SliverToBoxAdapter(
                       child: Padding(
                          padding: EdgeInsets.symmetric(vertical: AppTheme.spacingLarge, horizontal: AppTheme.spacingMedium),
                          child: Center(child: Text('No lines information available for this stop.')), // TODO: Localize
                       ),
                    )
                  else
                     SliverList(
                      delegate: SliverChildBuilderDelegate(
                         (context, index) {
                            final line = lines[index];
                            return LineListItem(
                               line: line,
                               onTap: () {
                                   Log.i('Tapped Line ${line.name} from Stop Details.');
                                   context.pushNamed(
                                      RouteNames.lineDetails,
                                      pathParameters: {'lineId': line.id},
                                   );
                               },
                            );
                         },
                         childCount: lines.length,
                      ),
                   ),

                 // Add some bottom padding
                 const SliverPadding(padding: EdgeInsets.only(bottom: AppTheme.spacingLarge)),
              ],
            );
          }
          // Fallback for any unhandled state
          return const Center(child: Text('Error: Invalid State.')); // TODO: Localize
        },
      ),
    );
  }
}

/// Delegate for creating sticky section headers (copied from LineDetailsPage - centralize later).
class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final double height;
  _SectionHeaderDelegate(this.title, {this.height = 48.0});
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context); final ColorTween backgroundTween = ColorTween( begin: theme.scaffoldBackgroundColor, end: theme.colorScheme.surfaceVariant, ); final double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    return Container( height: height, color: backgroundTween.lerp(progress), padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium), alignment: Alignment.centerLeft, child: Text( title, style: theme.textTheme.titleMedium?.copyWith( fontWeight: FontWeight.bold, color: theme.colorScheme.primary, ), ), );
  }
  @override double get maxExtent => height; @override double get minExtent => height; @override bool shouldRebuild(_SectionHeaderDelegate oldDelegate) => title != oldDelegate.title || height != oldDelegate.height;
}
