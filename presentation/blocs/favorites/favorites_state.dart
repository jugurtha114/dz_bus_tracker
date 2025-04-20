/// lib/presentation/blocs/favorites/favorites_state.dart

part of 'favorites_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all states related to user's favorite lines.
/// Uses [Equatable] for value comparison.
abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any favorites have been loaded.
class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

/// State indicating that the list of favorite lines is currently being fetched.
class FavoritesLoading extends FavoritesState {
  /// Holds the existing favorites while loading more (for pagination) or during an action.
  final List<FavoriteEntity>? currentFavorites;

  const FavoritesLoading({this.currentFavorites});

  @override
  List<Object?> get props => [currentFavorites];
}

/// State indicating that the list of favorite lines has been successfully loaded.
class FavoritesLoaded extends FavoritesState {
  /// The list of fetched favorite line records.
  final List<FavoriteEntity> favorites;

  /// Flag indicating if all available favorites have been loaded (no more pages).
  final bool hasReachedMax;

  const FavoritesLoaded({
    this.favorites = const [], // Default to empty list
    required this.hasReachedMax,
  });

  /// Creates a copy of the current loaded state with updated values.
  FavoritesLoaded copyWith({
    List<FavoriteEntity>? favorites,
    bool? hasReachedMax,
  }) {
    return FavoritesLoaded(
      favorites: favorites ?? this.favorites,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [favorites, hasReachedMax];

  @override
  String toString() =>
      'FavoritesLoaded(count: ${favorites.length}, hasReachedMax: $hasReachedMax)';
}

/// State indicating that an error occurred while fetching or modifying favorites.
class FavoritesError extends FavoritesState {
  /// The error message describing the failure.
  final String message;
  /// Optional: The list of favorites that were loaded before the error occurred.
  /// Useful for still displaying data while showing an error message (e.g., pagination failure).
  final List<FavoriteEntity>? previousFavorites; // <-- ADDED
  /// Optional: Flag indicating if pagination max was reached before error.
  final bool? hadReachedMax; // <-- ADDED

  const FavoritesError({
    required this.message,
    this.previousFavorites,
    this.hadReachedMax,
  });

  @override
  List<Object?> get props => [message, previousFavorites, hadReachedMax]; // <-- UPDATED props

  @override
  String toString() => 'FavoritesError(message: $message)';
}