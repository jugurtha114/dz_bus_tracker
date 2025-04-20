/// lib/presentation/blocs/line_list/line_list_event.dart

part of 'line_list_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all events related to the bus line list.
/// Uses [Equatable] for value comparison.
abstract class LineListEvent extends Equatable {
  const LineListEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to fetch the first page of lines, potentially filtered by a query.
/// Also used to refresh the list or perform a new search.
class FetchLines extends LineListEvent {
  /// The optional search query. If null or empty, fetches all lines.
  final String? query;

  /// Creates a [FetchLines] event.
  /// [query]: The search term to filter lines by name or description.
  const FetchLines({this.query});

  @override
  List<Object?> get props => [query];

  @override
  String toString() => 'FetchLines(query: $query)';
}

/// Event triggered to fetch the next page of lines for pagination/infinite scroll.
/// The BLoC determines the next page number based on the current state.
class FetchNextLineListPage extends LineListEvent {
  const FetchNextLineListPage();
}

// Note: A dedicated SearchLines event is not strictly necessary as FetchLines
// handles the query parameter. Keeping it simple with FetchLines for both
// initial load/refresh and searching.

