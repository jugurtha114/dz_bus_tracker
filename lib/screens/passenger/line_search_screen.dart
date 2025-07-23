// // lib/screens/passenger/line_search_screen.dart
//
// import 'package:flutter/material.dart';
// lib/screens/passenger/line_search_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../core/utils/storage_utils.dart';
import '../../providers/line_provider.dart';
import '../../providers/passenger_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/passenger/line_list_item.dart';
import '../../helpers/error_handler.dart';

class LineSearchScreen extends StatefulWidget {
  const LineSearchScreen({Key? key}) : super(key: key);

  @override
  State<LineSearchScreen> createState() => _LineSearchScreenState();
}

class _LineSearchScreenState extends State<LineSearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<String> _recentSearches = [];
  List<String> _favoriteLines = [];
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _popularLines = [];
  bool _isSearching = false;
  bool _isLoading = false;
  String _selectedFilter = 'all'; // all, nearby, favorites

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load recent searches and favorites from storage
      _recentSearches = await StorageUtils.getFromStorage<List<String>>('recent_searches') ?? [];
      _favoriteLines = await StorageUtils.getFromStorage<List<String>>('favorite_lines') ?? [];

      // Fetch popular/all lines
      final lineProvider = Provider.of<LineProvider>(context, listen: false);
      await lineProvider.fetchLines(isActive: true);

      // Set popular lines (you can implement popularity logic later)
      _popularLines = lineProvider.lines.take(10).toList();

      // Auto-focus search if no popular lines
      if (_popularLines.isEmpty) {
        _searchFocusNode.requestFocus();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          message: ErrorHandler.handleError(e),
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
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    try {
      final passengerProvider = Provider.of<PassengerProvider>(context, listen: false);
      await passengerProvider.searchLines(query: query.trim());

      setState(() {
        _searchResults = passengerProvider.searchResults;
      });

      // Add to recent searches
      await _addToRecentSearches(query.trim());
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          message: ErrorHandler.handleError(e),
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

  Future<void> _addToRecentSearches(String query) async {
    if (_recentSearches.contains(query)) {
      _recentSearches.remove(query);
    }
    _recentSearches.insert(0, query);

    // Keep only last 10 searches
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.take(10).toList();
    }

    await StorageUtils.saveToStorage('recent_searches', _recentSearches);
    setState(() {});
  }

  Future<void> _toggleFavorite(String lineId) async {
    setState(() {
      if (_favoriteLines.contains(lineId)) {
        _favoriteLines.remove(lineId);
      } else {
        _favoriteLines.add(lineId);
      }
    });

    await StorageUtils.saveToStorage('favorite_lines', _favoriteLines);

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _favoriteLines.contains(lineId)
              ? 'Added to favorites'
              : 'Removed from favorites',
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _isSearching = false;
    });
  }

  void _clearRecentSearches() {
    setState(() {
      _recentSearches = [];
    });
    StorageUtils.saveToStorage('recent_searches', <String>[]);
  }

  void _onLineSelected(Map<String, dynamic> line) {
    // Add to recent searches
    _addToRecentSearches(line['name'] ?? '');

    // Navigate to line details
    AppRouter.navigateTo(context, AppRoutes.lineDetails, arguments: line);
  }

  List<Map<String, dynamic>> _getFilteredLines() {
    final lineProvider = Provider.of<LineProvider>(context);

    switch (_selectedFilter) {
      case 'nearby':
      // Filter lines based on nearby stops
        final locationProvider = Provider.of<LocationProvider>(context, listen: false);
        if (locationProvider.currentLocation != null) {
          // This would require nearby stops logic - simplified for demo
          return lineProvider.lines.take(5).toList();
        }
        return lineProvider.lines;
      case 'favorites':
        return lineProvider.lines
            .where((line) => _favoriteLines.contains(line['id']))
            .toList();
      default:
        return lineProvider.lines;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lineProvider = Provider.of<LineProvider>(context);

    return Scaffold(
      appBar: DzAppBar(
        title: 'Search Lines',
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              // Navigate to map view
              Navigator.pop(context);
            },
            tooltip: 'Map View',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                CustomTextField(
                  label: '',
                  hintText: 'Search lines by name, code, or destination...',
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (value) {
                    if (value.length >= 2) {
                      _performSearch(value);
                    } else if (value.isEmpty) {
                      _clearSearch();
                    }
                  },
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                      : null,
                  textInputAction: TextInputAction.search,
                  showBorder: true,
                  borderColor: AppColors.primary.withValues(alpha: 0.3),
                ),

                const SizedBox(height: 12),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All Lines', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Nearby', 'nearby'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Favorites', 'favorites'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingIndicator())
                : _isSearching
                ? _buildSearchResults()
                : _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.white : AppColors.primary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: AppColors.white,
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.lightGrey,
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        title: 'No Results Found',
        subtitle: 'Try different keywords or check spelling',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final line = _searchResults[index];

        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LineListItem(
                  line: line,
                  onTap: () => _onLineSelected(line),
                  isFavorite: _favoriteLines.contains(line['id']),
                  onFavoriteToggle: () => _toggleFavorite(line['id']),
                  showDistance: true, showStops: true,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabContent() {
    return Column(
      children: [
        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.darkGrey,
            tabs: const [
              Tab(text: 'Popular'),
              Tab(text: 'Recent'),
              Tab(text: 'All Lines'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPopularTab(),
              _buildRecentTab(),
              _buildAllLinesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopularTab() {
    if (_popularLines.isEmpty) {
      return _buildEmptyState(
        icon: Icons.trending_up,
        title: 'No Popular Lines',
        subtitle: 'Popular lines will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _popularLines.length,
      itemBuilder: (context, index) {
        final line = _popularLines[index];

        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassyContainer(
                  color: AppColors.glassWhite,
                  child: LineListItem(
                    line: line,
                    onTap: () => _onLineSelected(line),
                    isFavorite: _favoriteLines.contains(line['id']),
                    onFavoriteToggle: () => _toggleFavorite(line['id']),
                    showBadge: true,
                    badgeText: 'Popular',
                    badgeColor: AppColors.warning, showStops: true,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentTab() {
    if (_recentSearches.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'No Recent Searches',
        subtitle: 'Your recent searches will appear here',
      );
    }

    return Column(
      children: [
        // Clear all button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearRecentSearches,
                child: Text(
                  'Clear All',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ),

        // Recent searches list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final search = _recentSearches[index];

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.history,
                          color: AppColors.mediumGrey,
                        ),
                        title: Text(search),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.north_west,
                            color: AppColors.mediumGrey,
                          ),
                          onPressed: () {
                            _searchController.text = search;
                            _performSearch(search);
                          },
                        ),
                        onTap: () {
                          _searchController.text = search;
                          _performSearch(search);
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllLinesTab() {
    final filteredLines = _getFilteredLines();

    if (filteredLines.isEmpty) {
      return _buildEmptyState(
        icon: Icons.directions_bus,
        title: 'No Lines Available',
        subtitle: 'Lines will appear here when available',
      );
    }

    return Column(
      children: [
        // Quick stats
        Container(
          margin: const EdgeInsets.all(16),
          child: GlassyContainer(
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Lines',
                    '${filteredLines.length}',
                    Icons.directions_bus,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.lightGrey,
                ),
                Expanded(
                  child: _buildStatItem(
                    'Favorites',
                    '${_favoriteLines.length}',
                    Icons.favorite,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.lightGrey,
                ),
                Expanded(
                  child: _buildStatItem(
                    'Active',
                    '${filteredLines.where((line) => line['is_active'] == true).length}',
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Lines list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredLines.length,
            itemBuilder: (context, index) {
              final line = filteredLines[index];

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: LineListItem(
                        line: line,
                        onTap: () => _onLineSelected(line),
                        isFavorite: _favoriteLines.contains(line['id']),
                        onFavoriteToggle: () => _toggleFavorite(line['id']),
                        showStatus: true, showStops: true,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.mediumGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.mediumGrey,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.body.copyWith(
              color: AppColors.mediumGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}