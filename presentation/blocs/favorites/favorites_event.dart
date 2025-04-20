/// lib/presentation/blocs/favorites/favorites_event.dart

part of 'favorites_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all events related to managing favorite lines.
/// Uses [Equatable] for value comparison.
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to load the initial list (first page) of favorite lines.
class LoadFavorites extends FavoritesEvent {
  const LoadFavorites();
}

/// Event triggered to load the next page of favorite lines for pagination.
class LoadNextFavoritePage extends FavoritesEvent {
  const LoadNextFavoritePage();
}

/// Event triggered when the user requests to add a line to favorites.
class AddFavoriteRequested extends FavoritesEvent {
  /// The ID of the line to add.
  final String lineId;
  /// Optional: The notification threshold in minutes for this favorite.
  final int? notificationThresholdMinutes;

  const AddFavoriteRequested({
    required this.lineId,
    this.notificationThresholdMinutes,
  });

  @override
  List<Object?> get props => [lineId, notificationThresholdMinutes];

  @override
  String toString() => 'AddFavoriteRequested(lineId: $lineId, threshold: $notificationThresholdMinutes)';
}

/// Event triggered when the user requests to remove a line from favorites.
class RemoveFavoriteRequested extends FavoritesEvent {
  /// The ID of the line to remove.
  final String lineId;

  const RemoveFavoriteRequested({required this.lineId});

  @override
  List<Object?> get props => [lineId];

   @override
  String toString() => 'RemoveFavoriteRequested(lineId: $lineId)';
}

/// Event triggered when the user requests to update the notification threshold
/// for an existing favorite.
class UpdateFavoriteThresholdRequested extends FavoritesEvent {
  /// The ID of the favorite record itself (not the line ID).
  final String favoriteId;
  /// The new notification threshold in minutes (null to disable).
  final int? notificationThresholdMinutes;

  const UpdateFavoriteThresholdRequested({
    required this.favoriteId,
    this.notificationThresholdMinutes,
  });

  @override
  List<Object?> get props => [favoriteId, notificationThresholdMinutes];

   @override
  String toString() => 'UpdateFavoriteThresholdRequested(favoriteId: $favoriteId, threshold: $notificationThresholdMinutes)';
}

/// Internal event dispatched after an add/remove action to refresh the list.
class _FavoritesChanged extends FavoritesEvent {
  const _FavoritesChanged();
}

