/// lib/presentation/blocs/line_list/line_list_bloc.dart

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart'; // For transformers
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart'; // For debounce

import '../../../core/constants/app_constants.dart'; // For pagination size
import '../../../core/error/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/line_entity.dart';
import '../../../domain/entities/paginated_list_entity.dart';
import '../../../domain/usecases/line/get_lines_usecase.dart';

part 'line_list_event.dart';
part 'line_list_state.dart';

/// Debounce duration for search queries to avoid excessive API calls.
const _debounceDuration = Duration(milliseconds: 300);

/// Transformer function to debounce events.
EventTransformer<Event> debounceRestartable<Event>(Duration duration) {
  return (events, mapper) => restartable<Event>()(events.debounce(duration), mapper);
}


/// BLoC responsible for managing the state of the bus line list.
///
/// Handles fetching initial lists, searching/filtering, and loading subsequent
/// pages for pagination.
class LineListBloc extends Bloc<LineListEvent, LineListState> {
  final GetLinesUseCase _getLinesUseCase;

  /// Creates an instance of [LineListBloc].
  /// Requires a [GetLinesUseCase] to fetch line data.
  LineListBloc({required GetLinesUseCase getLinesUseCase})
      : _getLinesUseCase = getLinesUseCase,
        super(const LineListInitial()) {

    // Register event handlers with appropriate transformers
    on<FetchLines>(
      _onFetchLines,
      // Use debounceRestartable to prevent rapid firing during search typing
      // and ensure only the latest search query is processed.
      transformer: debounceRestartable(_debounceDuration),
    );
    on<FetchNextLineListPage>(
      _onFetchNextPage,
      // Use droppable to ignore new pagination requests if one is already processing.
      transformer: droppable(),
    );
  }

  /// Handles the [FetchLines] event (initial fetch, refresh, or search).
  Future<void> _onFetchLines(FetchLines event, Emitter<LineListState> emit) async {
    Log.d('LineListBloc: Handling FetchLines event (query: ${event.query})');
    emit(const LineListLoading(isFirstFetch: true)); // Show loading for initial/search fetch

    final result = await _getLinesUseCase(GetLinesParams(
      page: 1, // Always fetch page 1 for a new search/refresh
      searchQuery: event.query,
      // Add other filters like isActive if needed from the event later
    ));

    emit(result.fold(
      (failure) {
        Log.e('LineListBloc: Failed to fetch lines.', error: failure);
        return LineListError(message: failure.message ?? 'Failed to load lines.');
      },
      (paginatedList) {
         Log.i('LineListBloc: Lines fetched successfully (${paginatedList.items.length} items, hasMore: ${paginatedList.hasMore}).');
        return LineListLoaded(
          lines: paginatedList.items,
          hasReachedMax: !paginatedList.hasMore,
          query: event.query, // Store the query used for this result
        );
      },
    ));
  }

  /// Handles the [FetchNextLineListPage] event for pagination.
  Future<void> _onFetchNextPage(FetchNextLineListPage event, Emitter<LineListState> emit) async {
     Log.d('LineListBloc: Handling FetchNextPage event.');
    // Ensure we are in a loaded state and haven't reached the max number of items
    if (state is LineListLoaded) {
      final currentState = state as LineListLoaded;
      if (currentState.hasReachedMax) {
        Log.d('LineListBloc: Reached max lines, not fetching next page.');
        return; // Do nothing if max reached
      }

      // Calculate the next page number
      final currentPage = (currentState.lines.length / AppConstants.defaultPaginationSize).ceil();
      final nextPage = currentPage + 1;
      Log.d('LineListBloc: Fetching next page: $nextPage');

      // No loading state emitted here, UI should show bottom indicator based on state + scroll

      final result = await _getLinesUseCase(GetLinesParams(
        page: nextPage,
        searchQuery: currentState.query, // Preserve current search query for pagination
        // Add other persistent filters if necessary
      ));

      emit(result.fold(
        (failure) {
          Log.e('LineListBloc: Failed to fetch next page.', error: failure);
          // Keep current items, but indicate error. Could add error field to state?
          // For now, just log error and keep existing state. UI can show snackbar.
          // Consider emitting a specific PaginationError state if needed.
          return currentState; // Keep current state on pagination error
        },
        (paginatedList) {
          Log.i('LineListBloc: Next page fetched successfully (${paginatedList.items.length} new items, hasMore: ${paginatedList.hasMore}).');
          // Append new items to the existing list
          return currentState.copyWith(
            lines: List.of(currentState.lines)..addAll(paginatedList.items),
            hasReachedMax: !paginatedList.hasMore,
          );
        },
      ));
    } else {
      Log.w('LineListBloc: FetchNextPage event received while not in LineListLoaded state.');
      // Optionally, trigger an initial fetch if in Initial state?
      // if (state is LineListInitial) {
      //   add(const FetchLines());
      // }
    }
  }
}
