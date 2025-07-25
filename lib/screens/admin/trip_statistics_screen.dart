// lib/screens/admin/trip_statistics_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme_config.dart';
import '../../services/trip_service.dart';
import '../../widgets/common/app_layout.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../localization/app_localizations.dart';

class TripStatisticsScreen extends StatefulWidget {
  const TripStatisticsScreen({Key? key}) : super(key: key);

  @override
  State<TripStatisticsScreen> createState() => _TripStatisticsScreenState();
}

class _TripStatisticsScreenState extends State<TripStatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TripService _tripService = TripService();
  bool _isLoading = true;
  String _selectedPeriod = 'today';
  
  Map<String, dynamic> _overallStats = {};
  List<Map<String, dynamic>> _lineStats = [];
  List<Map<String, dynamic>> _hourlyStats = [];
  List<Map<String, dynamic>> _dailyStats = [];
  List<Map<String, dynamic>> _topRoutes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate loading statistics from API
      await Future.delayed(const Duration(seconds: 1));
      
      _overallStats = {
        'total_trips_today': 245,
        'total_trips_week': 1680,
        'total_trips_month': 7320,
        'total_passengers_today': 8950,
        'total_passengers_week': 62150,
        'total_passengers_month': 268400,
        'total_revenue_today': 1342500,
        'total_revenue_week': 9322500,
        'total_revenue_month': 40260000,
        'average_trip_duration': 32,
        'average_passengers_per_trip': 36,
        'on_time_percentage': 87,
        'cancelled_trips': 8,
        'delayed_trips': 31,
      };

      _lineStats = [
        {
          'line_id': '1',
          'line_name': 'Line 1 - City Center - Airport',
          'total_trips': 45,
          'completed_trips': 42,
          'cancelled_trips': 3,
          'total_passengers': 1680,
          'revenue': 252000,
          'on_time_percentage': 93,
          'average_delay': 3,
          'peak_utilization': 95,
          'off_peak_utilization': 67,
        },
        {
          'line_id': '2',
          'line_name': 'Line 2 - University - Shopping Mall',
          'total_trips': 38,
          'completed_trips': 36,
          'cancelled_trips': 2,
          'total_passengers': 1440,
          'revenue': 172800,
          'on_time_percentage': 89,
          'average_delay': 4,
          'peak_utilization': 88,
          'off_peak_utilization': 52,
        },
        {
          'line_id': '4',
          'line_name': 'Line 4 - Beach - Downtown',
          'total_trips': 28,
          'completed_trips': 27,
          'cancelled_trips': 1,
          'total_passengers': 756,
          'revenue': 75600,
          'on_time_percentage': 96,
          'average_delay': 2,
          'peak_utilization': 72,
          'off_peak_utilization': 45,
        },
        {
          'line_id': '5',
          'line_name': 'Line 5 - Hospital - Train Station',
          'total_trips': 35,
          'completed_trips': 33,
          'cancelled_trips': 2,
          'total_passengers': 1254,
          'revenue': 163020,
          'on_time_percentage': 85,
          'average_delay': 6,
          'peak_utilization': 91,
          'off_peak_utilization': 58,
        },
      ];

      _hourlyStats = [
        {'hour': 6, 'trips': 8, 'passengers': 180},
        {'hour': 7, 'trips': 15, 'passengers': 420},
        {'hour': 8, 'trips': 22, 'passengers': 680},
        {'hour': 9, 'trips': 18, 'passengers': 520},
        {'hour': 10, 'trips': 12, 'passengers': 340},
        {'hour': 11, 'trips': 14, 'passengers': 380},
        {'hour': 12, 'trips': 16, 'passengers': 450},
        {'hour': 13, 'trips': 18, 'passengers': 510},
        {'hour': 14, 'trips': 15, 'passengers': 420},
        {'hour': 15, 'trips': 19, 'passengers': 560},
        {'hour': 16, 'trips': 21, 'passengers': 630},
        {'hour': 17, 'trips': 25, 'passengers': 750},
        {'hour': 18, 'trips': 24, 'passengers': 720},
        {'hour': 19, 'trips': 18, 'passengers': 540},
        {'hour': 20, 'trips': 12, 'passengers': 360},
        {'hour': 21, 'trips': 8, 'passengers': 240},
      ];

      _dailyStats = [
        {'day': 'Mon', 'trips': 235, 'passengers': 8420, 'revenue': 1263000},
        {'day': 'Tue', 'trips': 242, 'passengers': 8690, 'revenue': 1303500},
        {'day': 'Wed', 'trips': 238, 'passengers': 8550, 'revenue': 1282500},
        {'day': 'Thu', 'trips': 245, 'passengers': 8950, 'revenue': 1342500},
        {'day': 'Fri', 'trips': 251, 'passengers': 9180, 'revenue': 1377000},
        {'day': 'Sat', 'trips': 218, 'passengers': 7820, 'revenue': 1173000},
        {'day': 'Sun', 'trips': 196, 'passengers': 7040, 'revenue': 1056000},
      ];

      _topRoutes = [
        {
          'route': 'City Center → Airport Terminal 1',
          'trips': 28,
          'passengers': 1120,
          'revenue': 168000,
          'utilization': 95,
        },
        {
          'route': 'University → Shopping Mall',
          'trips': 24,
          'passengers': 960,
          'revenue': 115200,
          'utilization': 88,
        },
        {
          'route': 'Hospital → Train Station',
          'trips': 22,
          'passengers': 836,
          'revenue': 108680,
          'utilization': 91,
        },
        {
          'route': 'Beach → Downtown Plaza',
          'trips': 18,
          'passengers': 504,
          'revenue': 50400,
          'utilization': 72,
        },
        {
          'route': 'Airport Terminal 1 → City Center',
          'trips': 26,
          'passengers': 1040,
          'revenue': 156000,
          'utilization': 92,
        },
      ];

    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AppLayout(
      title: 'Trip Statistics',
      child: Column(
        children: [
          // Period selector
          _buildPeriodSelector(),
          
          // Overall stats overview
          _buildOverallStats(),
          
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
              tabs: const [
                Tab(text: 'Charts'),
                Tab(text: 'Lines'),
                Tab(text: 'Routes'),
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
                      _buildChartsTab(),
                      _buildLinesTab(),
                      _buildRoutesTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'Period:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12, height: 40),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPeriodChip('Today', 'today'),
                  const SizedBox(width: 8, height: 40),
                  _buildPeriodChip('This Week', 'week'),
                  const SizedBox(width: 8, height: 40),
                  _buildPeriodChip('This Month', 'month'),
                  const SizedBox(width: 8, height: 40),
                  _buildPeriodChip('Custom', 'custom'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
        });
        if (value == 'custom') {
          _showCustomPeriodDialog();
        } else {
          _loadStatistics();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildOverallStats() {
    String periodSuffix = '';
    switch (_selectedPeriod) {
      case 'today':
        periodSuffix = '_today';
        break;
      case 'week':
        periodSuffix = '_week';
        break;
      case 'month':
        periodSuffix = '_month';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Trips',
                  '${_overallStats['total_trips$periodSuffix']}',
                  Icons.trip_origin,
                  Theme.of(context).colorScheme.primary,
                  '${_overallStats['cancelled_trips']} cancelled',
                ),
              ),
              const SizedBox(width: 12, height: 40),
              Expanded(
                child: _buildStatCard(
                  'Passengers',
                  '${_overallStats['total_passengers$periodSuffix']}',
                  Icons.people,
                  Theme.of(context).colorScheme.primary,
                  '${_overallStats['average_passengers_per_trip']} avg/trip',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Revenue',
                  '${(_overallStats['total_revenue$periodSuffix'] / 1000).toInt()}K DA',
                  Icons.monetization_on,
                  Theme.of(context).colorScheme.primary,
                  '${_overallStats['on_time_percentage']}% on-time',
                ),
              ),
              const SizedBox(width: 12, height: 40),
              Expanded(
                child: _buildStatCard(
                  'Avg Duration',
                  '${_overallStats['average_trip_duration']} min',
                  Icons.schedule,
                  Theme.of(context).colorScheme.primary,
                  '${_overallStats['delayed_trips']} delayed',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return CustomCard(type: CardType.elevated, 
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.trending_up, color: color, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hourly distribution chart
          _buildChartSection(
            'Hourly Distribution',
            _buildHourlyChart(),
          ),
          const SizedBox(height: 16),
          
          // Daily performance chart
          _buildChartSection(
            'Weekly Performance',
            _buildDailyChart(),
          ),
          const SizedBox(height: 16),
          
          // Line performance pie chart
          _buildChartSection(
            'Line Performance Distribution',
            _buildLinePerformancePieChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(String title, Widget chart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomCard(type: CardType.elevated, 
          child: chart,
        ),
      ],
    );
  }

  Widget _buildHourlyChart() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final hour = value.toInt();
                  if (hour % 2 == 0) {
                    return Text(
                      '${hour}h',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _hourlyStats.map((stat) {
                return FlSpot(
                  (stat['hour'] as int).toDouble(),
                  (stat['trips'] as int).toDouble(),
                );
              }).toList(),
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChart() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < _dailyStats.length) {
                    return Text(
                      _dailyStats[value.toInt()]['day'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),  
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: _dailyStats.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: (entry.value['trips'] as int).toDouble(),
                  color: Theme.of(context).colorScheme.primary,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLinePerformancePieChart() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sections: _lineStats.asMap().entries.map((entry) {
                  final colors = [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary];
                  final color = colors[entry.key % colors.length];
                  
                  return PieChartSectionData(
                    value: (entry.value['total_passengers'] as int).toDouble(),
                    color: color,
                    title: '${((entry.value['total_passengers'] as int) / _lineStats.fold<int>(0, (sum, line) => sum + (line['total_passengers'] as int)) * 100).toInt()}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(width: 16, height: 40),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _lineStats.asMap().entries.map((entry) {
                final colors = [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary];
                final color = colors[entry.key % colors.length];
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
        
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8, height: 40),
                      Expanded(
                        child: Text(
                          'Line ${entry.value['line_id']}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lineStats.length,
      itemBuilder: (context, index) {
        final line = _lineStats[index];
        return _buildLineStatsCard(line);
      },
    );
  }

  Widget _buildLineStatsCard(Map<String, dynamic> line) {
    final completionRate = (line['completed_trips'] / line['total_trips'] * 100).toInt();
    
    return CustomCard(type: CardType.elevated, 
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.route, color: Theme.of(context).colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12, height: 40),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Line ${line['line_id']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        line['line_name'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  '$completionRate%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: completionRate >= 90 ? Theme.of(context).colorScheme.primary : 
                           completionRate >= 80 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Stats grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2,
              children: [
                _buildLineStatItem('Trips', '${line['completed_trips']}/${line['total_trips']}', Icons.trip_origin),
                _buildLineStatItem('Passengers', '${line['total_passengers']}', Icons.people),
                _buildLineStatItem('Revenue', '${(line['revenue'] / 1000).toInt()}K DA', Icons.monetization_on),
                _buildLineStatItem('On-Time', '${line['on_time_percentage']}%', Icons.schedule),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Utilization bars
            Text(
              'Utilization',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildUtilizationBar('Peak', line['peak_utilization'], Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 12, height: 40),
                Expanded(
                  child: _buildUtilizationBar('Off-Peak', line['off_peak_utilization'], Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilizationBar(String label, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoutesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _topRoutes.length,
      itemBuilder: (context, index) {
        final route = _topRoutes[index];
        return _buildRouteCard(route, index + 1);
      },
    );
  }

  Widget _buildRouteCard(Map<String, dynamic> route, int rank) {
    return CustomCard(type: CardType.elevated, 
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank indicator
            Container(
              width: 32,
        
              decoration: BoxDecoration(
                color: rank <= 3 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16, height: 40),
            
            // Route info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route['route'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildRouteStatChip(Icons.trip_origin, '${route['trips']} trips'),
                      const SizedBox(width: 8, height: 40),
                      _buildRouteStatChip(Icons.people, '${route['passengers']}'),
                      const SizedBox(width: 8, height: 40),
                      _buildRouteStatChip(Icons.monetization_on, '${(route['revenue'] / 1000).toInt()}K DA'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Utilization: ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${route['utilization']}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: route['utilization'] >= 90 ? Theme.of(context).colorScheme.primary :
                                 route['utilization'] >= 70 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 2, height: 40),
          Text(
            text,
            style: TextStyle(
              fontSize: 9,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomPeriodDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Custom period selection - to be implemented')),
    );
  }
}