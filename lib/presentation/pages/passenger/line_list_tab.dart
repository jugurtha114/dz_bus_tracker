/// lib/presentation/pages/passenger/line_list_tab.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// CORRECTED: Import AppTheme for constants
import '../../../config/themes/app_theme.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/line_entity.dart'; // Import LineEntity
import '../../blocs/line_list/line_list_bloc.dart';
import '../../routes/route_names.dart';
import '../../widgets/common/empty_list_indicator.dart';
import '../../widgets/common/error_display.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/search_input_field.dart';
import '../../widgets/line/line_list_item.dart';

/// Widget representing the content for the 'Lines' tab in the passenger home page.
/// Displays a searchable and paginated list of bus lines.
class LineListTab extends StatefulWidget {
  const LineListTab({super.key});

  @override
  State<LineListTab> createState() => _LineListTabState();
}

class _LineListTabState extends State<LineListTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final currentState = context.read<LineListBloc>().state;
    if (currentState is LineListInitial) {
      context.read<LineListBloc>().add(const FetchLines());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<LineListBloc>().state;
      // Only fetch next page if currently loaded and not reached max
      if (state is LineListLoaded && !state.hasReachedMax) {
        Log.d("LineListTab: Reached bottom, attempting to fetch next page.");
        context.read<LineListBloc>().add(const FetchNextLineListPage());
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _performSearch(String query) {
    Log.d("LineListTab: Performing search with query: '$query'");
    context.read<LineListBloc>().add(FetchLines(query: query.isNotEmpty ? query : null));
  }

  Future<void> _refreshList() async {
    Log.d("LineListTab: Refreshing list.");
    context.read<LineListBloc>().add(FetchLines(query: _searchController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchInputField(
          controller: _searchController,
          hintText: 'Search by line name or number...', // TODO: Localize
          onChanged: (query) => _performSearch(query),
        ),
        Expanded(
          child: BlocBuilder<LineListBloc, LineListState>(
            builder: (context, state) {
              // --- Determine current state for UI ---
              List<LineEntity> currentLines = [];
              bool hasReachedMax = false;
              bool isLoading = false;
              bool isLoadingMore = false;
              bool isFirstFetch = false;
              bool showErrorDisplay = false;
              String? currentQuery;

              if (state is LineListInitial) {
                isLoading = true;
                isFirstFetch = true;
              } else if (state is LineListLoading) {
                isLoading = true;
                isFirstFetch = state.isFirstFetch;
                currentLines = state.currentLines ?? []; // Use currentLines if loading more
                isLoadingMore = !state.isFirstFetch && state.currentLines != null;
              } else if (state is LineListLoaded) {
                isLoading = false;
                currentLines = state.lines;
                hasReachedMax = state.hasReachedMax;
                currentQuery = state.query;
              } else if (state is LineListError) {
                isLoading = false;
                // Try to show previous data if available (e.g., pagination error)
                currentLines = state.previousLines ?? [];
                hasReachedMax = state.hadReachedMax ?? false;
                showErrorDisplay = state.previousLines == null; // Show full error only if initial load failed
              }

              // --- Render UI based on state ---

              if (isLoading && isFirstFetch) {
                return const Center(child: LoadingIndicator());
              }

              if (showErrorDisplay && state is LineListError) {
                return ErrorDisplay(
                  message: state.message,
                  onRetry: () => _refreshList(), // Retry with current query
                );
              }

              if (currentLines.isEmpty && !isLoading) { // Includes case where error happened but had no previous data
                return RefreshIndicator(
                  onRefresh: _refreshList,
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: EmptyListIndicator(
                          message: currentQuery != null && currentQuery.isNotEmpty
                              ? 'No lines found matching "$currentQuery".' // TODO: Localize
                              : 'No bus lines available at the moment.', // TODO: Localize
                          // CORRECTED: Use a valid icon
                          iconData: currentQuery != null && currentQuery.isNotEmpty
                              ? Icons.search_off
                              : Icons.bus_alert_outlined, // Or Icons.list_alt_outlined
                          onRetry: _refreshList,
                          retryButtonText: 'Refresh List', // TODO: Localize
                        ),
                      ),
                    ),
                  ),
                );
              }

              // --- Display List (Loaded or Loading More) ---
              return RefreshIndicator(
                onRefresh: _refreshList,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: hasReachedMax
                      ? currentLines.length
                      : currentLines.length + (isLoadingMore ? 1 : 0), // +1 for loading indicator
                  itemBuilder: (context, index) {
                    if (index >= currentLines.length) {
                      // Bottom loading indicator
                      return isLoadingMore ? const Padding(
                        // CORRECTED: Use AppTheme constant
                        padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
                        child: Center(child: LoadingIndicator(size: 24)),
                      ) : const SizedBox.shrink(); // Render nothing if not loading more but not max reached yet
                    }

                    final line = currentLines[index];
                    return LineListItem(
                      line: line,
                      onTap: () {
                        Log.i("Tapped on line: ${line.name} (ID: ${line.id})");
                        context.pushNamed(
                          RouteNames.lineDetails,
                          pathParameters: {'lineId': line.id},
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Helper class for capitalization (move to string_utils.dart if not already done)
class StringUtil {
  static String capitalizeFirst(String s) { if (s.isEmpty) return ''; return "${s[0].toUpperCase()}${s.substring(1)}"; }
}