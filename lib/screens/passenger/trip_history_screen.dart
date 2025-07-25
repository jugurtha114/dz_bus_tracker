// lib/screens/passenger/trip_history_screen.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../core/utils/date_utils.dart';
import '../../services/trip_service.dart';
import '../../widgets/common/app_layout.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../localization/app_localizations.dart';
import '../../helpers/dialog_helper.dart';
import '../../widgets/common/custom_card.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TripService _tripService = TripService();
  bool _isLoading = true;
  String _searchQuery = '';
  
  List<Map<String, dynamic>> _allTrips = [];
  List<Map<String, dynamic>> _completedTrips = [];
  List<Map<String, dynamic>> _cancelledTrips = [];
  List<Map<String, dynamic>> _upcomingTrips = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTripHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTripHistory() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate loading trip history from API
      await Future.delayed(const Duration(seconds: 1));
      
      _allTrips = [
        {
          'id': '1',
          'trip_number': 'T240724001',
          'line_id': '1',
          'line_name': 'Line 1 - City Center - Airport',
          'line_code': 'L001',
          'bus_number': 'DZ-001-AB',
          'driver_name': 'Ahmed Ben Ali',
          'origin_stop': 'City Center Plaza',
          'destination_stop': 'Airport Terminal 1',
          'departure_time': '2024-07-24T08:30:00Z',
          'arrival_time': '2024-07-24T09:15:00Z',
          'boarded_at': '2024-07-24T08:32:00Z',
          'alighted_at': '2024-07-24T09:10:00Z',
          'fare_paid': 150,
          'payment_method': 'card',
          'status': 'completed',
          'rating': 4,
          'feedback': 'Great service, on time arrival',
          'distance': 25,
          'duration_minutes': 45,
          'passenger_count': 28,
        },
        {
          'id': '2',
          'trip_number': 'T240723002',
          'line_id': '2',
          'line_name': 'Line 2 - University - Shopping Mall',
          'line_code': 'L002',
          'bus_number': 'DZ-002-CD',
          'driver_name': 'Fatima Zohra',
          'origin_stop': 'University Main Gate',
          'destination_stop': 'Shopping Mall Central',
          'departure_time': '2024-07-23T14:20:00Z',
          'arrival_time': '2024-07-23T14:55:00Z',
          'boarded_at': '2024-07-23T14:22:00Z',
          'alighted_at': '2024-07-23T14:50:00Z',
          'fare_paid': 120,
          'payment_method': 'cash',
          'status': 'completed',
          'rating': 5,
          'feedback': 'Excellent driver, smooth ride',
          'distance': 18,
          'duration_minutes': 35,
          'passenger_count': 22,
        },
        {
          'id': '3',
          'trip_number': 'T240722003',
          'line_id': '4',
          'line_name': 'Line 4 - Beach - Downtown',
          'line_code': 'L004',
          'bus_number': 'DZ-004-GH',
          'driver_name': 'Mohammed Kassim',
          'origin_stop': 'Beach Promenade',
          'destination_stop': 'Downtown Plaza',
          'departure_time': '2024-07-22T16:45:00Z',
          'arrival_time': null,
          'boarded_at': null,
          'alighted_at': null,
          'fare_paid': 0,
          'payment_method': null,
          'status': 'cancelled',
          'rating': null,
          'feedback': null,
          'distance': 12,
          'duration_minutes': 0,
          'passenger_count': 0,
          'cancellation_reason': 'Bus breakdown',
          'cancelled_at': '2024-07-22T16:40:00Z',
        },
        {
          'id': '4',
          'trip_number': 'T240721004',
          'line_id': '5',
          'line_name': 'Line 5 - Hospital - Train Station',
          'line_code': 'L005',
          'bus_number': 'DZ-005-IJ',
          'driver_name': 'Omar Abdullah',
          'origin_stop': 'Central Hospital',
          'destination_stop': 'Train Station Plaza',
          'departure_time': '2024-07-21T11:10:00Z',
          'arrival_time': '2024-07-21T11:40:00Z',
          'boarded_at': '2024-07-21T11:12:00Z',
          'alighted_at': '2024-07-21T11:35:00Z',
          'fare_paid': 130,
          'payment_method': 'mobile',
          'status': 'completed',
          'rating': 4,
          'feedback': 'Good service but slightly delayed',
          'distance': 15,
          'duration_minutes': 30,
          'passenger_count': 18,
        },
        {
          'id': '5',
          'trip_number': 'T240725005',
          'line_id': '1',
          'line_name': 'Line 1 - City Center - Airport',
          'line_code': 'L001',
          'bus_number': 'DZ-001-AB',
          'driver_name': 'Ahmed Ben Ali',
          'origin_stop': 'City Center Plaza',
          'destination_stop': 'Airport Terminal 1',
          'departure_time': '2024-07-25T10:30:00Z',
          'arrival_time': null,
          'boarded_at': null,
          'alighted_at': null,
          'fare_paid': 150,
          'payment_method': 'card',
          'status': 'upcoming',
          'rating': null,
          'feedback': null,
          'distance': 25,
          'duration_minutes': 45,
          'passenger_count': 0,
        },
      ];

      _categorizeTrips();
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _categorizeTrips() {
    _completedTrips = _allTrips.where((t) => t['status'] == 'completed').toList();
    _cancelledTrips = _allTrips.where((t) => t['status'] == 'cancelled').toList();
    _upcomingTrips = _allTrips.where((t) => t['status'] == 'upcoming').toList();
  }

  List<Map<String, dynamic>> _getFilteredTrips(List<Map<String, dynamic>> trips) {
    if (_searchQuery.isEmpty) return trips;
    
    return trips.where((trip) {
      final lineName = trip['line_name'].toLowerCase();
      final tripNumber = trip['trip_number'].toLowerCase();
      final origin = trip['origin_stop'].toLowerCase();
      final destination = trip['destination_stop'].toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return lineName.contains(query) || 
             tripNumber.contains(query) || 
             origin.contains(query) || 
             destination.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AppLayout(
      title: 'Trip History',
      child: Column(
        children: [
          // Search and filters
          _buildSearchSection(),
          
          // Stats overview
          _buildStatsOverview(),
          
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.primary,
              isScrollable: true,
              tabs: [
                _buildTabWithBadge('All', _allTrips.length),
                _buildTabWithBadge('Completed', _completedTrips.length),
                _buildTabWithBadge('Upcoming', _upcomingTrips.length),
                _buildTabWithBadge('Cancelled', _cancelledTrips.length),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTripsList(_getFilteredTrips(_allTrips)),
                      _buildTripsList(_getFilteredTrips(_completedTrips)),
                      _buildTripsList(_getFilteredTrips(_upcomingTrips)),
                      _buildTripsList(_getFilteredTrips(_cancelledTrips)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search trips by line, number, or stops...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    final totalDistance = _completedTrips.fold<double>(0, (sum, trip) => sum + (trip['distance'] as double));
    final totalSpent = _completedTrips.fold<double>(0, (sum, trip) => sum + (trip['fare_paid'] as double));
    final avgRating = _completedTrips.where((t) => t['rating'] != null).isNotEmpty
        ? _completedTrips.where((t) => t['rating'] != null).fold<double>(0, (sum, trip) => sum + (trip['rating'] as double)) / 
          _completedTrips.where((t) => t['rating'] != null).length
        : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Trips',
              '${_completedTrips.length}',
              Icons.trip_origin,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Distance',
              '${totalDistance.toInt()} km',
              Icons.straighten,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Total Spent',
              '${totalSpent.toInt()} DA',
              Icons.monetization_on,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Avg Rating',
              avgRating > 0 ? avgRating.toStringAsFixed(1) : 'N/A',
              Icons.star,
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return CustomCard(type: CardType.elevated, 
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabWithBadge(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 8, height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList(List<Map<String, dynamic>> trips) {
    if (trips.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(),
            Text('No trips found'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTripHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return _buildTripCard(trip);
        },
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final status = trip['status'] as String;
    final departureTime = DateTime.tryParse(trip['departure_time'] ?? '');
    final arrivalTime = trip['arrival_time'] != null ? DateTime.tryParse(trip['arrival_time']) : null;

    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'completed':
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.check_circle;
        break;
      case 'upcoming':
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.schedule;
        break;
      case 'cancelled':
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.help;
    }

    return CustomCard(type: CardType.elevated, 
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTripDetails(trip),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12, height: 40),
                  
                  // Trip info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              trip['trip_number'],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8, height: 40),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${trip['line_code']} - ${trip['line_name']}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Fare info
                  if (status == 'completed')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${trip['fare_paid']} DA',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          trip['payment_method'] ?? '',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Route info
              Row(
                children: [
                  Icon(Icons.radio_button_checked, size: 12, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8, height: 40),
                  Expanded(
                    child: Text(
                      trip['origin_stop'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 2,
        
                    color: Theme.of(context).colorScheme.primary,
                    margin: const EdgeInsets.only(left: 5),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.location_on, size: 12, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8, height: 40),
                  Expanded(
                    child: Text(
                      trip['destination_stop'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Time and additional info
              Row(
                children: [
                  if (departureTime != null) ...[
                    Icon(Icons.schedule, size: 14, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 4, height: 40),
                    Text(
                      DzDateUtils.formatDateTime(departureTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (status == 'completed' && trip['rating'] != null) ...[
                    Icon(Icons.star, size: 14, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 4, height: 40),
                    Text(
                      '${trip['rating']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              
              // Additional info for cancelled trips
              if (status == 'cancelled' && trip['cancellation_reason'] != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8, height: 40),
                      Expanded(
                        child: Text(
                          'Cancelled: ${trip['cancellation_reason']}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showTripDetails(Map<String, dynamic> trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0,
        minChildSize: 0,
        maxChildSize: 0,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
        
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'Trip Details',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDetailRow('Trip Number', trip['trip_number']),
                    _buildDetailRow('Line', '${trip['line_code']} - ${trip['line_name']}'),
                    _buildDetailRow('Bus Number', trip['bus_number']),
                    _buildDetailRow('Driver', trip['driver_name']),
                    _buildDetailRow('Status', trip['status'].toUpperCase()),
                    _buildDetailRow('Origin', trip['origin_stop']),
                    _buildDetailRow('Destination', trip['destination_stop']),
                    
                    if (trip['departure_time'] != null)
                      _buildDetailRow('Departure Time', 
                        DateTime.tryParse(trip['departure_time']) != null
                            ? DzDateUtils.formatDateTime(DateTime.parse(trip['departure_time']))
                            : 'Unknown'
                      ),
                    
                    if (trip['arrival_time'] != null)
                      _buildDetailRow('Arrival Time', 
                        DateTime.tryParse(trip['arrival_time']) != null
                            ? DzDateUtils.formatDateTime(DateTime.parse(trip['arrival_time']))
                            : 'Unknown'
                      ),
                    
                    if (trip['fare_paid'] > 0)
                      _buildDetailRow('Fare Paid', '${trip['fare_paid']} DA'),
                    
                    if (trip['payment_method'] != null)
                      _buildDetailRow('Payment Method', trip['payment_method']),
                    
                    if (trip['distance'] > 0)
                      _buildDetailRow('Distance', '${trip['distance']} km'),
                    
                    if (trip['duration_minutes'] > 0)
                      _buildDetailRow('Duration', '${trip['duration_minutes']} minutes'),
                    
                    if (trip['rating'] != null)
                      _buildDetailRow('Rating', '${trip['rating']}/5'),
                    
                    if (trip['feedback'] != null && trip['feedback'].isNotEmpty)
                      _buildDetailRow('Feedback', trip['feedback']),
                    
                    if (trip['cancellation_reason'] != null)
                      _buildDetailRow('Cancellation Reason', trip['cancellation_reason']),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}