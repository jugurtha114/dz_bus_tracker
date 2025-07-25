// lib/widgets/tracking/tracking_list.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/tracking_model.dart';
import '../../providers/tracking_provider.dart';
import '../common/empty_state_widget.dart' as empty_state;
import '../common/loading_indicator.dart';
import '../common/error_widget.dart';
import 'trip_card.dart';
import 'anomaly_card.dart';
import 'location_update_card.dart';

/// Types of tracking data to display
enum TrackingDataType {
  trips,
  anomalies,
  locationUpdates,
  busLines,
}

/// Filter types for tracking data
enum TrackingFilter {
  all,
  active,
  completed,
  resolved,
  unresolved,
  recent,
}

/// Layout types for tracking list
enum TrackingListLayout {
  standard,  // Standard card layout
  compact,   // Compact card layout
  detailed,  // Detailed card layout
  timeline,  // Timeline layout for location updates
}

/// Comprehensive tracking list widget
class TrackingList extends StatefulWidget {
  final TrackingDataType dataType;
  final TrackingListLayout layout;
  final TrackingFilter filter;
  final bool showFilterChips;
  final bool showSearch;
  final bool enablePullToRefresh;
  final bool enableInfiniteScroll;
  final Function(dynamic)? onItemTap;
  final EdgeInsets? padding;
  final Widget? header;
  final Widget? footer;
  final String? busId;
  final String? tripId;

  const TrackingList({
    super.key,
    required this.dataType,
    this.layout = TrackingListLayout.standard,
    this.filter = TrackingFilter.all,
    this.showFilterChips = true,
    this.showSearch = false,
    this.enablePullToRefresh = true,
    this.enableInfiniteScroll = true,
    this.onItemTap,
    this.padding,
    this.header,
    this.footer,
    this.busId,
    this.tripId,
  });

  @override
  State<TrackingList> createState() => _TrackingListState();
}

class _TrackingListState extends State<TrackingList> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  TrackingFilter _currentFilter = TrackingFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
    
    // Setup infinite scroll
    if (widget.enableInfiniteScroll) {
      _scrollController.addListener(_onScroll);
    }
    
    // Setup search
    if (widget.showSearch) {
      _searchController.addListener(_onSearchChanged);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<TrackingProvider>();
      if (provider.hasMorePages && !provider.isLoading) {
        _loadMoreData();
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _loadMoreData() {
    final provider = context.read<TrackingProvider>();
    switch (widget.dataType) {
      case TrackingDataType.trips:
        provider.loadNextPage();
        break;
      case TrackingDataType.anomalies:
        provider.loadNextPage();
        break;
      case TrackingDataType.locationUpdates:
        provider.loadNextPage();
        break;
      case TrackingDataType.busLines:
        provider.loadMoreBusLines();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && _getDataList(provider).isEmpty) {
          return const Center(child: LoadingIndicator());
        }

        if (provider.error != null && _getDataList(provider).isEmpty) {
          return Center(
            child: ErrorDisplayWidget(
              message: provider.error!,
              actionText: 'Retry',
              onAction: () => _refreshData(provider),
            ),
          );
        }

        final filteredData = _filterData(_getDataList(provider));

        if (filteredData.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            // Header
            if (widget.header != null) widget.header!,
            
            // Search bar
            if (widget.showSearch) _buildSearchBar(),
            
            // Filter chips
            if (widget.showFilterChips) _buildFilterChips(),
            
            // Data list
            Expanded(
              child: widget.enablePullToRefresh
                  ? RefreshIndicator(
                      onRefresh: () => _refreshData(provider),
                      child: _buildDataList(filteredData, provider),
                    )
                  : _buildDataList(filteredData, provider),
            ),
            
            // Footer
            if (widget.footer != null) widget.footer!,
          ],
        );
      },
    );
  }

  /// Get data list based on data type
  List<dynamic> _getDataList(TrackingProvider provider) {
    switch (widget.dataType) {
      case TrackingDataType.trips:
        return provider.trips;
      case TrackingDataType.anomalies:
        return provider.anomalies;
      case TrackingDataType.locationUpdates:
        return provider.locationUpdates;
      case TrackingDataType.busLines:
        return provider.busLines;
    }
  }

  /// Refresh data based on data type
  Future<void> _refreshData(TrackingProvider provider) {
    switch (widget.dataType) {
      case TrackingDataType.trips:
        return provider.loadTrips();
      case TrackingDataType.anomalies:
        return provider.loadAnomalies();
      case TrackingDataType.locationUpdates:
        return provider.loadLocationUpdates();
      case TrackingDataType.busLines:
        return provider.loadBusLines();
    }
  }

  /// Build search bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search ${_getDataTypeName()}...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }

  /// Build filter chips
  Widget _buildFilterChips() {
    final availableFilters = _getAvailableFilters();
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: availableFilters.map((filter) {
          final isSelected = _currentFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getFilterLabel(filter)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _currentFilter = filter;
                });
              },
              avatar: Icon(
                _getFilterIcon(filter),
                size: 16,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build data list
  Widget _buildDataList(List<dynamic> data, TrackingProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 8),
      itemCount: data.length + (provider.hasMorePages ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator at the end
        if (index >= data.length) {
          return const Padding(
            padding: const EdgeInsets.all(16),
            child: Center(child: LoadingIndicator()),
          );
        }

        final item = data[index];
        return _buildDataItem(item);
      },
    );
  }

  /// Build data item based on type
  Widget _buildDataItem(dynamic item) {
    switch (widget.dataType) {
      case TrackingDataType.trips:
        return TripCard(
          trip: item as Trip,
          displayMode: _getTripDisplayMode(),
          onTap: () => widget.onItemTap?.call(item),
        );
      
      case TrackingDataType.anomalies:
        return AnomalyCard(
          anomaly: item as Anomaly,
          displayMode: _getAnomalyDisplayMode(),
          onTap: () => widget.onItemTap?.call(item),
        );
      
      case TrackingDataType.locationUpdates:
        return LocationUpdateCard(
          locationUpdate: item as LocationUpdate,
          displayMode: _getLocationUpdateDisplayMode(),
          onTap: () => widget.onItemTap?.call(item),
        );
      
      case TrackingDataType.busLines:
        return _buildBusLineItem(item as BusLine);
    }
  }

  /// Build bus line item
  Widget _buildBusLineItem(BusLine busLine) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: busLine.trackingStatusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.directions_bus,
                      color: busLine.trackingStatusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bus: ${busLine.bus['license_plate']}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Line: ${busLine.line['name']}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: busLine.trackingStatusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      busLine.trackingStatusText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: busLine.trackingStatusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (busLine.isActive) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Assigned: ${busLine.formattedAssignedAt}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return empty_state.EmptyStateWidget(
      icon: _getEmptyStateIcon(),
      title: _getEmptyStateTitle(),
      message: _getEmptyStateSubtitle(),
      buttonText: 'Refresh',
      onButtonPressed: () {
        final provider = context.read<TrackingProvider>();
        _refreshData(provider);
      },
    );
  }

  /// Filter data based on current filter and search query
  List<dynamic> _filterData(List<dynamic> data) {
    var filtered = data;

    // Apply filter based on data type
    switch (widget.dataType) {
      case TrackingDataType.trips:
        filtered = _filterTrips(filtered.cast<Trip>()).cast<dynamic>();
        break;
      case TrackingDataType.anomalies:
        filtered = _filterAnomalies(filtered.cast<Anomaly>()).cast<dynamic>();
        break;
      case TrackingDataType.locationUpdates:
        filtered = _filterLocationUpdates(filtered.cast<LocationUpdate>()).cast<dynamic>();
        break;
      case TrackingDataType.busLines:
        filtered = _filterBusLines(filtered.cast<BusLine>()).cast<dynamic>();
        break;
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = _applySearch(filtered);
    }

    return filtered;
  }

  /// Filter trips
  List<Trip> _filterTrips(List<Trip> trips) {
    switch (_currentFilter) {
      case TrackingFilter.active:
        return trips.where((t) => !t.isCompleted).toList();
      case TrackingFilter.completed:
        return trips.where((t) => t.isCompleted).toList();
      case TrackingFilter.recent:
        return trips.where((t) => t.isRecent).toList();
      default:
        return trips;
    }
  }

  /// Filter anomalies
  List<Anomaly> _filterAnomalies(List<Anomaly> anomalies) {
    switch (_currentFilter) {
      case TrackingFilter.resolved:
        return anomalies.where((a) => a.resolved).toList();
      case TrackingFilter.unresolved:
        return anomalies.where((a) => !a.resolved).toList();
      case TrackingFilter.recent:
        return anomalies.where((a) => a.isRecent).toList();
      default:
        return anomalies;
    }
  }

  /// Filter location updates
  List<LocationUpdate> _filterLocationUpdates(List<LocationUpdate> updates) {
    switch (_currentFilter) {
      case TrackingFilter.recent:
        return updates.where((u) => u.isRecent).toList();
      default:
        return updates;
    }
  }

  /// Filter bus lines
  List<BusLine> _filterBusLines(List<BusLine> busLines) {
    switch (_currentFilter) {
      case TrackingFilter.active:
        return busLines.where((bl) => bl.isActive).toList();
      default:
        return busLines;
    }
  }

  /// Apply search query
  List<dynamic> _applySearch(List<dynamic> data) {
    final query = _searchQuery.toLowerCase();
    
    return data.where((item) {
      switch (widget.dataType) {
        case TrackingDataType.trips:
          final trip = item as Trip;
          return trip.line['name'].toLowerCase().contains(query) ||
                 trip.bus['license_plate'].toLowerCase().contains(query);
        
        case TrackingDataType.anomalies:
          final anomaly = item as Anomaly;
          return anomaly.typeDisplayName.toLowerCase().contains(query) ||
                 anomaly.description.toLowerCase().contains(query);
        
        case TrackingDataType.locationUpdates:
          final update = item as LocationUpdate;
          return update.bus?['license_plate']?.toLowerCase().contains(query) ?? false;
        
        case TrackingDataType.busLines:
          final busLine = item as BusLine;
          return busLine.bus['license_plate'].toLowerCase().contains(query) ||
                 busLine.line['name'].toLowerCase().contains(query);
      }
    }).toList();
  }

  /// Get available filters for current data type
  List<TrackingFilter> _getAvailableFilters() {
    switch (widget.dataType) {
      case TrackingDataType.trips:
        return [TrackingFilter.all, TrackingFilter.active, TrackingFilter.completed, TrackingFilter.recent];
      case TrackingDataType.anomalies:
        return [TrackingFilter.all, TrackingFilter.resolved, TrackingFilter.unresolved, TrackingFilter.recent];
      case TrackingDataType.locationUpdates:
        return [TrackingFilter.all, TrackingFilter.recent];
      case TrackingDataType.busLines:
        return [TrackingFilter.all, TrackingFilter.active];
    }
  }

  /// Get display modes based on layout
  TripDisplayMode _getTripDisplayMode() {
    switch (widget.layout) {
      case TrackingListLayout.compact:
        return TripDisplayMode.compact;
      case TrackingListLayout.detailed:
        return TripDisplayMode.detailed;
      default:
        return TripDisplayMode.standard;
    }
  }

  AnomalyDisplayMode _getAnomalyDisplayMode() {
    switch (widget.layout) {
      case TrackingListLayout.compact:
        return AnomalyDisplayMode.compact;
      case TrackingListLayout.detailed:
        return AnomalyDisplayMode.detailed;
      default:
        return AnomalyDisplayMode.standard;
    }
  }

  LocationUpdateDisplayMode _getLocationUpdateDisplayMode() {
    switch (widget.layout) {
      case TrackingListLayout.compact:
        return LocationUpdateDisplayMode.compact;
      case TrackingListLayout.detailed:
        return LocationUpdateDisplayMode.detailed;
      case TrackingListLayout.timeline:
        return LocationUpdateDisplayMode.timeline;
      default:
        return LocationUpdateDisplayMode.standard;
    }
  }

  /// Get helper methods for UI strings
  String _getDataTypeName() {
    switch (widget.dataType) {
      case TrackingDataType.trips:
        return 'trips';
      case TrackingDataType.anomalies:
        return 'anomalies';
      case TrackingDataType.locationUpdates:
        return 'location updates';
      case TrackingDataType.busLines:
        return 'bus assignments';
    }
  }

  String _getFilterLabel(TrackingFilter filter) {
    switch (filter) {
      case TrackingFilter.all:
        return 'All';
      case TrackingFilter.active:
        return 'Active';
      case TrackingFilter.completed:
        return 'Completed';
      case TrackingFilter.resolved:
        return 'Resolved';
      case TrackingFilter.unresolved:
        return 'Unresolved';
      case TrackingFilter.recent:
        return 'Recent';
    }
  }

  IconData _getFilterIcon(TrackingFilter filter) {
    switch (filter) {
      case TrackingFilter.all:
        return Icons.list;
      case TrackingFilter.active:
        return Icons.play_arrow;
      case TrackingFilter.completed:
        return Icons.check_circle;
      case TrackingFilter.resolved:
        return Icons.check_circle;
      case TrackingFilter.unresolved:
        return Icons.warning;
      case TrackingFilter.recent:
        return Icons.access_time;
    }
  }

  IconData _getEmptyStateIcon() {
    switch (widget.dataType) {
      case TrackingDataType.trips:
        return Icons.route;
      case TrackingDataType.anomalies:
        return Icons.warning;
      case TrackingDataType.locationUpdates:
        return Icons.location_on;
      case TrackingDataType.busLines:
        return Icons.directions_bus;
    }
  }

  String _getEmptyStateTitle() {
    if (_searchQuery.isNotEmpty) {
      return 'No Results Found';
    }
    
    switch (widget.dataType) {
      case TrackingDataType.trips:
        return _currentFilter == TrackingFilter.active ? 'No Active Trips' : 'No Trips';
      case TrackingDataType.anomalies:
        return _currentFilter == TrackingFilter.unresolved ? 'No Unresolved Anomalies' : 'No Anomalies';
      case TrackingDataType.locationUpdates:
        return 'No Location Updates';
      case TrackingDataType.busLines:
        return 'No Bus Assignments';
    }
  }

  String _getEmptyStateSubtitle() {
    if (_searchQuery.isNotEmpty) {
      return 'Try adjusting your search terms or filters.';
    }
    
    switch (widget.dataType) {
      case TrackingDataType.trips:
        return 'Start tracking buses to see trip data here.';
      case TrackingDataType.anomalies:
        return 'No anomalies detected in the tracking system.';
      case TrackingDataType.locationUpdates:
        return 'No location data available for the selected filters.';
      case TrackingDataType.busLines:
        return 'No buses are currently assigned to routes.';
    }
  }
}