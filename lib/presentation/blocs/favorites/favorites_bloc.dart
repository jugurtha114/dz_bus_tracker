/// lib/presentation/blocs/favorites/favorites_bloc.dart

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart'; // For transformers
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/error/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/favorite_entity.dart';
import '../../../domain/entities/paginated_list_entity.dart';
import '../../../domain/usecases/favorite/add_favorite_line_usecase.dart';
import '../../../domain/usecases/favorite/get_favorite_lines_usecase.dart';
import '../../../domain/usecases/favorite/remove_favorite_line_usecase.dart';
import '../../../domain/usecases/favorite/update_favorite_threshold_usecase.dart'; // Import new use case

part 'favorites_event.dart';
part 'favorites_state.dart';

/// BLoC responsible for managing the state of the user's favorite bus lines list.
///
/// Handles fetching, paginating, adding, removing, and updating favorite lines.
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoriteLinesUseCase _getFavoriteLinesUseCase;
  final AddFavoriteLineUseCase _addFavoriteLineUseCase;
  final RemoveFavoriteLineUseCase _removeFavoriteLineUseCase;
  final UpdateFavoriteThresholdUseCase _updateFavoriteThresholdUseCase;

  /// Creates an instance of [FavoritesBloc].
  FavoritesBloc({
    required GetFavoriteLinesUseCase getFavoriteLinesUseCase,
    required AddFavoriteLineUseCase addFavoriteLineUseCase,
    required RemoveFavoriteLineUseCase removeFavoriteLineUseCase,
    required UpdateFavoriteThresholdUseCase updateFavoriteThresholdUseCase,
  })  : _getFavoriteLinesUseCase = getFavoriteLinesUseCase,
        _addFavoriteLineUseCase = addFavoriteLineUseCase,
        _removeFavoriteLineUseCase = removeFavoriteLineUseCase,
        _updateFavoriteThresholdUseCase = updateFavoriteThresholdUseCase,
        super(const FavoritesInitial()) {

    // Register event handlers
    on<LoadFavorites>(
      _onLoadFavorites,
      transformer: restartable(), // Restart if load requested again quickly
    );
    on<LoadNextFavoritePage>(
      _onLoadNextPage,
      transformer: droppable(), // Ignore if already loading next page
    );
    on<AddFavoriteRequested>(
      _onAddFavoriteRequested,
      transformer: sequential(), // Process add requests one by one
    );
    on<RemoveFavoriteRequested>(
      _onRemoveFavoriteRequested,
      transformer: sequential(), // Process remove requests one by one
    );
    on<UpdateFavoriteThresholdRequested>(
      _onUpdateThresholdRequested,
      transformer: sequential(), // Process update requests one by one
    );
    // Internal event handler to reload list after modification
    on<_FavoritesChanged>(
      (event, emit) => add(const LoadFavorites()), // Trigger full reload
      transformer: restartable(), // Debounce/restart reloads if changes happen rapidly
    );

    // Trigger initial load
    add(const LoadFavorites());
  }

  /// Handles the [LoadFavorites] event (initial load or refresh).
  Future<void> _onLoadFavorites(
      LoadFavorites event, Emitter<FavoritesState> emit) async {
    Log.d('FavoritesBloc: Handling LoadFavorites event.');
    emit(const FavoritesLoading());

    final result = await _getFavoriteLinesUseCase(const GetFavoriteLinesParams(page: 1));

    emit(result.fold(
      (failure) {
        Log.e('FavoritesBloc: Failed to load favorites.', error: failure);
        return FavoritesError(message: failure.message ?? 'Failed to load favorites.');
      },
      (paginatedList) {
        Log.i('FavoritesBloc: Favorites loaded successfully (${paginatedList.items.length} items, hasMore: ${paginatedList.hasMore}).');
        return FavoritesLoaded(
          favorites: paginatedList.items,
          hasReachedMax: !paginatedList.hasMore,
        );
      },
    ));
  }

  /// Handles the [LoadNextFavoritePage] event for pagination.
  Future<void> _onLoadNextPage(
      LoadNextFavoritePage event, Emitter<FavoritesState> emit) async {
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;
      if (currentState.hasReachedMax) {
        Log.d('FavoritesBloc: Reached max favorites, not fetching next page.');
        return;
      }

      final currentPage = (currentState.favorites.length / AppConstants.defaultPaginationSize).ceil();
      final nextPage = currentPage + 1;
      Log.d('FavoritesBloc: Fetching next favorites page: $nextPage');

      // Emit loading state *while preserving* current favorites for better UX
      emit(FavoritesLoading(currentFavorites: currentState.favorites));

      final result = await _getFavoriteLinesUseCase(GetFavoriteLinesParams(page: nextPage));

      emit(result.fold(
        (failure) {
          Log.e('FavoritesBloc: Failed to fetch next favorites page.', error: failure);
          // Revert to previous loaded state on pagination error, show error via listener/snackbar
          return currentState.copyWith(
            // Optionally add an error message to the state or rely on UI listeners
          );
        },
        (paginatedList) {
           Log.i('FavoritesBloc: Next favorites page fetched successfully (${paginatedList.items.length} new items, hasMore: ${paginatedList.hasMore}).');
          return currentState.copyWith(
            favorites: List.of(currentState.favorites)..addAll(paginatedList.items),
            hasReachedMax: !paginatedList.hasMore,
          );
        },
      ));
    } else {
       Log.w('FavoritesBloc: LoadNextFavoritePage event received while not in FavoritesLoaded state.');
    }
  }

  /// Handles the [AddFavoriteRequested] event.
  Future<void> _onAddFavoriteRequested(
      AddFavoriteRequested event, Emitter<FavoritesState> emit) async {
     Log.d('FavoritesBloc: Handling AddFavoriteRequested event for lineId: ${event.lineId}');
     // Optionally emit a specific loading state for this item if needed
     // emit(FavoritesLoading(currentFavorites: state is FavoritesLoaded ? (state as FavoritesLoaded).favorites : []));

     final result = await _addFavoriteLineUseCase(AddFavoriteLineParams(
        lineId: event.lineId,
        notificationThresholdMinutes: event.notificationThresholdMinutes,
     ));

     result.fold(
        (failure) {
           Log.e('FavoritesBloc: Failed to add favorite.', error: failure);
           // Emit an error state or notify UI via listener
           emit(FavoritesError(message: failure.message ?? 'Failed to add favorite.'));
           // Re-emit previous loaded state if needed after showing error
           // if (state is FavoritesError && (state as FavoritesError).previousState is FavoritesLoaded) {
           //    emit((state as FavoritesError).previousState!);
           // }
        },
        (_) {
            Log.i('FavoritesBloc: Favorite added successfully for lineId: ${event.lineId}. Triggering refresh.');
            // Trigger a reload of the favorites list to reflect the change
            add(const _FavoritesChanged());
        }
     );
  }

  /// Handles the [RemoveFavoriteRequested] event.
  Future<void> _onRemoveFavoriteRequested(
      RemoveFavoriteRequested event, Emitter<FavoritesState> emit) async {
      Log.d('FavoritesBloc: Handling RemoveFavoriteRequested event for lineId: ${event.lineId}');
      // Optionally emit loading state

       final result = await _removeFavoriteLineUseCase(RemoveFavoriteLineParams(
         lineId: event.lineId,
      ));

       result.fold(
        (failure) {
           Log.e('FavoritesBloc: Failed to remove favorite.', error: failure);
           emit(FavoritesError(message: failure.message ?? 'Failed to remove favorite.'));
        },
        (_) {
            Log.i('FavoritesBloc: Favorite removed successfully for lineId: ${event.lineId}. Triggering refresh.');
            // Trigger a reload of the favorites list
            add(const _FavoritesChanged());
        }
     );
  }

  /// Handles the [UpdateFavoriteThresholdRequested] event.
  Future<void> _onUpdateThresholdRequested(
      UpdateFavoriteThresholdRequested event, Emitter<FavoritesState> emit) async {
      Log.d('FavoritesBloc: Handling UpdateFavoriteThresholdRequested event for favId: ${event.favoriteId}');
      // Optionally emit loading state

      final result = await _updateFavoriteThresholdUseCase(UpdateFavoriteThresholdParams(
          favoriteId: event.favoriteId,
          notificationThresholdMinutes: event.notificationThresholdMinutes,
      ));

      result.fold(
        (failure) {
           Log.e('FavoritesBloc: Failed to update favorite threshold.', error: failure);
            emit(FavoritesError(message: failure.message ?? 'Failed to update threshold.'));
        },
        (updatedFavorite) {
             Log.i('FavoritesBloc: Favorite threshold updated successfully for favId: ${event.favoriteId}. Triggering refresh.');
            // Trigger a reload to ensure consistency, though optimistic update is possible
            add(const _FavoritesChanged());
            // Optimistic update (alternative to full reload):
            // if (state is FavoritesLoaded) {
            //    final currentState = state as FavoritesLoaded;
            //    final index = currentState.favorites.indexWhere((fav) => fav.id == event.favoriteId);
            //    if (index != -1) {
            //       final updatedList = List<FavoriteEntity>.from(currentState.favorites);
            //       updatedList[index] = updatedFavorite; // Use the returned updated favorite
            //       emit(currentState.copyWith(favorites: updatedList));
            //    } else { add(const _FavoritesChanged()); } // Reload if item not found
            // } else { add(const _FavoritesChanged()); } // Reload if not loaded
        }
     );
  }
}
