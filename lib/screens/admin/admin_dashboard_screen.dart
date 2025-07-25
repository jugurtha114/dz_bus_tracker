// lib/screens/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import '../../services/navigation_service.dart';
import '../../widgets/common/app_layout.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../localization/app_localizations.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _dashboardStats = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    // Simulate loading dashboard data
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _dashboardStats = {
        'total_users': 1250,
        'active_drivers': 85,
        'pending_drivers': 12,
        'total_buses': 145,
        'active_buses': 120,
        'total_lines': 28,
        'active_trips': 45,
        'daily_passengers': 3420,
        'monthly_revenue': 125000,
        'system_uptime': 99,
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);

    return AppLayout(
      title: localizations.translate('admin_dashboard'),
      showBackButton: false,
      currentIndex: 0,
      child: _isLoading
          ? const Center(child: LoadingIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section
                    _buildWelcomeSection(authProvider),
                    const SizedBox(height: 16),
                    
                    // Quick stats cards
                    _buildQuickStatsGrid(),
                    const SizedBox(height: 16),
                    
                    // Charts section
                    _buildChartsSection(),
                    const SizedBox(height: 16),
                    
                    // Management actions
                    _buildManagementActions(),
                    const SizedBox(height: 16),
                    
                    // Recent activities
                    _buildRecentActivities(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeSection(AuthProvider authProvider) {
    final user = authProvider.user;
    String adminName = user?.firstName ?? '';
    if (adminName.isEmpty) {
      adminName = user?.email?.split('@')[0] ?? 'Admin';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
            child: Icon(
              Icons.admin_panel_settings,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16, height: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $adminName',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'System running smoothly • ${_dashboardStats['system_uptime']}% uptime',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Users',
          '${_dashboardStats['total_users']}',
          Icons.people,
          Theme.of(context).colorScheme.primary,
          '+12% from last month',
        ),
        _buildStatCard(
          'Active Drivers',
          '${_dashboardStats['active_drivers']}',
          Icons.drive_eta,
          Theme.of(context).colorScheme.primary,
          '${_dashboardStats['pending_drivers']} pending',
        ),
        _buildStatCard(
          'Active Buses',
          '${_dashboardStats['active_buses']}/${_dashboardStats['total_buses']}',
          Icons.directions_bus,
          Theme.of(context).colorScheme.primary,
          '${_dashboardStats['active_trips']} trips running',
        ),
        _buildStatCard(
          'Daily Passengers',
          '${_dashboardStats['daily_passengers']}',
          Icons.person_outline,
          Theme.of(context).colorScheme.primary,
          'Updated 5 min ago',
        ),
      ],
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
              Icon(icon, color: color, size: 28),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.trending_up, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildUsageChart()),
            const SizedBox(width: 16, height: 40),
            Expanded(child: _buildRevenueChart()),
          ],
        ),
      ],
    );
  }

  Widget _buildUsageChart() {
    return CustomCard(type: CardType.elevated, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Usage',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 3),
                      FlSpot(1, 4),
                      FlSpot(2, 6),
                      FlSpot(3, 5),
                      FlSpot(4, 7),
                      FlSpot(5, 8),
                      FlSpot(6, 9),
                    ],
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
    );
  }

  Widget _buildRevenueChart() {
    return CustomCard(type: CardType.elevated, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Breakdown',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 40,
                    color: Theme.of(context).colorScheme.primary,
                    title: '40%',
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: 30,
                    color: Theme.of(context).colorScheme.primary,
                    title: '30%',
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: 20,
                    color: Theme.of(context).colorScheme.primary,
                    title: '20%',
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: 10,
                    color: Theme.of(context).colorScheme.primary,
                    title: '10%',
                    radius: 50,
                  ),
                ],
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
          children: [
            _buildActionCard(
              'User Management',
              Icons.people_outline,
              Theme.of(context).colorScheme.primary,
              () => NavigationService.navigateTo(AppRoutes.userManagement),
            ),
            _buildActionCard(
              'Driver Approvals',
              Icons.how_to_reg,
              Theme.of(context).colorScheme.primary,
              () => NavigationService.navigateTo(AppRoutes.driverApproval),
            ),
            _buildActionCard(
              'Line Management',
              Icons.route,
              Theme.of(context).colorScheme.primary,
              () => NavigationService.navigateTo(AppRoutes.lineManagement),
            ),
            _buildActionCard(
              'System Reports',
              Icons.analytics,
              Theme.of(context).colorScheme.primary,
              () => NavigationService.navigateTo(AppRoutes.anomalyManagement),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return CustomCard(type: CardType.elevated, 
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    final activities = [
      {'type': 'user_registered', 'message': 'New user registered', 'time': '2 min ago'},
      {'type': 'driver_approved', 'message': 'Driver Ahmed M. approved', 'time': '15 min ago'},
      {'type': 'bus_added', 'message': 'Bus DZ-123-AB added to line 5', 'time': '1 hour ago'},
      {'type': 'anomaly_detected', 'message': 'Traffic anomaly detected on Route 12', 'time': '2 hours ago'},
      {'type': 'maintenance', 'message': 'System maintenance completed', 'time': '3 hours ago'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomCard(type: CardType.elevated, 
          child: Column(
            children: activities.map((activity) {
              IconData activityIcon;
              Color activityColor;
              
              switch (activity['type']) {
                case 'user_registered':
                  activityIcon = Icons.person_add;
                  activityColor = Theme.of(context).colorScheme.primary;
                  break;
                case 'driver_approved':
                  activityIcon = Icons.check_circle;
                  activityColor = Theme.of(context).colorScheme.primary;
                  break;
                case 'bus_added':
                  activityIcon = Icons.directions_bus;
                  activityColor = Theme.of(context).colorScheme.primary;
                  break;
                case 'anomaly_detected':
                  activityIcon = Icons.warning;
                  activityColor = Theme.of(context).colorScheme.primary;
                  break;
                default:
                  activityIcon = Icons.info;
                  activityColor = Theme.of(context).colorScheme.primary;
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: activityColor.withValues(alpha: 0),
                  child: Icon(activityIcon, color: activityColor, size: 20),
                ),
                title: Text(
                  activity['message']!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Text(
                  activity['time']!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}