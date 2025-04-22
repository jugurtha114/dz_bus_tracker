/// lib/presentation/pages/passenger/favorites_tab.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/themes/app_theme.dart';
import '../../../core/utils/helpers.dart'; // For confirmation dialog
import '../../../core/utils/logger.dart';
import '../../../domain/entities/favorite_entity.dart';
import '../../blocs/favorites/favorites_bloc.dart'; // Import Favorites BLoC
import '../../routes/route_names.dart';
import '../../widgets/common/empty_list_indicator.dart';
import '../../widgets/common/error_display.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/line/line_list_item.dart'; // Reuse LineListItem

/// Widget representing the content for the 'Favorites' tab in the passenger home page.
/// Displays a paginated list of the user's favorite bus lines with swipe-to-remove functionality.
class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Initial fetch if state is initial (or potentially always refresh on tab view)
    final currentState = context.read<FavoritesBloc>().state;
    if (currentState is FavoritesInitial) {
      context.read<FavoritesBloc>().add(const LoadFavorites());
    }
     // else { // Optional: Refresh every time the tab becomes visible?
     //    context.read<FavoritesBloc>().add(const LoadFavorites());
     // }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Listener for scroll events to trigger loading the next page.
  void _onScroll() {
    if (_isBottom) {
      Log.d("FavoritesTab: Reached bottom, attempting to fetch next page.");
      context.read<FavoritesBloc>().add(const LoadNextFavoritePage());
    }
  }

  /// Checks if the user has scrolled to near the bottom of the list.
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9);
  }

   /// Refreshes the list by fetching the first page again.
  Future<void> _refreshList() async {
     Log.d("FavoritesTab: Refreshing list.");
     context.read<FavoritesBloc>().add(const LoadFavorites());
  }

  /// Handles removing a favorite via swipe or button press.
  void _removeFavorite(BuildContext context, String lineId, String lineName) async {
      // Optionally show confirmation dialog
      final confirm = await Helpers.showConfirmationDialog(
         context,
         title: 'Remove Favorite?', // TODO: Localize
         content: 'Are you sure you want to remove Line $lineName from your favorites?', // TODO: Localize
         confirmText: 'Remove', // TODO: Localize
      ) ?? false;

      if (confirm && context.mounted) {
          Log.i('Removing favorite line: $lineId');
          context.read<FavoritesBloc>().add(RemoveFavoriteRequested(lineId: lineId));
          // Show temporary feedback (optional)
          // Helpers.showSnackBar(context, message: 'Removing ${lineName}...');
      }
  }


  @override
  Widget build(BuildContext context) {
    // Placeholder for localization
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');

    return BlocConsumer<FavoritesBloc, FavoritesState>(
      listener: (context, state) {
        // Listener can show Snackbars for errors that occur during background actions like remove
        if (state is FavoritesError && state.props.length == 1) { // Crude check if it's just an error state, not holding previous data
             WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) { // Check if widget is still in tree
                    Helpers.showSnackBar(context, message: state.message, isError: true);
                  }
             });
        }
         // Optionally show success snackbar after add/remove/update actions here
         // Need more specific states or flags if distinguishing between load error and action error
      },
      builder: (context, state) {
        // --- Initial Loading State ---
        if (state is FavoritesInitial || (state is FavoritesLoading && state.currentFavorites == null)) {
           return const Center(child: LoadingIndicator());
        }
        // --- Error State (only show full error if initial load failed) ---
        if (state is FavoritesError && state.previousFavorites == null) {
          return Center(
            child: ErrorDisplay(
              message: state.message,
              onRetry: () => _refreshList(),
            ),
          );
        }
        // --- Loaded State (or Loading More, or Error with previous data) ---
        List<FavoriteEntity> currentFavorites = [];
        bool hasReachedMax = false;
        bool isLoadingMore = false;

        if (state is FavoritesLoaded) {
           currentFavorites = state.favorites;
           hasReachedMax = state.hasReachedMax;
           isLoadingMore = false;
        } else if (state is FavoritesLoading && state.currentFavorites != null) {
           currentFavorites = state.currentFavorites!;
           hasReachedMax = false; // Assume not max if loading more
           isLoadingMore = true;
        } else if (state is FavoritesError && state.previousFavorites != null) {
            currentFavorites = state.previousFavorites!;
            // Determine hasReachedMax based on the previously loaded data
            // This requires storing hasReachedMax with the error or assuming it wasn't max
            hasReachedMax = false; // Assume we can still try loading more after error
            isLoadingMore = false;
        }

        if (currentFavorites.isEmpty && !isLoadingMore) {
          return RefreshIndicator(
             onRefresh: _refreshList,
             child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: EmptyListIndicator(
                      message: 'You haven\'t added any favorite lines yet. Tap the heart icon on a line\'s details page.', // TODO: Localize
                      iconData: Icons.favorite_outline,
                       onRetry: _refreshList, // Allow retry even when empty
                       retryButtonText: 'Refresh',
                    ),
                  ),
                ),
             ),
          );
        }

        // --- Display List ---
        return RefreshIndicator(
           onRefresh: _refreshList,
           child: ListView.builder(
             controller: _scrollController,
             itemCount: hasReachedMax
                 ? currentFavorites.length
                 : currentFavorites.length + (isLoadingMore ? 1 : 0), // +1 for loading indicator only if loading
             itemBuilder: (context, index) {
               if (index >= currentFavorites.length) {
                 // Show loading indicator at the bottom if loading more
                 return const Padding(
                   padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
                   child: Center(child: LoadingIndicator(size: 24)),
                 );
               }

               // Build the favorite line item
               final favorite = currentFavorites[index];
               return Dismissible( // Add swipe-to-remove functionality
                  key: Key('favorite_${favorite.id}'), // Unique key for dismissible
                  direction: DismissDirection.endToStart, // Swipe left to remove
                  onDismissed: (direction) {
                     _removeFavorite(context, favorite.lineId, favorite.lineDetails.name);
                  },
                  background: Container(
                     color: AppTheme.errorColor.withOpacity(0.8),
                     padding: const EdgeInsets.only(right: AppTheme.spacingMedium),
                     alignment: Alignment.centerRight,
                     child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  child: LineListItem(
                     line: favorite.lineDetails,
                     onTap: () {
                       Log.i("Tapped on favorite line: ${favorite.lineDetails.name} (ID: ${favorite.lineId})");
                       context.pushNamed(
                         RouteNames.lineDetails,
                         pathParameters: {'lineId': favorite.lineId},
                       );
                     },
                     // Optional: Add trailing unfavorite button for non-swipe action
                      // trailing: IconButton(
                      //    icon: Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary),
                      //    tooltip: 'Remove Favorite', // TODO: Localize
                      //    onPressed: () => _removeFavorite(context, favorite.lineId, favorite.lineDetails.name),
                      // ),
                  ),
               );
             },
           ),
        );
      },
    );
  }
}

/// Helper class for capitalization (move to string_utils.dart if not already done)
class StringUtil {
   static String capitalizeFirst(String s) { if (s.isEmpty) return ''; return "${s[0].toUpperCase()}${s.substring(1)}"; }
}

