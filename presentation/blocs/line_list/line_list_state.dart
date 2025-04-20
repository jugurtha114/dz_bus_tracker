/// lib/presentation/blocs/line_list/line_list_state.dart

part of 'line_list_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all states related to fetching the bus line list.
/// Uses [Equatable] for state comparison.
abstract class LineListState extends Equatable {
  const LineListState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any lines have been requested.
class LineListInitial extends LineListState {
  const LineListInitial();
}

/// State indicating that the list of lines is currently being fetched.
class LineListLoading extends LineListState {
  /// Flag to differentiate between the very first fetch and subsequent fetches
  /// (e.g., loading more items for pagination or after a search).
  /// UI can use this to show a full-screen loader vs. a smaller indicator.
  final bool isFirstFetch;

  /// Holds the existing list of lines while loading more (for pagination UX).
  final List<LineEntity>? currentLines; // <-- ADDED

  const LineListLoading({
    this.isFirstFetch = true,
    this.currentLines, // <-- ADDED
  });

  @override
  // Updated props to include currentLines
  List<Object?> get props => [isFirstFetch, currentLines]; // <-- UPDATED
}

/// State indicating that the list of lines (or search results) has been successfully loaded.
class LineListLoaded extends LineListState {
  /// The list of fetched bus lines for the current page/search.
  final List<LineEntity> lines;
  /// Flag indicating if all available lines have been loaded (no more pages).
  final bool hasReachedMax;
  /// The search query associated with this loaded list (null if not a search result).
  final String? query;

  const LineListLoaded({
    this.lines = const [],
    required this.hasReachedMax,
    this.query,
  });

  /// Creates a copy of the current loaded state with potential modifications.
  LineListLoaded copyWith({
    List<LineEntity>? lines,
    bool? hasReachedMax,
    String? query,
    bool clearQuery = false,
  }) {
    return LineListLoaded(
      lines: lines ?? this.lines,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      query: clearQuery ? null : (query ?? this.query),
    );
  }

  @override
  List<Object?> get props => [lines, hasReachedMax, query];

  @override
  String toString() =>
      'LineListLoaded(lines: ${lines.length}, hasReachedMax: $hasReachedMax, query: $query)';
}

/// State indicating that an error occurred while fetching the list of lines.
class LineListError extends LineListState {
  /// The error message describing the failure.
  final String message;
  /// Optional: The list of lines loaded before the error occurred (e.g., pagination error)
  final List<LineEntity>? previousLines; // <-- ADDED (Consistent with FavoritesError)
  /// Optional: Previous pagination status
  final bool? hadReachedMax; // <-- ADDED

  const LineListError({
    required this.message,
    this.previousLines,
    this.hadReachedMax
  });

  @override
  List<Object?> get props => [message, previousLines, hadReachedMax]; // <-- UPDATED

  @override
  String toString() => 'LineListError(message: $message)';
}