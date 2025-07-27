// lib/screens/passenger/stop_search_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../config/route_config.dart';
import '../../providers/stop_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/widgets.dart';
import '../../models/stop_model.dart';

/// Modern stop search screen with location-based discovery
class StopSearchScreen extends StatefulWidget {
  const StopSearchScreen({super.key});

  @override
  State<StopSearchScreen> createState() => _StopSearchScreenState();
}

class _StopSearchScreenState extends State<StopSearchScreen> {
  late TextEditingController _searchController;
  bool _isLoading = false;
  bool _showNearbyOnly = false;
  List<Stop> _searchResults = [];
  List<Stop> _nearbyStops = [];
  List<Stop> _recentStops = [];
  List<Stop> _popularStops = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Defer loading to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stopProvider = context.read<StopProvider>();
      await Future.wait([
        stopProvider.loadRecentStops(),
        stopProvider.loadPopularStops(),
      ]);
      
      setState(() {
        _recentStops = stopProvider.recentStops;
        _popularStops = stopProvider.popularStops;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final stopProvider = context.read<StopProvider>();
      await stopProvider.searchStops(query);
      
      setState(() {
        _searchResults = stopProvider.searchResults;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _findNearbyStops() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final locationProvider = context.read<LocationProvider>();
      final stopProvider = context.read<StopProvider>();

      // Get current location
      await locationProvider.getCurrentLocation();

      if (locationProvider.currentLocation != null) {
        // Find nearby stops
        await stopProvider.fetchNearbyStops(
          latitude: locationProvider.currentLocation!.latitude,
          longitude: locationProvider.currentLocation!.longitude,
        );

        setState(() {
          _nearbyStops = stopProvider.nearbyStops;
          _showNearbyOnly = true;
        });
      } else {
        throw Exception('Unable to get current location');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to find nearby stops: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Find Stops',
      actions: [
        IconButton(
          icon: Icon(_showNearbyOnly ? Icons.list : Icons.near_me),
          onPressed: () {
            if (_showNearbyOnly) {
              setState(() {
                _showNearbyOnly = false;
              });
            } else {
              _findNearbyStops();
            }
          },
        ),
      ],
      child: Column(
        children: [
          // Search Header
          _buildSearchHeader(context),
          
          // Search Results or Default Content
          Expanded(
            child: _searchController.text.isNotEmpty
                ? _buildSearchResults(context)
                : _showNearbyOnly
                    ? _buildNearbyStops(context)
                    : _buildDefaultContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.space16),
      child: Column(
        children: [
          // Location button
          if (!_showNearbyOnly)
            AppButton(
              text: 'Find Stops Near Me',
              onPressed: _findNearbyStops,
              icon: Icons.near_me,
              size: AppButtonSize.small,
            ),
          
          if (!_showNearbyOnly) const SizedBox(height: DesignSystem.space12),
          
          // Search bar
          AppInput(
            controller: _searchController,
            label: 'Search by stop name or address',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                      });
                    },
                  )
                : null,
            onChanged: (value) {
              setState(() {});
              if (value.length >= 2) {
                _performSearch(value);
              } else {
                setState(() {
                  _searchResults = [];
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_isLoading) {
      return const LoadingState();
    }

    if (_searchResults.isEmpty) {
      return EmptyState(
        title: 'No stops found',
        message: 'No bus stops match your search "${_searchController.text}"',
        icon: Icons.search_off,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space16),
          child: Text(
            '${_searchResults.length} stops found',
            style: context.textStyles.titleSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        
        const SizedBox(height: DesignSystem.space8),
        
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final stop = _searchResults[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: DesignSystem.space8),
                child: _buildStopCard(stop, isSearchResult: true),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyStops(BuildContext context) {
    if (_isLoading) {
      return const LoadingState.fullScreen();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with location info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space16),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                size: 20,
                color: context.colors.primary,
              ),
              const SizedBox(width: DesignSystem.space8),
              Text(
                'Nearby stops',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              AppButton.text(
                text: 'Show All',
                onPressed: () {
                  setState(() {
                    _showNearbyOnly = false;
                  });
                },
                size: AppButtonSize.small,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: DesignSystem.space8),
        
        // Nearby stops list
        Expanded(
          child: _nearbyStops.isEmpty
              ? const EmptyState(
                  title: 'No nearby stops',
                  message: 'No bus stops found in your area.',
                  icon: Icons.location_off,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space16),
                  itemCount: _nearbyStops.length,
                  itemBuilder: (context, index) {
                    final stop = _nearbyStops[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: DesignSystem.space8),
                      child: _buildStopCard(stop, showDistance: true),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDefaultContent(BuildContext context) {
    if (_isLoading) {
      return const LoadingState.fullScreen();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Stops
          if (_recentStops.isNotEmpty) ...[ 
            _buildSection(
              context,
              'Recent Stops',
              _recentStops,
              onClear: _clearRecentStops,
            ),
            const SizedBox(height: DesignSystem.space24),
          ],
          
          // Popular Stops
          _buildSection(
            context,
            'Popular Stops',
            _popularStops,
          ),
          
          const SizedBox(height: DesignSystem.space24),
          
          // Quick Search Options
          _buildQuickSearchOptions(context),
          
          const SizedBox(height: DesignSystem.space24),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Stop> stops, {
    VoidCallback? onClear,
  }) {
    return SectionLayout(
      title: title,
      actions: onClear != null
          ? [
              AppButton.text(
                text: 'Clear',
                onPressed: onClear,
                size: AppButtonSize.small,
              ),
            ]
          : null,
      child: stops.isEmpty
          ? EmptyState(
              title: 'No $title',
              message: 'No stops available in this category',
              icon: Icons.location_on_outlined,
            )
          : Column(
              children: stops.map((stop) => Padding(
                padding: const EdgeInsets.only(bottom: DesignSystem.space8),
                child: _buildStopCard(stop),
              )).toList(),
            ),
    );
  }

  Widget _buildStopCard(Stop stop, {bool isSearchResult = false, bool showDistance = false}) {
    return AppCard(
      onTap: () => _selectStop(stop),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Row(
          children: [
            // Stop icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              ),
              child: Icon(
                Icons.location_on,
                color: context.colors.onPrimaryContainer,
                size: 24,
              ),
            ),
            
            const SizedBox(width: DesignSystem.space16),
            
            // Stop information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stop.name ?? 'Unnamed Stop',
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (stop.address != null) ...[ 
                    const SizedBox(height: DesignSystem.space4),
                    Text(
                      stop.address!,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: DesignSystem.space8),
                  Row(
                    children: [
                      _buildStopDetail(
                        Icons.directions_bus,
                        '${stop.lineCount} lines',
                      ),
                      if (showDistance && stop.distanceFromUser != null) ...[ 
                        const SizedBox(width: DesignSystem.space16),
                        _buildStopDetail(
                          Icons.straighten,
                          '${stop.distanceFromUser?.toStringAsFixed(1) ?? '0.0'} km',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Status and chevron
            Column(
              children: [
                StatusBadge(
                  status: stop.isActive ? 'ACTIVE' : 'INACTIVE',
                  color: _getStopStatusColor(stop.isActive ? 'active' : 'inactive'),
                  
                ),
                const SizedBox(height: DesignSystem.space8),
                Icon(
                  Icons.chevron_right,
                  color: context.colors.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: context.colors.onSurfaceVariant,
        ),
        const SizedBox(width: DesignSystem.space4),
        Text(
          text,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSearchOptions(BuildContext context) {
    return SectionLayout(
      title: 'Quick Search',
      child: ResponsiveGrid(
        mobileColumns: 2,
        tabletColumns: 2,
        children: [
          _buildQuickSearchCard(
            'City Center',
            Icons.location_city,
            'Downtown stops',
            () => _quickSearch('city center'),
          ),
          _buildQuickSearchCard(
            'Universities',
            Icons.school,
            'Campus stops',
            () => _quickSearch('university'),
          ),
          _buildQuickSearchCard(
            'Hospitals',
            Icons.local_hospital,
            'Medical centers',
            () => _quickSearch('hospital'),
          ),
          _buildQuickSearchCard(
            'Shopping',
            Icons.shopping_cart,
            'Mall & shops',
            () => _quickSearch('shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSearchCard(
    String title,
    IconData icon,
    String subtitle,
    VoidCallback onTap,
  ) {
    return AppCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: context.colors.primary,
            ),
            const SizedBox(height: DesignSystem.space8),
            Text(
              title,
              style: context.textStyles.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.space4),
            Text(
              subtitle,
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStopStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return DesignSystem.busActive;
      case 'maintenance':
        return DesignSystem.warning;
      case 'closed':
        return DesignSystem.error;
      default:
        return DesignSystem.busInactive;
    }
  }

  void _selectStop(Stop stop) {
    // Save to recent searches
    final stopProvider = context.read<StopProvider>();
    stopProvider.addToRecentStops(stop);
    
    // Navigate to stop details
    Navigator.of(context).pushNamed(
      AppRoutes.stopDetails,
      arguments: {'stopId': stop.id},
    );
  }

  void _clearRecentStops() {
    final stopProvider = context.read<StopProvider>();
    stopProvider.clearRecentStops();
    
    setState(() {
      _recentStops = [];
    });
  }

  void _quickSearch(String query) {
    _searchController.text = query;
    _performSearch(query);
  }
}