/// lib/presentation/blocs/line_details/line_details_event.dart

part of 'line_details_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all events related to fetching bus line details.
/// Uses [Equatable] for value comparison.
abstract class LineDetailsEvent extends Equatable {
  const LineDetailsEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to load all necessary details for a specific bus line,
/// including its core information, stops, active buses, ETAs, and favorite status.
class LoadLineDetails extends LineDetailsEvent {
  /// The unique identifier of the line to load details for.
  final String lineId;

  /// Creates a [LoadLineDetails] event.
  const LoadLineDetails({required this.lineId});

  @override
  List<Object?> get props => [lineId];

  @override
  String toString() => 'LoadLineDetails(lineId: $lineId)';
}
