// lib/screens/admin/anomaly_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/widgets.dart';

/// Anomaly management screen for admins to monitor and manage system anomalies
class AnomalyManagementScreen extends StatefulWidget {
  const AnomalyManagementScreen({super.key});

  @override
  State<AnomalyManagementScreen> createState() => _AnomalyManagementScreenState();
}

class _AnomalyManagementScreenState extends State<AnomalyManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  List<Map<String, dynamic>> _allAnomalies = [];
  List<Map<String, dynamic>> _criticalAnomalies = [];
  List<Map<String, dynamic>> _resolvedAnomalies = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnomalies();
  }

  Future<void> _loadAnomalies() async {
    setState(() => _isLoading = true);
    try {
      final adminProvider = context.read<AdminProvider>();
      await adminProvider.loadAnomalies();
      setState(() {
        _allAnomalies = adminProvider.allAnomalies;
        _criticalAnomalies = adminProvider.criticalAnomalies;
        _resolvedAnomalies = adminProvider.resolvedAnomalies;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load anomalies: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Anomaly Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadAnomalies,
        ),
      ],
      child: Column(
        children: [
          // Statistics
          Container(
            padding: const EdgeInsets.all(DesignSystem.space16),
            child: StatsSection(
              crossAxisCount: 3,
              stats: [
                StatItem(
                  value: '${_allAnomalies.length}',
                  label: 'Total\\nAnomalies',
                  icon: Icons.warning,
                  color: context.warningColor,
                ),
                StatItem(
                  value: '${_criticalAnomalies.length}',
                  label: 'Critical\\nIssues',
                  icon: Icons.error,
                  color: context.colors.error,
                ),
                StatItem(
                  value: '${_resolvedAnomalies.length}',
                  label: 'Resolved\\nIssues',
                  icon: Icons.check_circle,
                  color: context.successColor,
                ),
              ],
            ),
          ),
          
          // Tab Bar
          AppTabBar(
            controller: _tabController,
            tabs: [
              AppTab(
                label: 'All (${_allAnomalies.length})',
                icon: Icons.warning,
              ),
              AppTab(
                label: 'Critical (${_criticalAnomalies.length})',
                icon: Icons.error,
              ),
              AppTab(
                label: 'Resolved (${_resolvedAnomalies.length})',
                icon: Icons.check_circle,
              ),
            ],
          ),
          
          // Tab Content
          Expanded(
            child: _isLoading
                ? const LoadingState.fullScreen()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAnomaliesList(_allAnomalies),
                      _buildAnomaliesList(_criticalAnomalies),
                      _buildAnomaliesList(_resolvedAnomalies),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnomaliesList(List<Map<String, dynamic>> anomalies) {
    if (anomalies.isEmpty) {
      return const EmptyState(
        title: 'No anomalies found',
        message: 'No anomalies in this category',
        icon: Icons.check_circle_outline,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(DesignSystem.space16),
      itemCount: anomalies.length,
      itemBuilder: (context, index) {
        final anomaly = anomalies[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: DesignSystem.space12),
          child: _buildAnomalyCard(anomaly),
        );
      },
    );
  }

  Widget _buildAnomalyCard(Map<String, dynamic> anomaly) {
    final severity = anomaly['severity'] ?? 'medium';
    final severityColor = _getSeverityColor(severity);
    final severityIcon = _getSeverityIcon(severity);

    return AppCard(
      onTap: () => _showAnomalyDetails(anomaly),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  severityIcon,
                  color: severityColor,
                  size: 20,
                ),
                const SizedBox(width: DesignSystem.space8),
                Expanded(
                  child: Text(
                    anomaly['title'] ?? 'Unknown Anomaly',
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StatusBadge(
                  status: severity.toUpperCase(),
                  color: _getSeverityBadgeStatusColor(severity),
                ),
              ],
            ),
            
            const SizedBox(height: DesignSystem.space8),
            
            Text(
              anomaly['description'] ?? 'No description',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: DesignSystem.space8),
            
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: DesignSystem.space4),
                Text(
                  _formatTime(anomaly['detected_at']),
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: DesignSystem.space16),
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: DesignSystem.space4),
                Expanded(
                  child: Text(
                    anomaly['location'] ?? 'Unknown location',
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return context.colors.error;
      case 'high':
        return context.warningColor;
      case 'medium':
        return context.infoColor;
      case 'low':
        return context.successColor;
      default:
        return context.colors.primary;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.error;
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      case 'low':
        return Icons.notification_important;
      default:
        return Icons.help;
    }
  }

  Color _getSeverityBadgeStatusColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return DesignSystem.error;
      case 'high':
        return DesignSystem.warning;
      case 'medium':
        return DesignSystem.info;
      case 'low':
        return DesignSystem.busActive;
      default:
        return DesignSystem.busInactive;
    }
  }

  String _formatTime(dynamic time) {
    if (time == null) return 'Unknown';
    try {
      final dateTime = time is String ? DateTime.parse(time) : time as DateTime;
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      return '${difference.inDays}d ago';
    } catch (e) {
      return 'Invalid time';
    }
  }

  void _showAnomalyDetails(Map<String, dynamic> anomaly) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              Text(
                'Anomaly Details',
                style: context.textStyles.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: DesignSystem.space16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Title', anomaly['title'] ?? 'Unknown'),
                      _buildDetailRow('Severity', anomaly['severity'] ?? 'Unknown'),
                      _buildDetailRow('Status', anomaly['status'] ?? 'Open'),
                      _buildDetailRow('Location', anomaly['location'] ?? 'Unknown'),
                      _buildDetailRow('Detected At', _formatTime(anomaly['detected_at'])),
                      _buildDetailRow('Description', anomaly['description'] ?? 'No description'),
                      if (anomaly['resolution'] != null)
                        _buildDetailRow('Resolution', anomaly['resolution']),
                    ],
                  ),
                ),
              ),
              if (anomaly['status'] != 'resolved') ...[
                const SizedBox(height: DesignSystem.space16),
                AppButton(
                  text: 'Mark as Resolved',
                  onPressed: () => _resolveAnomaly(anomaly),
                  icon: Icons.check,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignSystem.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.textStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _resolveAnomaly(Map<String, dynamic> anomaly) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Anomaly ${anomaly['title']} marked as resolved'),
        backgroundColor: context.successColor,
      ),
    );
    _loadAnomalies();
  }
}