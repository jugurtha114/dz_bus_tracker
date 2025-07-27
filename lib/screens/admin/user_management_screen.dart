// lib/screens/admin/user_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/widgets.dart';
import '../../models/user_model.dart';

/// Comprehensive user management screen for admins to manage all system users
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'all';
  
  List<User> _allUsers = [];
  List<User> _passengers = [];
  List<User> _drivers = [];
  List<User> _admins = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final adminProvider = context.read<AdminProvider>();
      await adminProvider.loadAllUsers();
      
      setState(() {
        _allUsers = adminProvider.allUsers;
        _passengers = adminProvider.passengerUsers;
        _drivers = adminProvider.driverUsers;
        _admins = adminProvider.adminUsers;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load users: $error')),
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
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'User Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.person_add),
          onPressed: _showAddUserDialog,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadUsers,
        ),
      ],
      child: Column(
        children: [
          // User Statistics Header
          _buildUserStatistics(),
          
          // Search and Filter Bar
          _buildSearchAndFilter(),
          
          // Tab Bar
          AppTabBar(
            controller: _tabController,
            tabs: [
              AppTab(
                label: 'All (${_allUsers.length})',
                icon: Icons.people,
              ),
              AppTab(
                label: 'Passengers (${_passengers.length})',
                icon: Icons.person,
              ),
              AppTab(
                label: 'Drivers (${_drivers.length})',
                icon: Icons.drive_eta,
              ),
              AppTab(
                label: 'Admins (${_admins.length})',
                icon: Icons.admin_panel_settings,
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
                      _buildUsersList(_getFilteredUsers(_allUsers)),
                      _buildUsersList(_getFilteredUsers(_passengers)),
                      _buildUsersList(_getFilteredUsers(_drivers)),
                      _buildUsersList(_getFilteredUsers(_admins)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatistics() {
    final activeUsers = _allUsers.where((u) => u.isActive).length;
    final inactiveUsers = _allUsers.length - activeUsers;

    return Container(
      padding: const EdgeInsets.all(DesignSystem.space16),
      child: StatsSection(
        title: 'User Overview',
        crossAxisCount: 2,
        stats: [
          StatItem(
            value: '${_allUsers.length}',
            label: 'Total\\nUsers',
            icon: Icons.people,
            color: context.colors.primary,
          ),
          StatItem(
            value: '$activeUsers',
            label: 'Active\\nUsers',
            icon: Icons.check_circle,
            color: context.successColor,
          ),
          StatItem(
            value: '$inactiveUsers',
            label: 'Inactive\\nUsers',
            icon: Icons.block,
            ),
          StatItem(
            value: '${_drivers.length}',
            label: 'Active\\nDrivers',
            icon: Icons.drive_eta,
            color: context.infoColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space16),
      child: Row(
        children: [
          Expanded(
            child: AppInput(
              hint: 'Search users by name or email...',
              prefixIcon: Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: DesignSystem.space8),
          AppButton.text(
            text: 'Filter',
            onPressed: _showFilterDialog,
            icon: Icons.filter_list,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(List<User> users) {
    if (users.isEmpty) {
      return EmptyState(
        title: 'No users found',
        message: _searchQuery.isNotEmpty 
            ? 'No users match your search criteria'
            : 'No users in this category',
        icon: Icons.people_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(DesignSystem.space16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: DesignSystem.space12),
            child: _buildUserCard(user),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(User user) {
    final userTypeColor = _getUserTypeColor(user.userType);
    final userTypeIcon = _getUserTypeIcon(user.userType);

    return AppCard(
      onTap: () => _showUserDetails(user),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Row(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 25,
              backgroundColor: userTypeColor.withValues(alpha: 0.1),
              backgroundImage: user.profileImageUrl != null
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null
                  ? Icon(
                      userTypeIcon,
                      color: userTypeColor,
                      size: 24,
                    )
                  : null,
            ),
            
            const SizedBox(width: DesignSystem.space12),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name ?? 'Unknown User',
                          style: context.textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      StatusBadge(
                        status: user.isActive ? 'ACTIVE' : 'INACTIVE',
                        color: user.isActive ? DesignSystem.success : DesignSystem.error,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: DesignSystem.space4),
                  
                  Text(
                    user.email ?? 'No email',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  
                  const SizedBox(height: DesignSystem.space4),
                  
                  Row(
                    children: [
                      Icon(
                        userTypeIcon,
                        size: 16,
                        color: userTypeColor,
                      ),
                      const SizedBox(width: DesignSystem.space4),
                      Text(
                        _getUserTypeLabel(user.userType),
                        style: context.textStyles.bodySmall?.copyWith(
                          color: userTypeColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: DesignSystem.space16),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: DesignSystem.space4),
                      Text(
                        'Joined ${_formatJoinDate(user.createdAt)}',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions Menu
            PopupMenuButton<String>(
              onSelected: (value) => _handleUserAction(value, user),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit User'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: user.isActive ? 'deactivate' : 'activate',
                  child: Row(
                    children: [
                      Icon(user.isActive ? Icons.block : Icons.check_circle),
                      const SizedBox(width: 8),
                      Text(user.isActive ? 'Deactivate' : 'Activate'),
                    ],
                  ),
                ),
                if (user.userType == UserType.driver) ...[
                  const PopupMenuItem(
                    value: 'view_performance',
                    child: Row(
                      children: [
                        Icon(Icons.analytics),
                        SizedBox(width: 8),
                        Text('View Performance'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'assign_bus',
                    child: Row(
                      children: [
                        Icon(Icons.directions_bus),
                        SizedBox(width: 8),
                        Text('Assign Bus'),
                      ],
                    ),
                  ),
                ],
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete User', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  List<User> _getFilteredUsers(List<User> users) {
    if (_searchQuery.isEmpty) return users;
    
    final query = _searchQuery.toLowerCase();
    return users.where((user) {
      final name = user.name?.toLowerCase() ?? '';
      final email = user.email?.toLowerCase() ?? '';
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  Color _getUserTypeColor(UserType? userType) {
    switch (userType) {
      case UserType.driver:
        return context.successColor;
      case UserType.admin:
        return context.colors.error;
      case UserType.passenger:
      default:
        return context.colors.primary;
    }
  }

  IconData _getUserTypeIcon(UserType? userType) {
    switch (userType) {
      case UserType.driver:
        return Icons.drive_eta;
      case UserType.admin:
        return Icons.admin_panel_settings;
      case UserType.passenger:
      default:
        return Icons.person;
    }
  }

  String _getUserTypeLabel(UserType? userType) {
    switch (userType) {
      case UserType.driver:
        return 'Driver';
      case UserType.admin:
        return 'Admin';
      case UserType.passenger:
      default:
        return 'Passenger';
    }
  }

  String _formatJoinDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) return 'today';
    if (difference.inDays < 30) return '${difference.inDays}d ago';
    if (difference.inDays < 365) return '${(difference.inDays / 30).round()}m ago';
    return '${(difference.inDays / 365).round()}y ago';
  }

  // Action handlers
  void _handleUserAction(String action, User user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'activate':
      case 'deactivate':
        _toggleUserStatus(user);
        break;
      case 'view_performance':
        _viewDriverPerformance(user);
        break;
      case 'assign_bus':
        _assignBusToDriver(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _showUserDetails(User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              Text(
                'User Details',
                style: context.textStyles.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: DesignSystem.space16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      _buildUserDetailsSection(user),
                      const SizedBox(height: DesignSystem.space16),
                      _buildUserStatsSection(user),
                      if (user.userType == UserType.driver) ...[
                        const SizedBox(height: DesignSystem.space16),
                        _buildDriverSpecificSection(user),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetailsSection(User user) {
    return SectionLayout(
      title: 'Personal Information',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              _buildDetailRow('Full Name', user.name ?? 'Not provided'),
              _buildDetailRow('Email', user.email ?? 'Not provided'),
              _buildDetailRow('Phone', user.phoneNumber ?? 'Not provided'),
              _buildDetailRow('User Type', _getUserTypeLabel(user.userType)),
              _buildDetailRow('Status', user.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow('Joined', _formatJoinDate(user.createdAt)),
              _buildDetailRow('Last Login', user.lastLoginAt != null 
                  ? _formatJoinDate(user.lastLoginAt) 
                  : 'Never'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserStatsSection(User user) {
    return SectionLayout(
      title: 'User Statistics',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              _buildDetailRow('Total Trips', '${user.totalTrips ?? 0}'),
              _buildDetailRow('Rating', user.rating != null 
                  ? '${user.rating!.toStringAsFixed(1)} ⭐'
                  : 'Not rated'),
              if (user.userType == UserType.passenger) ...[
                _buildDetailRow('Total Spent', '\$${user.totalSpent?.toStringAsFixed(2) ?? '0.00'}'),
                _buildDetailRow('Favorite Route', user.favoriteRoute ?? 'None'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverSpecificSection(User user) {
    return SectionLayout(
      title: 'Driver Information',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              _buildDetailRow('License Number', user.licenseNumber ?? 'Not provided'),
              _buildDetailRow('License Expiry', user.licenseExpiry != null 
                  ? _formatJoinDate(user.licenseExpiry) 
                  : 'Not provided'),
              _buildDetailRow('Assigned Bus', user.assignedBusPlate ?? 'Not assigned'),
              _buildDetailRow('Years Experience', '${user.yearsExperience ?? 0} years'),
              _buildDetailRow('Total Distance', '${user.totalDistanceDriven ?? 0} km'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignSystem.space4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  // Dialog methods
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Users',
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DesignSystem.space16),
            // Filter options would be implemented here
            AppButton(
              text: 'Apply Filters',
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add user form coming soon')),
    );
  }

  void _showEditUserDialog(User user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit user form for ${user.name} coming soon')),
    );
  }

  void _toggleUserStatus(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.isActive ? 'Deactivate User' : 'Activate User'),
        content: Text(
          'Are you sure you want to ${user.isActive ? 'deactivate' : 'activate'} ${user.name}?'
        ),
        actions: [
          AppButton.text(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            text: user.isActive ? 'Deactivate' : 'Activate',
            onPressed: () {
              Navigator.of(context).pop();
              _processUserStatusToggle(user);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _processUserStatusToggle(User user) async {
    try {
      final adminProvider = context.read<AdminProvider>();
      await adminProvider.toggleUserStatus(user.id!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User ${user.isActive ? 'deactivated' : 'activated'} successfully'),
          backgroundColor: context.successColor,
        ),
      );
      
      _loadUsers();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user status: $error')),
      );
    }
  }

  void _viewDriverPerformance(User user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Driver performance for ${user.name} coming soon')),
    );
  }

  void _assignBusToDriver(User user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bus assignment for ${user.name} coming soon')),
    );
  }

  void _deleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${user.name}? This action cannot be undone.'
        ),
        actions: [
          AppButton.text(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            text: 'Delete',
            onPressed: () {
              Navigator.of(context).pop();
              _processUserDeletion(user);
            },
            ),
        ],
      ),
    );
  }

  Future<void> _processUserDeletion(User user) async {
    try {
      final adminProvider = context.read<AdminProvider>();
      await adminProvider.deleteUser(user.id!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} deleted successfully'),
          backgroundColor: context.colors.error,
        ),
      );
      
      _loadUsers();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user: $error')),
      );
    }
  }
}