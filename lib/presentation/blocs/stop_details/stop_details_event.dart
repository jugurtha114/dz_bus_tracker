/// lib/presentation/blocs/stop_details/stop_details_event.dart

part of 'stop_details_bloc.dart'; // Link to the BLoC file

/// Base abstract class for all events related to fetching stop details.
/// Uses [Equatable] for value comparison.
abstract class StopDetailsEvent extends Equatable {
  const StopDetailsEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to load all necessary details for a specific bus stop,
/// including its info, serving lines, and current ETAs.
class LoadStopDetails extends StopDetailsEvent {
  /// The unique identifier of the stop to load details for.
  final String stopId;
  /// Optional: Filter ETAs/Lines for a specific line ID at this stop.
  final String? filterByLineId;

  /// Creates a [LoadStopDetails] event.
  const LoadStopDetails({required this.stopId, this.filterByLineId});

  @override
  List<Object?> get props => [stopId, filterByLineId];

  @override
  String toString() => 'LoadStopDetails(stopId: $stopId, filterLineId: $filterByLineId)';
}

/// Event triggered to specifically refresh the ETA list for the current stop.
class RefreshStopEtas extends StopDetailsEvent {
   /// The unique identifier of the stop whose ETAs need refreshing.
  final String stopId;
   /// Optional: Filter ETAs for a specific line ID at this stop.
  final String? filterByLineId;

  const RefreshStopEtas({required this.stopId, this.filterByLineId});

  @override
  List<Object?> get props => [stopId, filterByLineId];
}
