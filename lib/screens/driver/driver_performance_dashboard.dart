// lib/screens/driver/driver_performance_dashboard.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme_config.dart';
import '../../core/utils/date_utils.dart';
import '../../services/driver_performance_service.dart';
import '../../widgets/widgets.dart';
import '../../localization/app_localizations.dart';

class DriverPerformanceDashboard extends StatefulWidget {
  const DriverPerformanceDashboard({Key? key}) : super(key: key);

  @override
  State<DriverPerformanceDashboard> createState() => _DriverPerformanceDashboardState();
}

class _DriverPerformanceDashboardState extends State<DriverPerformanceDashboard> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DriverPerformanceService _performanceService = DriverPerformanceService();
  
  bool _isLoading = true;
  String _selectedPeriod = 'week';
  Map<String, dynamic> _performanceData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPerformanceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPerformanceData() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await _performanceService.getPerformanceData(period: _selectedPeriod);
      setState(() {
        _performanceData = data;
      });
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

    return PageLayout(
      title: 'Performance Dashboard',
      showAppBar: true,
      appBarActions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (period) {
            setState(() {
              _selectedPeriod = period;
            });
            _loadPerformanceData();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'today', child: Text('Today')),
            const PopupMenuItem(value: 'week', child: Text('This Week')),
            const PopupMenuItem(value: 'month', child: Text('This Month')),
            const PopupMenuItem(value: 'year', child: Text('This Year')),
          ],
        ),
      ],
      body: _isLoading
          ? const LoadingState.fullScreen(message: 'Loading performance data...')
          : RefreshIndicator(
              onRefresh: _loadPerformanceData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Performance Score Overview
                    _buildPerformanceScore(),
                    const SizedBox(height: 16),
                    
                    // Key Metrics Grid
                    _buildKeyMetrics(),
                    const SizedBox(height: 16),
                    
                    // Tab Navigation
                    _buildTabNavigation(),
                    const SizedBox(height: 16),
                    
                    // Tab Content
                    SizedBox(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDrivingBehaviorTab(),
                          _buildEfficiencyTab(),
                          _buildSafetyScoreTab(),
                          _buildTrendsTab(),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Recent Achievements
                    _buildAchievements(),
                    const SizedBox(height: 16),
                    
                    // Improvement Suggestions
                    _buildImprovementSuggestions(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPerformanceScore() {
    final overallScore = _performanceData['overall_score']?.toDouble() ?? 85;
    final previousScore = _performanceData['previous_score']?.toDouble() ?? 82;
    final scoreDiff = overallScore - previousScore;
    
    return AppCard( 
      child: Column(
        children: [
          Text(
            'Overall Performance Score',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Score Circle
          SizedBox(
            width: 160,
        
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Circle
                CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 12,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                
                // Progress Circle
                CircularProgressIndicator(
                  value: overallScore / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(overallScore),
                  ),
                ),
                
                // Score Text
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${overallScore.toInt()}',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(overallScore),
                      ),
                    ),
                    Text(
                      'Score',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Score Change
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                scoreDiff >= 0 ? Icons.trending_up : Icons.trending_down,
                color: scoreDiff >= 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 4, height: 40),
              Text(
                '${scoreDiff >= 0 ? '+' : ''}${scoreDiff.toStringAsFixed(1)} from last $_selectedPeriod',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scoreDiff >= 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
    final metrics = _performanceData['metrics'] as Map<String, dynamic>? ?? {};
    
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Distance',
            '${metrics['total_distance'] ?? 245} km',
            Icons.straighten,
            Theme.of(context).colorScheme.primary,
          ),
        ),
        Expanded(
          child: _buildMetricCard(
            'Fuel Efficiency',
            '${metrics['fuel_efficiency'] ?? 12} L/100km',
            Icons.local_gas_station,
            Theme.of(context).colorScheme.primary,
          ),
        ),
        Expanded(
          child: _buildMetricCard(
            'On-Time Rate',
            '${metrics['on_time_rate'] ?? 92}%',
            Icons.schedule,
            Theme.of(context).colorScheme.primary,
          ),
        ),
        Expanded(
          child: _buildMetricCard(
            'Safety Score',
            '${metrics['safety_score'] ?? 95}/100',
            Icons.security,
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return AppCard( 
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
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

  Widget _buildTabNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.primary,
        labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        isScrollable: true,
        tabs: const [
          Tab(text: 'Driving'),
          Tab(text: 'Efficiency'),
          Tab(text: 'Safety'),
          Tab(text: 'Trends'),
        ],
      ),
    );
  }

  Widget _buildDrivingBehaviorTab() {
    final drivingData = _performanceData['driving_behavior'] as Map<String, dynamic>? ?? {};
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Speed Analysis Chart
          AppCard( 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Speed Analysis',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _generateSpeedData(),
                          isCurved: true,
                          color: Theme.of(context).colorScheme.primary,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Driving Behavior Metrics
          Row(
            children: [
              Expanded(
                child: _buildBehaviorMetric(
                  'Harsh Braking',
                  '${drivingData['harsh_braking'] ?? 3} events',
                  Icons.warning,
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              Expanded(
                child: _buildBehaviorMetric(
                  'Rapid Acceleration',
                  '${drivingData['rapid_acceleration'] ?? 2} events',
                  Icons.speed,
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBehaviorMetric(
                  'Smooth Turns',
                  '${drivingData['smooth_turns'] ?? 95}%',
                  Icons.turn_right,
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              Expanded(
                child: _buildBehaviorMetric(
                  'Idle Time',
                  '${drivingData['idle_time'] ?? 12} min',
                  Icons.pause_circle,
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyTab() {
    final efficiencyData = _performanceData['efficiency'] as Map<String, dynamic>? ?? {};
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Fuel Efficiency Chart
          AppCard( 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fuel Efficiency Trend',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: _generateEfficiencyBars(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Efficiency Metrics
          _buildEfficiencyMetrics(efficiencyData),
        ],
      ),
    );
  }

  Widget _buildSafetyScoreTab() {
    final safetyData = _performanceData['safety'] as Map<String, dynamic>? ?? {};
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Safety Score Breakdown
          AppCard( 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety Score Breakdown',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildSafetyIndicator('Speed Compliance', safetyData['speed_compliance'] ?? 95),
                _buildSafetyIndicator('Traffic Rules', safetyData['traffic_rules'] ?? 98),
                _buildSafetyIndicator('Defensive Driving', safetyData['defensive_driving'] ?? 87),
                _buildSafetyIndicator('Vehicle Handling', safetyData['vehicle_handling'] ?? 92),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Recent Safety Events
          _buildSafetyEvents(safetyData['recent_events'] as List<Map<String, dynamic>>? ?? []),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Performance Trend Chart
          AppCard( 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance Trends',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _generateTrendData(),
                          isCurved: true,
                          color: Theme.of(context).colorScheme.primary,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Trend Summary
          _buildTrendSummary(),
        ],
      ),
    );
  }

  Widget _buildBehaviorMetric(String title, String value, IconData icon, Color color) {
    return AppCard( 
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
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

  Widget _buildEfficiencyMetrics(Map<String, dynamic> data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Average Speed',
                '${data['avg_speed'] ?? 45} km/h',
                Icons.speed,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              child: _buildMetricCard(
                'Route Completion',
                '${data['route_completion'] ?? 98}%',
                Icons.route,
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Maintenance Score',
                '${data['maintenance_score'] ?? 87}/100',
                Icons.build,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              child: _buildMetricCard(
                'Eco Score',
                '${data['eco_score'] ?? 82}/100',
                Icons.eco,
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSafetyIndicator(String title, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '$score%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(score.toDouble()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Theme.of(context).colorScheme.primary,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getScoreColor(score.toDouble()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyEvents(List<Map<String, dynamic>> events) {
    if (events.isEmpty) {
      return AppCard( 
        child: Center(
          child: Column(
            children: [
              Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 48),
              const SizedBox(height: 16),
              Text(
                'No Safety Events',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Great job maintaining safe driving!',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AppCard( 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Safety Events',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...events.map((event) => _buildSafetyEventItem(event)),
        ],
      ),
    );
  }

  Widget _buildSafetyEventItem(Map<String, dynamic> event) {
    final severity = event['severity'] as String? ?? 'low';
    Color severityColor;
    IconData severityIcon;
    
    switch (severity) {
      case 'high':
        severityColor = Theme.of(context).colorScheme.primary;
        severityIcon = Icons.error;
        break;
      case 'medium':
        severityColor = Theme.of(context).colorScheme.primary;
        severityIcon = Icons.warning;
        break;
      default:
        severityColor = Theme.of(context).colorScheme.primary;
        severityIcon = Icons.info;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(severityIcon, color: severityColor, size: 20),
          const SizedBox(width: 12, height: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] ?? 'Safety Event',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  event['description'] ?? 'No description',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            DzDateUtils.getTimeAgo(
              DateTime.tryParse(event['timestamp'] ?? '') ?? DateTime.now(),
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildTrendCard(
            'This Week',
            '+2%',
            'Performance improved',
            Theme.of(context).colorScheme.primary,
            Icons.trending_up,
          ),
        ),
        Expanded(
          child: _buildTrendCard(
            'This Month',
            '+5%',
            'Significant improvement',
            Theme.of(context).colorScheme.primary,
            Icons.trending_up,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendCard(String period, String change, String description, Color color, IconData icon) {
    return AppCard( 
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(
            change,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            period,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = _performanceData['achievements'] as List<Map<String, dynamic>>? ?? [];
    
    return AppCard( 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Achievements',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (achievements.isEmpty)
            Center(
              child: Text(
                'No recent achievements',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          else
            ...achievements.map((achievement) => _buildAchievementItem(achievement)),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(Map<String, dynamic> achievement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.emoji_events, color: Theme.of(context).colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 12, height: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'] ?? 'Achievement',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  achievement['description'] ?? 'No description',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementSuggestions() {
    final suggestions = _performanceData['suggestions'] as List<Map<String, dynamic>>? ?? [];
    
    return AppCard( 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Improvement Suggestions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (suggestions.isEmpty)
            Center(
              child: Text(
                'No suggestions at this time',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          else
            ...suggestions.map((suggestion) => _buildSuggestionItem(suggestion)),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(Map<String, dynamic> suggestion) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 12, height: 40),
          Expanded(
            child: Text(
              suggestion['text'] ?? 'No suggestion text',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Theme.of(context).colorScheme.primary;
    if (score >= 70) return Theme.of(context).colorScheme.primary;
    return Theme.of(context).colorScheme.primary;
  }

  List<FlSpot> _generateSpeedData() {
    return [
      const FlSpot(0, 30),
      const FlSpot(1, 45),
      const FlSpot(2, 40),
      const FlSpot(3, 55),
      const FlSpot(4, 50),
      const FlSpot(5, 60),
      const FlSpot(6, 45),
    ];
  }

  List<BarChartGroupData> _generateEfficiencyBars() {
    return [
      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 12, color: Theme.of(context).colorScheme.primary)]),
      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 13, color: Theme.of(context).colorScheme.primary)]),
      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 11, color: Theme.of(context).colorScheme.primary)]),
      BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 12, color: Theme.of(context).colorScheme.primary)]),
      BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 12, color: Theme.of(context).colorScheme.primary)]),
    ];
  }

  List<FlSpot> _generateTrendData() {
    return [
      const FlSpot(0, 80),
      const FlSpot(1, 82),
      const FlSpot(2, 78),
      const FlSpot(3, 85),
      const FlSpot(4, 87),
      const FlSpot(5, 89),
      const FlSpot(6, 85),
    ];
  }
}