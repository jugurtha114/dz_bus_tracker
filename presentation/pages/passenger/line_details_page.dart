/// lib/presentation/pages/passenger/line_details_page.dart

import 'dart:ui'; // For ImageFilter

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/themes/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/location_entity.dart';
import '../../blocs/favorites/favorites_bloc.dart'; // Import Favorites BLoC
import '../../blocs/line_details/line_details_bloc.dart';
import '../../routes/route_names.dart';
import '../../widgets/common/error_display.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/line/line_detail_header.dart'; // Import widget
import '../../widgets/line/line_stop_list.dart'; // Import widget
import '../../widgets/map/bus_map_view.dart'; // Import REAL map widget

/// Page displaying detailed information about a specific bus line.
class LineDetailsPage extends StatelessWidget {
  /// The unique identifier of the line to display. Passed via route parameter.
  final String lineId;

  const LineDetailsPage({super.key, required this.lineId});

  @override
  Widget build(BuildContext context) {
    // Provide the BLoC scoped to this page instance
    return BlocProvider(
      create: (context) => LineDetailsBloc(
        getLineDetailsUseCase: sl(),
        getStopsForLineUseCase: sl(),
        getBusesForLineUseCase: sl(),
        getEtasForLineUseCase: sl(),
        lineRepository: sl(), // Inject repo for favorite check
      )..add(LoadLineDetails(lineId: lineId)), // Initial event
      // FavoritesBloc needs to be provided higher up the tree (e.g., above PassengerHomePage)
      // Or provided here as well if not global:
      // BlocProvider( create: (_) => FavoritesBloc(...), child: _LineDetailsView(...))
      child: _LineDetailsView(lineId: lineId), // Pass lineId to the view
    );
  }
}

/// The main view widget for the Line Details page.
class _LineDetailsView extends StatelessWidget {
  final String lineId;
  const _LineDetailsView({required this.lineId});

  @override
  Widget build(BuildContext context) {
     // Access FavoritesBloc assuming it's provided above this page.
     // Use watch to rebuild favorite icon if state changes, read for dispatching.
     final favoritesBloc = context.read<FavoritesBloc>();
     final bool isCurrentlyFavorite = context.select((FavoritesBloc bloc) {
        if (bloc.state is FavoritesLoaded) {
          return (bloc.state as FavoritesLoaded).favorites.any((fav) => fav.lineId == lineId);
        }
        return false; // Assume not favorite if state isn't loaded
     });
      // Alternatively, rely solely on the isFavorite from LineDetailsBloc state


    return Scaffold(
      // Use a CustomScrollView for sliver effects
      body: BlocConsumer<LineDetailsBloc, LineDetailsState>(
         listener: (context, state) {
            // Show snackbar on error, potentially?
             if (state is LineDetailsError) {
                // Helpers.showSnackBar(context, message: state.message, isError: true);
             }
          },
        builder: (context, state) {
          if (state is LineDetailsLoading || state is LineDetailsInitial) {
            return const Center(child: LoadingIndicator());
          }

          if (state is LineDetailsError) {
            return Center(
              child: ErrorDisplay(
                message: state.message,
                onRetry: () => context.read<LineDetailsBloc>().add(LoadLineDetails(lineId: lineId)),
              ),
            );
          }

          if (state is LineDetailsLoaded) {
            final line = state.lineDetails;
            final stops = state.stops;
            final buses = state.activeBuses;
            final bool isLineFavoritedByBloc = state.isFavorite; // Use status from this BLoC

            // Prepare locations map for BusMapView
            final busLocations = buses.fold<Map<String, LocationEntity>>(
               {}, (map, bus) {
                  // TODO: Replace this logic when BusEntity contains lastLocation
                  // For now, generating dummy location if needed by map view
                  // This needs proper fetching/updating logic via BusTrackingBloc or similar
                  map[bus.id] = LocationEntity(
                     latitude: 36.7 + (bus.id.hashCode % 1000)/10000.0,
                     longitude: 3.0 + (bus.id.hashCode % 500)/10000.0,
                     timestamp: DateTime.now()
                  );
                  return map;
               });


            return CustomScrollView(
              slivers: [
                // Collapsing AppBar with Line Name and Favorite Button
                SliverAppBar(
                  expandedHeight: 130.0, // Increased height
                  floating: false,
                  pinned: true,
                  // Use line color for background with some transparency? Or surface?
                  backgroundColor: _parseLineColor(context, line.color).withOpacity(0.8),
                  foregroundColor: Colors.white, // Ensure contrast
                  elevation: 2.0,
                  stretch: true, // Allow stretching on overscroll
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsetsDirectional.only(start: 60, bottom: 14),
                    centerTitle: false,
                    title: Text(
                      line.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        shadows: [ // Add shadow for better readability over background
                          Shadow(offset: Offset(0, 1), blurRadius: 2.0, color: Colors.black45)
                        ]
                      ),
                    ),
                    // Subtle gradient or solid color background for flexible space
                    background: Container(
                       decoration: BoxDecoration(
                          gradient: LinearGradient(
                             begin: Alignment.topCenter,
                             end: Alignment.bottomCenter,
                             colors: [
                                _parseLineColor(context, line.color).withOpacity(0.7),
                                _parseLineColor(context, line.color).withOpacity(0.9),
                             ]
                          )
                       ),
                    ),
                  ),
                   actions: [
                      IconButton(
                         icon: Icon(
                            // Use favorite status from this BLoC's state
                            isLineFavoritedByBloc ? Icons.favorite : Icons.favorite_border,
                            color: isLineFavoritedByBloc ? AppTheme.accentColor : Colors.white,
                         ),
                         tooltip: isLineFavoritedByBloc ? 'Remove from Favorites' : 'Add to Favorites', // TODO: Localize
                         iconSize: 28,
                         onPressed: () {
                            Log.d('Favorite button tapped. Current status (from DetailsBloc): $isLineFavoritedByBloc');
                            if (isLineFavoritedByBloc) {
                               favoritesBloc.add(RemoveFavoriteRequested(lineId: line.id));
                            } else {
                               favoritesBloc.add(AddFavoriteRequested(lineId: line.id));
                            }
                            // Show feedback immediately (optional)
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                               content: Text(isLineFavoritedByBloc ? 'Removing from favorites...' : 'Adding to favorites...'), // TODO: Localize
                               duration: const Duration(seconds: 1),
                            ));
                            // Add a short delay then trigger reload of details to reflect fav status change
                            Future.delayed(const Duration(milliseconds: 500), () {
                               context.read<LineDetailsBloc>().add(LoadLineDetails(lineId: lineId));
                            });
                         },
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                   ],
                ),

                // Header Section with Line Details
                SliverToBoxAdapter(
                  child: Material( // Add Material for elevation/background if needed
                    elevation: 1.0, // Subtle elevation
                    child: LineDetailHeader(line: line),
                  )
                ),

                 SliverToBoxAdapter(child: Container(height: AppTheme.spacingMedium, color: Theme.of(context).scaffoldBackgroundColor)), // Spacer

                // Map View Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
                    child: BusMapView(
                       line: line,
                       stops: stops,
                       activeBuses: buses,
                       busLocations: busLocations, // Pass latest locations
                    ),
                  )
                ),

                 // Stops List Section Header
                 SliverPersistentHeader(
                   pinned: true,
                   delegate: _SectionHeaderDelegate('Stops & ETAs'), // TODO: Localize
                 ),

                 // Stops List with ETAs (check if stops list is empty first)
                 stops.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.spacingLarge),
                        child: Center(child: Text('No stops available for this line.')), // TODO: Localize
                      ),
                    )
                  : LineStopList(
                      stops: stops,
                      etasByStopId: state.etasByStopId,
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

  /// Helper to parse color (can be moved to a utility)
   Color _parseLineColor(BuildContext context, String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return Theme.of(context).colorScheme.primary;
    try { String hex = colorHex.toUpperCase().replaceAll("#", ""); if (hex.length == 6) hex = "FF$hex"; if (hex.length == 8) return Color(int.parse("0x$hex")); } catch (e) { Log.e("Error parsing line color: $colorHex", error: e); }
    return Theme.of(context).colorScheme.primary;
   }
}

/// Delegate for creating sticky section headers within a CustomScrollView.
class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final double height;

  _SectionHeaderDelegate(this.title, {this.height = 48.0}); // Increased height

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final ColorTween backgroundTween = ColorTween(
       begin: theme.scaffoldBackgroundColor,
       end: theme.colorScheme.surfaceVariant, // Slightly different color when stuck
    );
     final double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);


    return Container(
      height: height,
      color: backgroundTween.lerp(progress), // Animate background color
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(_SectionHeaderDelegate oldDelegate) {
    return title != oldDelegate.title || height != oldDelegate.height;
  }
}

