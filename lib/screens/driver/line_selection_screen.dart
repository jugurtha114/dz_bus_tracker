// lib/screens/driver/line_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../config/route_config.dart';
import '../../providers/line_provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/driver_provider.dart';
import '../../widgets/widgets.dart';
import '../../models/line_model.dart';

/// Modern line selection screen for drivers to choose their active route
class LineSelectionScreen extends StatefulWidget {
  const LineSelectionScreen({super.key});

  @override
  State<LineSelectionScreen> createState() => _LineSelectionScreenState();
}

class _LineSelectionScreenState extends State<LineSelectionScreen> {
  late TextEditingController _searchController;
  bool _isLoading = false;
  List<Line> _availableLines = [];
  Line? _currentLine;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final lineProvider = context.read<LineProvider>();
      final driverProvider = context.read<DriverProvider>();
      
      await Future.wait([
        lineProvider.fetchAvailableLines(),
        driverProvider.getCurrentAssignment(),
      ]);
      
      setState(() {
        _availableLines = lineProvider.availableLines;
        // Handle currentLine conversion from String? to Line?
        final currentLineId = driverProvider.currentLine;
        if (currentLineId != null && _availableLines.isNotEmpty) {
          try {
            _currentLine = _availableLines.firstWhere(
              (line) => line.id == currentLineId,
            );
          } catch (e) {
            _currentLine = null;
          }
        }
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load lines: $error')),
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

  List<Line> _getFilteredLines() {
    List<Line> filtered = _availableLines;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((line) {
        return (line.name?.toLowerCase().contains(query) ?? false) ||
               (line.number?.toLowerCase().contains(query) ?? false) ||
               (line.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case 'express':
        filtered = filtered.where((line) => line.type == 'express').toList();
        break;
      case 'local':
        filtered = filtered.where((line) => line.type == 'local').toList();
        break;
      case 'night':
        filtered = filtered.where((line) => line.type == 'night').toList();
        break;
      default:
        break;
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Select Line',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
        ),
      ],
      child: Column(
        children: [
          // Current Assignment (if any)
          if (_currentLine != null) _buildCurrentAssignment(),
          
          // Search and Filters
          _buildSearchSection(),
          
          // Available Lines
          Expanded(
            child: _isLoading
                ? const LoadingState.fullScreen()
                : _buildLinesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentAssignment() {
    return Container(
      margin: const EdgeInsets.all(DesignSystem.space16),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.route,
                    color: context.colors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: DesignSystem.space8),
                  Text(
                    'Current Assignment',
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: DesignSystem.space12),
              
              Row(
                children: [
                  // Line badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignSystem.space12,
                      vertical: DesignSystem.space8,
                    ),
                    decoration: BoxDecoration(
                      color: _currentLine!.color != null
                          ? Color(int.parse(_currentLine!.color!.replaceFirst('#', '0xff')))
                          : context.colors.primary,
                      borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                    ),
                    child: Text(
                      'Line ${_currentLine!.number ?? 'N/A'}',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: DesignSystem.space12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentLine!.name ?? 'Unnamed Line',
                          style: context.textStyles.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${_currentLine!.startLocation ?? 'Unknown'} ↔ ${_currentLine!.endLocation ?? 'Unknown'}',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  AppButton.outlined(
                    text: 'End Shift',
                    onPressed: _endCurrentShift,
                    size: AppButtonSize.small,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space16),
      child: Column(
        children: [
          // Search bar
          AppInput(
            controller: _searchController,
            label: 'Search lines by name, number, or route',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            onChanged: (value) => setState(() {}),
          ),
          
          const SizedBox(height: DesignSystem.space12),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: DesignSystem.space8),
                _buildFilterChip('Express', 'express'),
                const SizedBox(width: DesignSystem.space8),
                _buildFilterChip('Local', 'local'),
                const SizedBox(width: DesignSystem.space8),
                _buildFilterChip('Night', 'night'),
              ],
            ),
          ),
          
          const SizedBox(height: DesignSystem.space16),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : 'all';
        });
      },
      selectedColor: context.colors.primaryContainer,
      backgroundColor: context.colors.surfaceContainerHighest,
    );
  }

  Widget _buildLinesList() {
    final filteredLines = _getFilteredLines();

    if (filteredLines.isEmpty) {
      return EmptyState(
        title: _searchController.text.isNotEmpty ? 'No lines found' : 'No available lines',
        message: _searchController.text.isNotEmpty
            ? 'No lines match your search "${_searchController.text}"'
            : 'No lines are currently available for assignment',
        icon: Icons.route_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space16),
      itemCount: filteredLines.length,
      itemBuilder: (context, index) {
        final line = filteredLines[index];
        final isCurrentLine = _currentLine?.id == line.id;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: DesignSystem.space12),
          child: _buildLineCard(line, isCurrentLine),
        );
      },
    );
  }

  Widget _buildLineCard(Line line, bool isCurrent) {
    return AppCard(
      onTap: isCurrent ? null : () => _selectLine(line),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space16),
        child: Row(
          children: [
            // Line number badge
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: line.color != null
                    ? Color(int.parse(line.color!.replaceFirst('#', '0xff')))
                    : context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              ),
              child: Center(
                child: Text(
                  line.number ?? 'N/A',
                  style: context.textStyles.titleMedium?.copyWith(
                    color: line.color != null ? Colors.white : context.colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: DesignSystem.space16),
            
            // Line details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          line.name ?? 'Unnamed Line',
                          style: context.textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (line.type != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignSystem.space8,
                            vertical: DesignSystem.space4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(line.type!),
                            borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                          ),
                          child: Text(
                            line.type!.toUpperCase(),
                            style: context.textStyles.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: DesignSystem.space4),
                  
                  Text(
                    '${line.startLocation ?? 'Unknown'} ↔ ${line.endLocation ?? 'Unknown'}',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  
                  const SizedBox(height: DesignSystem.space8),
                  
                  Row(
                    children: [
                      _buildLineDetail(Icons.schedule, 'Every ${line.frequency ?? 0}min'),
                      const SizedBox(width: DesignSystem.space16),
                      _buildLineDetail(Icons.location_on, '${line.stopsCount ?? 0} stops'),
                      const SizedBox(width: DesignSystem.space16),
                      _buildLineDetail(Icons.straighten, '${line.totalDistance?.toStringAsFixed(1) ?? '0.0'} km'),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action button or current indicator
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSystem.space12,
                  vertical: DesignSystem.space8,
                ),
                decoration: BoxDecoration(
                  color: context.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: context.successColor,
                      size: 16,
                    ),
                    const SizedBox(width: DesignSystem.space4),
                    Text(
                      'CURRENT',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.successColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else
              Icon(
                Icons.chevron_right,
                color: context.colors.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineDetail(IconData icon, String text) {
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

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'express':
        return context.colors.error;
      case 'night':
        return Colors.indigo;
      case 'local':
        return context.successColor;
      default:
        return context.colors.primary;
    }
  }

  void _selectLine(Line line) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Line'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Do you want to start operating on:'),
            const SizedBox(height: DesignSystem.space8),
            Text(
              '${line.name}',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${line.startLocation} ↔ ${line.endLocation}',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            if (_currentLine != null) ...[ 
              const SizedBox(height: DesignSystem.space12),
              Text(
                'This will end your current assignment on ${_currentLine!.name}.',
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.warningColor,
                ),
              ),
            ],
          ],
        ),
        actions: [
          AppButton.text(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            text: 'Select Line',
            onPressed: () {
              Navigator.of(context).pop();
              _confirmLineSelection(line);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLineSelection(Line line) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final driverProvider = context.read<DriverProvider>();
      await driverProvider.selectLine(line.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Line ${line.number} selected successfully'),
            backgroundColor: context.successColor,
          ),
        );
        
        // Refresh data to show current assignment
        await _loadData();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select line: $error')),
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

  void _endCurrentShift() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Shift'),
        content: const Text('Are you sure you want to end your current shift?'),
        actions: [
          AppButton.text(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            text: 'End Shift',
            onPressed: () {
              Navigator.of(context).pop();
              _confirmEndShift();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmEndShift() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final driverProvider = context.read<DriverProvider>();
      await driverProvider.endShift();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shift ended successfully'),
          ),
        );
        
        // Refresh data
        await _loadData();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to end shift: $error')),
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