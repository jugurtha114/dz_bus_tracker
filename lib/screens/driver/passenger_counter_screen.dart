// lib/screens/driver/passenger_counter_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../providers/tracking_provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/driver_provider.dart';
import '../../widgets/widgets.dart';

/// Modern passenger counter screen for drivers to track bus occupancy
class PassengerCounterScreen extends StatefulWidget {
  const PassengerCounterScreen({super.key});

  @override
  State<PassengerCounterScreen> createState() => _PassengerCounterScreenState();
}

class _PassengerCounterScreenState extends State<PassengerCounterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  int _passengerCount = 0;
  int _capacity = 50;
  bool _isLoading = false;
  String? _currentStop;
  List<Map<String, dynamic>> _countHistory = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final busProvider = context.read<BusProvider>();
      final trackingProvider = context.read<TrackingProvider>();
      
      // Get bus capacity
      if (busProvider.selectedBus != null) {
        _capacity = busProvider.selectedBus!.capacity ?? 50;
      }
      
      // Get current passenger count
      if (trackingProvider.isTracking) {
        _passengerCount = trackingProvider.currentPassengerCount;
        _currentStop = trackingProvider.currentStop;
      }
      
      // Load count history
      await trackingProvider.getPassengerCountHistory();
      _countHistory = trackingProvider.locationHistory;
      
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Passenger Counter',
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: _showCountHistory,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadInitialData,
        ),
      ],
      child: _isLoading
          ? const LoadingState.fullScreen()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(DesignSystem.space16),
              child: Column(
                children: [
                  // Current Status
                  _buildCurrentStatus(),
                  
                  const SizedBox(height: DesignSystem.space20),
                  
                  // Main Counter
                  _buildMainCounter(),
                  
                  const SizedBox(height: DesignSystem.space20),
                  
                  // Quick Action Buttons
                  _buildQuickActions(),
                  
                  const SizedBox(height: DesignSystem.space20),
                  
                  // Occupancy Visualization
                  _buildOccupancyVisualization(),
                  
                  const SizedBox(height: DesignSystem.space20),
                  
                  // Update Button
                  _buildUpdateButton(),
                  
                  const SizedBox(height: DesignSystem.space20),
                  
                  // Statistics
                  _buildStatistics(),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentStatus() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: context.colors.primary,
                  size: 20,
                ),
                const SizedBox(width: DesignSystem.space8),
                Text(
                  'Current Location',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: DesignSystem.space8),
            
            Text(
              _currentStop ?? 'Not at a stop',
              style: context.textStyles.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(height: DesignSystem.space12),
            
            // Capacity bar
            Row(
              children: [
                Text(
                  'Capacity: ',
                  style: context.textStyles.bodyMedium,
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: _passengerCount / _capacity,
                    backgroundColor: context.colors.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getOccupancyColor(),
                    ),
                  ),
                ),
                const SizedBox(width: DesignSystem.space8),
                Text(
                  '${((_passengerCount / _capacity) * 100).toInt()}%',
                  style: context.textStyles.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getOccupancyColor(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCounter() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space24),
        child: Column(
          children: [
            Text(
              'Current Passengers',
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: DesignSystem.space16),
            
            // Main counter display
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getOccupancyColor().withValues(alpha: 0.1),
                  border: Border.all(
                    color: _getOccupancyColor(),
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_passengerCount',
                        style: context.textStyles.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getOccupancyColor(),
                        ),
                      ),
                      Text(
                        'of $_capacity',
                        style: context.textStyles.titleMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: DesignSystem.space20),
            
            // +/- Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Decrease button
                GestureDetector(
                  onTap: () => _decrementCount(1),
                  onLongPress: () => _decrementCount(5),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.colors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: context.colors.error),
                    ),
                    child: Icon(
                      Icons.remove,
                      size: 40,
                      color: context.colors.error,
                    ),
                  ),
                ),
                
                // Increase button
                GestureDetector(
                  onTap: () => _incrementCount(1),
                  onLongPress: () => _incrementCount(5),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.successColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: context.successColor),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 40,
                      color: context.successColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: DesignSystem.space12),
            
            Text(
              'Tap to add/remove 1 • Long press for 5',
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: AppButton.outlined(
            text: 'Reset to 0',
            onPressed: () => _setCount(0),
            icon: Icons.refresh,
          ),
        ),
        const SizedBox(width: DesignSystem.space12),
        Expanded(
          child: AppButton.outlined(
            text: 'Set Full',
            onPressed: () => _setCount(_capacity),
            icon: Icons.people,
          ),
        ),
        const SizedBox(width: DesignSystem.space12),
        Expanded(
          child: AppButton.outlined(
            text: 'Custom',
            onPressed: _showCustomCountDialog,
            icon: Icons.edit,
          ),
        ),
      ],
    );
  }

  Widget _buildOccupancyVisualization() {
    return SectionLayout(
      title: 'Occupancy Level',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              // Occupancy level indicator
              Container(
                padding: const EdgeInsets.all(DesignSystem.space16),
                decoration: BoxDecoration(
                  color: _getOccupancyColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getOccupancyIcon(),
                      color: _getOccupancyColor(),
                      size: 32,
                    ),
                    const SizedBox(width: DesignSystem.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getOccupancyLabel(),
                            style: context.textStyles.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getOccupancyColor(),
                            ),
                          ),
                          Text(
                            _getOccupancyDescription(),
                            style: context.textStyles.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: DesignSystem.space16),
              
              // Visual seats representation (simplified)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10,
                  childAspectRatio: 1,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: _capacity,
                itemBuilder: (context, index) {
                  final isOccupied = index < _passengerCount;
                  return Container(
                    decoration: BoxDecoration(
                      color: isOccupied 
                          ? _getOccupancyColor()
                          : context.colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 12,
                      color: isOccupied 
                          ? Colors.white
                          : context.colors.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return AppButton(
      text: 'Update Passenger Count',
      onPressed: _updatePassengerCount,
      icon: Icons.cloud_upload,
      isLoading: _isLoading,
    );
  }

  Widget _buildStatistics() {
    return SectionLayout(
      title: 'Today\'s Statistics',
      child: StatsSection(
        crossAxisCount: 2,
        stats: [
          StatItem(
            value: '${_countHistory.length}',
            label: 'Updates\\nToday',
            icon: Icons.update,
            color: context.colors.primary,
          ),
          StatItem(
            value: '${_getAverageOccupancy()}%',
            label: 'Average\\nOccupancy',
            icon: Icons.people,
            color: context.successColor,
          ),
          StatItem(
            value: '${_getMaxOccupancy()}',
            label: 'Peak\\nPassengers',
            icon: Icons.trending_up,
            color: context.warningColor,
          ),
          StatItem(
            value: '${_getEfficiencyScore()}%',
            label: 'Efficiency\\nScore',
            icon: Icons.star,
            color: context.infoColor,
          ),
        ],
      ),
    );
  }

  void _incrementCount(int value) {
    if (_passengerCount + value <= _capacity) {
      setState(() {
        _passengerCount += value;
      });
      _animateCounter();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum capacity reached')),
      );
    }
  }

  void _decrementCount(int value) {
    setState(() {
      _passengerCount = (_passengerCount - value).clamp(0, _capacity);
    });
    _animateCounter();
  }

  void _setCount(int count) {
    setState(() {
      _passengerCount = count.clamp(0, _capacity);
    });
    _animateCounter();
  }

  void _animateCounter() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  Color _getOccupancyColor() {
    final ratio = _passengerCount / _capacity;
    if (ratio >= 0.9) return context.colors.error;
    if (ratio >= 0.7) return context.warningColor;
    if (ratio >= 0.3) return context.successColor;
    return context.infoColor;
  }

  IconData _getOccupancyIcon() {
    final ratio = _passengerCount / _capacity;
    if (ratio >= 0.9) return Icons.warning;
    if (ratio >= 0.7) return Icons.people;
    if (ratio >= 0.3) return Icons.people_outline;
    return Icons.person_outline;
  }

  String _getOccupancyLabel() {
    final ratio = _passengerCount / _capacity;
    if (ratio >= 0.9) return 'Full';
    if (ratio >= 0.7) return 'High';
    if (ratio >= 0.3) return 'Moderate';
    return 'Low';
  }

  String _getOccupancyDescription() {
    final ratio = _passengerCount / _capacity;
    if (ratio >= 0.9) return 'Bus is at maximum capacity';
    if (ratio >= 0.7) return 'Bus is getting crowded';
    if (ratio >= 0.3) return 'Comfortable passenger load';
    return 'Plenty of space available';
  }

  int _getAverageOccupancy() {
    if (_countHistory.isEmpty) return 0;
    final total = _countHistory.fold<int>(0, (sum, entry) => sum + (entry['count'] as int));
    return ((total / _countHistory.length) / _capacity * 100).round();
  }

  int _getMaxOccupancy() {
    if (_countHistory.isEmpty) return _passengerCount;
    return _countHistory.fold<int>(_passengerCount, (max, entry) => 
        (entry['count'] as int) > max ? entry['count'] as int : max);
  }

  int _getEfficiencyScore() {
    final ratio = _passengerCount / _capacity;
    if (ratio >= 0.7 && ratio <= 0.9) return 100;
    if (ratio >= 0.5) return 80;
    if (ratio >= 0.3) return 60;
    return 40;
  }

  void _showCustomCountDialog() {
    final controller = TextEditingController(text: _passengerCount.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Custom Count'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppInput(
              controller: controller,
              label: 'Passenger Count',
              keyboardType: TextInputType.number,
              validator: (value) {
                final count = int.tryParse(value ?? '');
                if (count == null) return 'Please enter a valid number';
                if (count < 0) return 'Count cannot be negative';
                if (count > _capacity) return 'Count cannot exceed capacity ($_capacity)';
                return null;
              },
            ),
          ],
        ),
        actions: [
          AppButton.text(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            text: 'Set Count',
            onPressed: () {
              final count = int.tryParse(controller.text);
              if (count != null && count >= 0 && count <= _capacity) {
                Navigator.of(context).pop();
                _setCount(count);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showCountHistory() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Column(
          children: [
            Text(
              'Count History',
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DesignSystem.space16),
            Expanded(
              child: _countHistory.isEmpty
                  ? const EmptyState(
                      title: 'No history',
                      message: 'No passenger count updates today',
                      icon: Icons.history,
                    )
                  : ListView.builder(
                      itemCount: _countHistory.length,
                      itemBuilder: (context, index) {
                        final entry = _countHistory[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getOccupancyColor(),
                            child: Text(
                              '${entry['count']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text('${entry['count']} passengers'),
                          subtitle: Text(entry['time'] ?? 'Unknown time'),
                          trailing: Text(entry['stop'] ?? 'Unknown stop'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePassengerCount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final trackingProvider = context.read<TrackingProvider>();
      await trackingProvider.updatePassengerCount(_passengerCount);
      
      // Add to history
      _countHistory.insert(0, {
        'count': _passengerCount,
        'time': TimeOfDay.now().format(context),
        'stop': _currentStop,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passenger count updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update count: $error')),
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
}