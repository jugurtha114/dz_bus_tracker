// lib/widgets/tracking/tracking_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/tracking_model.dart';
import '../../providers/tracking_provider.dart';
import '../common/loading_indicator.dart';
import '../common/error_widget.dart';
import '../common/glassy_container.dart';
import 'trip_card.dart';
import 'anomaly_card.dart';
import 'location_update_card.dart';
import 'tracking_list.dart';

/// Comprehensive tracking dashboard widget
class TrackingDashboard extends StatefulWidget {
  final String? busId;
  final String? driverId;
  final bool showMetrics;
  final bool showRecentActivity;
  final bool showActiveTrips;
  final bool showAnomalies;
  final EdgeInsets? padding;

  const TrackingDashboard({
    super.key,
    this.busId,
    this.driverId,
    this.showMetrics = true,
    this.showRecentActivity = true,
    this.showActiveTrips = true,
    this.showAnomalies = true,
    this.padding,
  });

  @override
  State<TrackingDashboard> createState() => _TrackingDashboardState();
}

class _TrackingDashboardState extends State<TrackingDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final provider = context.read<TrackingProvider>();
    provider.loadTrips();
    provider.loadAnomalies();
    provider.loadLocationUpdates();
    provider.loadBusLines();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackingProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: widget.padding ?? const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard header
              _buildHeader(context, provider),
              
              const SizedBox(height: 20),

              // Metrics overview
              if (widget.showMetrics) ...[
                _buildMetricsOverview(context, provider),
                const SizedBox(height: 20),
              ],

              // Tab navigation
              _buildTabBar(context),
              
              const SizedBox(height: 16),

              // Tab content
              Expanded(
                child: _buildTabContent(context, provider),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build dashboard header
  Widget _buildHeader(BuildContext context, TrackingProvider provider) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          Icons.dashboard,
          size: 28,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tracking Dashboard',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.busId != null || widget.driverId != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.busId != null 
                      ? 'Bus: ${widget.busId}'
                      : 'Driver: ${widget.driverId}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          onPressed: _loadData,
          icon: provider.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                )
              : const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  /// Build metrics overview
  Widget _buildMetricsOverview(BuildContext context, TrackingProvider provider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildMetricCard(
          context,
          'Active Trips',
          provider.trips.where((t) => !t.isCompleted).length.toString(),
          Icons.directions_bus,
          Colors.blue,
        ),
        _buildMetricCard(
          context,
          'Anomalies',
          provider.anomalies.where((a) => !a.resolved).length.toString(),
          Icons.warning,
          Colors.orange,
        ),
        _buildMetricCard(
          context,
          'Bus Lines',
          provider.busLines.where((bl) => bl.isActive).length.toString(),
          Icons.route,
          Colors.green,
        ),
        _buildMetricCard(
          context,
          'Recent Updates',
          provider.locationUpdates.where((u) => u.isRecent).length.toString(),
          Icons.location_on,
          Colors.purple,
        ),
      ],
    );
  }

  /// Build metric card
  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return GlassyContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build tab bar
  Widget _buildTabBar(BuildContext context) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabs: const [
        Tab(
          icon: Icon(Icons.directions_bus),
          text: 'Trips',
        ),
        Tab(
          icon: Icon(Icons.warning),
          text: 'Anomalies',
        ),
        Tab(
          icon: Icon(Icons.location_on),
          text: 'Locations',
        ),
        Tab(
          icon: Icon(Icons.route),
          text: 'Bus Lines',
        ),
      ],
    );
  }

  /// Build tab content
  Widget _buildTabContent(BuildContext context, TrackingProvider provider) {
    if (provider.isLoading && _hasNoData(provider)) {
      return const Center(child: LoadingIndicator());
    }

    if (provider.error != null && _hasNoData(provider)) {
      return Center(
        child: ErrorDisplayWidget(
          message: provider.error!,
          actionText: 'Retry',
          onAction: _loadData,
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        // Trips tab
        _buildTripsTab(context, provider),
        
        // Anomalies tab
        _buildAnomaliesTab(context, provider),
        
        // Location updates tab
        _buildLocationUpdatesTab(context, provider),
        
        // Bus lines tab
        _buildBusLinesTab(context, provider),
      ],
    );
  }

  /// Build trips tab
  Widget _buildTripsTab(BuildContext context, TrackingProvider provider) {
    if (provider.trips.isEmpty) {
      return _buildEmptyState(
        context,
        'No trips found',
        'Start tracking buses to see trip data here.',
        Icons.directions_bus,
      );
    }

    return Column(
      children: [
        // Recent active trip
        if (provider.trips.any((t) => !t.isCompleted)) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Active Trip',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TripCard(
            trip: provider.trips.firstWhere((t) => !t.isCompleted),
            displayMode: TripDisplayMode.dashboard,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          const SizedBox(height: 16),
        ],

        // All trips list
        Expanded(
          child: TrackingList(
            dataType: TrackingDataType.trips,
            layout: TrackingListLayout.standard,
            busId: widget.busId,
            enablePullToRefresh: true,
            enableInfiniteScroll: true,
            header: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'All Trips',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build anomalies tab
  Widget _buildAnomaliesTab(BuildContext context, TrackingProvider provider) {
    if (provider.anomalies.isEmpty) {
      return _buildEmptyState(
        context,
        'No anomalies detected',
        'All systems are running normally.',
        Icons.check_circle,
        Colors.green,
      );
    }

    // Check for critical anomalies
    final criticalAnomalies = provider.anomalies
        .where((a) => !a.resolved && a.severity == AnomalySeverity.high)
        .toList();

    return Column(
      children: [
        // Critical anomalies alert
        if (criticalAnomalies.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Critical Anomalies',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
          ...criticalAnomalies.take(2).map(
            (anomaly) => AnomalyCard(
              anomaly: anomaly,
              displayMode: AnomalyDisplayMode.alert,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // All anomalies list
        Expanded(
          child: TrackingList(
            dataType: TrackingDataType.anomalies,
            layout: TrackingListLayout.standard,
            busId: widget.busId,
            enablePullToRefresh: true,
            enableInfiniteScroll: true,
            header: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'All Anomalies',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build location updates tab
  Widget _buildLocationUpdatesTab(BuildContext context, TrackingProvider provider) {
    if (provider.locationUpdates.isEmpty) {
      return _buildEmptyState(
        context,
        'No location updates',
        'Location data will appear here when available.',
        Icons.location_off,
      );
    }

    return TrackingList(
      dataType: TrackingDataType.locationUpdates,
      layout: TrackingListLayout.timeline,
      busId: widget.busId,
      enablePullToRefresh: true,
      enableInfiniteScroll: true,
      showSearch: true,
    );
  }

  /// Build bus lines tab
  Widget _buildBusLinesTab(BuildContext context, TrackingProvider provider) {
    if (provider.busLines.isEmpty) {
      return _buildEmptyState(
        context,
        'No bus assignments',
        'Buses will be assigned to routes here.',
        Icons.route,
      );
    }

    return TrackingList(
      dataType: TrackingDataType.busLines,
      layout: TrackingListLayout.standard,
      enablePullToRefresh: true,
      enableInfiniteScroll: true,
      showSearch: true,
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, [
    Color? iconColor,
  ]) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: iconColor ?? theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Check if all data is empty
  bool _hasNoData(TrackingProvider provider) {
    return provider.trips.isEmpty &&
        provider.anomalies.isEmpty &&
        provider.locationUpdates.isEmpty &&
        provider.busLines.isEmpty;
  }
}