// lib/screens/admin/user_management_screen.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../core/utils/date_utils.dart';
import '../../services/user_service.dart';
import '../../widgets/common/app_layout.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../localization/app_localizations.dart';
import '../../helpers/dialog_helper.dart';
import '../../widgets/common/custom_card.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserService _userService = UserService();
  bool _isLoading = true;
  String _searchQuery = '';
  
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _passengers = [];
  List<Map<String, dynamic>> _drivers = [];
  List<Map<String, dynamic>> _admins = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate loading users from API
      await Future.delayed(const Duration(seconds: 1));
      
      _allUsers = [
        {
          'id': '1',
          'email': 'ahmed.ben@email.com',
          'first_name': 'Ahmed',
          'last_name': 'Ben Ali',
          'user_type': 'passenger',
          'is_active': true,
          'date_joined': '2024-01-15T10:30:00Z',
          'phone_number': '+213 555 123 456',
        },
        {
          'id': '2',
          'email': 'fatima.driver@email.com',
          'first_name': 'Fatima',
          'last_name': 'Zohra',
          'user_type': 'driver',
          'is_active': true,
          'date_joined': '2024-02-20T14:15:00Z',
          'phone_number': '+213 555 789 012',
        },
        {
          'id': '3',
          'email': 'admin@dzbus.com',
          'first_name': 'System',
          'last_name': 'Admin',
          'user_type': 'admin',
          'is_active': true,
          'date_joined': '2024-01-01T00:00:00Z',
          'phone_number': '+213 555 000 000',
        },
        // Add more sample data...
      ];

      _categorizeUsers();
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _categorizeUsers() {
    _passengers = _allUsers.where((u) => u['user_type'] == 'passenger').toList();
    _drivers = _allUsers.where((u) => u['user_type'] == 'driver').toList();
    _admins = _allUsers.where((u) => u['user_type'] == 'admin').toList();
  }

  List<Map<String, dynamic>> _getFilteredUsers(List<Map<String, dynamic>> users) {
    if (_searchQuery.isEmpty) return users;
    
    return users.where((user) {
      final fullName = '${user['first_name']} ${user['last_name']}'.toLowerCase();
      final email = user['email'].toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return fullName.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AppLayout(
      title: 'User Management',
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
              tabs: [
                _buildTabWithBadge('All', _allUsers.length),
                _buildTabWithBadge('Passengers', _passengers.length),
                _buildTabWithBadge('Drivers', _drivers.length),
                _buildTabWithBadge('Admins', _admins.length),
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

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12, height: 40),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _showAddUserDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Users',
              '${_allUsers.length}',
              Icons.people,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Active',
              '${_allUsers.where((u) => u['is_active'] == true).length}',
              Icons.check_circle,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Inactive',
              '${_allUsers.where((u) => u['is_active'] == false).length}',
              Icons.block,
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
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

  Widget _buildUsersList(List<Map<String, dynamic>> users) {
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(),
            Text('No users found'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isActive = user['is_active'] == true;
    final userType = user['user_type'] ?? 'passenger';
    final joinDate = DateTime.tryParse(user['date_joined'] ?? '');

    Color typeColor;
    IconData typeIcon;
    
    switch (userType) {
      case 'driver':
        typeColor = Theme.of(context).colorScheme.primary;
        typeIcon = Icons.drive_eta;
        break;
      case 'admin':
        typeColor = Theme.of(context).colorScheme.primary;
        typeIcon = Icons.admin_panel_settings;
        break;
      default:
        typeColor = Theme.of(context).colorScheme.primary;
        typeIcon = Icons.person;
    }

    return CustomCard(type: CardType.elevated, 
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showUserDetails(user),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: typeColor.withValues(alpha: 0),
                child: Icon(typeIcon, color: typeColor),
              ),
              const SizedBox(width: 16, height: 40),
              
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${user['first_name']} ${user['last_name']}'.trim(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isActive ? 'Active' : 'Inactive',
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
                      user['email'] ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 4, height: 40),
                        Text(
                          joinDate != null 
                              ? 'Joined ${DzDateUtils.formatDate(joinDate)}'
                              : 'Join date unknown',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
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
                    value: isActive ? 'deactivate' : 'activate',
                    child: Row(
                      children: [
                        Icon(isActive ? Icons.block : Icons.check_circle),
                        const SizedBox(width: 8, height: 40),
                        Text(isActive ? 'Deactivate' : 'Activate'),
                      ],
                    ),
                  ),
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
      ),
    );
  }

  void _handleUserAction(String action, Map<String, dynamic> user) {
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
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
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
                      'User Details',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDetailRow('Name', '${user['first_name']} ${user['last_name']}'),
                    _buildDetailRow('Email', user['email'] ?? ''),
                    _buildDetailRow('Phone', user['phone_number'] ?? 'Not provided'),
                    _buildDetailRow('User Type', user['user_type'] ?? ''),
                    _buildDetailRow('Status', user['is_active'] == true ? 'Active' : 'Inactive'),
                    _buildDetailRow('Join Date', 
                      DateTime.tryParse(user['date_joined'] ?? '') != null
                          ? DzDateUtils.formatDateTime(DateTime.parse(user['date_joined']))
                          : 'Unknown'
                    ),
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
            width: 100,
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

  void _showAddUserDialog() {
    // TODO: Implement add user dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add user functionality - to be implemented')),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    // TODO: Implement edit user dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit user functionality - to be implemented')),
    );
  }

  void _toggleUserStatus(Map<String, dynamic> user) {
    final isActive = user['is_active'] == true;
    
    DialogHelper.showConfirmDialog(
      context,
      title: isActive ? 'Deactivate User' : 'Activate User',
      message: 'Are you sure you want to ${isActive ? 'deactivate' : 'activate'} this user?',
      confirmText: isActive ? 'Deactivate' : 'Activate',
      cancelText: 'Cancel',
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          user['is_active'] = !isActive;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User ${isActive ? 'deactivated' : 'activated'} successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    });
  }

  void _deleteUser(Map<String, dynamic> user) {
    DialogHelper.showConfirmDialog(
      context,
      title: 'Delete User',
      message: 'Are you sure you want to delete this user? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          _allUsers.remove(user);
          _categorizeUsers();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
}