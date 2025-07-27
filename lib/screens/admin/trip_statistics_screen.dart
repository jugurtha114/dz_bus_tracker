// lib/screens/admin/trip_statistics_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/widgets.dart';

/// Trip statistics screen for admins to view comprehensive trip analytics
class TripStatisticsScreen extends StatefulWidget {
  const TripStatisticsScreen({super.key});

  @override
  State<TripStatisticsScreen> createState() => _TripStatisticsScreenState();
}

class _TripStatisticsScreenState extends State<TripStatisticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    try {
      final adminProvider = context.read<AdminProvider>();
      await adminProvider.loadTripStatistics();
      setState(() => _statistics = adminProvider.tripStatistics);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load statistics: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Trip Statistics',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadStatistics,
        ),
      ],
      child: _isLoading
          ? const LoadingState.fullScreen()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(DesignSystem.space16),
              child: Column(
                children: [
                  // Overview Statistics
                  SectionLayout(
                    title: 'Trip Overview',
                    child: StatsSection(
                      crossAxisCount: 2,
                      stats: [
                        StatItem(
                          value: '${_statistics['total_trips'] ?? 0}',
                          label: 'Total\\nTrips',
                          icon: Icons.trip_origin,
                          color: context.colors.primary,
                        ),
                        StatItem(
                          value: '${_statistics['completed_trips'] ?? 0}',
                          label: 'Completed\\nTrips',
                          icon: Icons.check_circle,
                          color: context.successColor,
                        ),
                        StatItem(
                          value: '${_statistics['cancelled_trips'] ?? 0}',
                          label: 'Cancelled\\nTrips',
                          icon: Icons.cancel,
                          color: context.colors.error,
                        ),
                        StatItem(
                          value: '${_statistics['avg_passengers'] ?? 0}',
                          label: 'Avg\\nPassengers',
                          icon: Icons.people,
                          color: context.infoColor,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: DesignSystem.space16),
                  
                  // Performance Metrics
                  SectionLayout(
                    title: 'Performance Metrics',
                    child: StatsSection(
                      crossAxisCount: 2,
                      stats: [
                        StatItem(
                          value: '${_statistics['on_time_percentage'] ?? 0}%',
                          label: 'On-Time\\nPerformance',
                          icon: Icons.schedule,
                          color: context.successColor,
                        ),
                        StatItem(
                          value: '${_statistics['avg_rating'] ?? 0.0}',
                          label: 'Average\\nRating',
                          icon: Icons.star,
                          color: context.warningColor,
                        ),
                        StatItem(
                          value: '${_statistics['total_distance'] ?? 0} km',
                          label: 'Total\\nDistance',
                          icon: Icons.straighten,
                          color: context.infoColor,
                        ),
                        StatItem(
                          value: '${_statistics['fuel_efficiency'] ?? 0} L/100km',
                          label: 'Fuel\\nEfficiency',
                          icon: Icons.local_gas_station,
                          color: context.colors.primary,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: DesignSystem.space16),
                  
                  // Chart Placeholders
                  SectionLayout(
                    title: 'Trip Trends',
                    child: AppCard(
                      child: Container(
                        height: 200,
                        padding: const EdgeInsets.all(DesignSystem.space16),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 48,
                                color: context.colors.primary,
                              ),
                              const SizedBox(height: DesignSystem.space8),
                              Text(
                                'Trip Trends Chart',
                                style: context.textStyles.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Daily trip completion trends',
                                style: context.textStyles.bodyMedium?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: DesignSystem.space16),
                  
                  SectionLayout(
                    title: 'Route Performance',
                    child: AppCard(
                      child: Container(
                        height: 200,
                        padding: const EdgeInsets.all(DesignSystem.space16),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.route,
                                size: 48,
                                color: context.colors.primary,
                              ),
                              const SizedBox(height: DesignSystem.space8),
                              Text(
                                'Route Performance',
                                style: context.textStyles.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Performance by route comparison',
                                style: context.textStyles.bodyMedium?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}