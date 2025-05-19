// lib/screens/driver/line_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../providers/line_provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/passenger/line_list_item.dart';
import '../../helpers/dialog_helper.dart';
import '../../helpers/error_handler.dart';

class LineSelectionScreen extends StatefulWidget {
  const LineSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LineSelectionScreen> createState() => _LineSelectionScreenState();
}

class _LineSelectionScreenState extends State<LineSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadLines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLines() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final lineProvider = Provider.of<LineProvider>(context, listen: false);
      await lineProvider.fetchLines(isActive: true);
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

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<Map<String, dynamic>> _getFilteredLines() {
    final lineProvider = Provider.of<LineProvider>(context);

    if (_searchQuery.isEmpty) {
      return lineProvider.lines;
    }

    return lineProvider.lines.where((line) {
      final name = line['name']?.toString().toLowerCase() ?? '';
      final code = line['code']?.toString().toLowerCase() ?? '';
      final description = line['description']?.toString().toLowerCase() ?? '';

      return name.contains(_searchQuery) ||
          code.contains(_searchQuery) ||
          description.contains(_searchQuery);
    }).toList();
  }

  void _onLineSelected(Map<String, dynamic> line) {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);

    // Check if tracking is active
    if (trackingProvider.isTracking) {
      DialogHelper.showInfoDialog(
        context,
        title: 'Tracking Active',
        message: 'You need to stop tracking before selecting a new line.',
      );
      return;
    }

    // Check if a bus is selected
    if (busProvider.selectedBus == null) {
      DialogHelper.showInfoDialog(
        context,
        title: 'No Bus Selected',
        message: 'Please select a bus first before selecting a line.',
      ).then((_) {
        AppRouter.navigateTo(context, AppRoutes.busManagement);
      });
      return;
    }

    // Update bus with selected line
    _updateBusLine(busProvider.selectedBus!['id'], line['id']);
  }

  Future<void> _updateBusLine(String busId, String lineId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final busProvider = Provider.of<BusProvider>(context, listen: false);

      await busProvider.updateBus(
        busId: busId,
        lineId: lineId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Line selected successfully'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate back
        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final filteredLines = _getFilteredLines();
    final busProvider = Provider.of<BusProvider>(context);

    return Scaffold(
      appBar: const DzAppBar(
        title: 'Select Line',
      ),
      body: Column(
        children: [
          // Bus info card
          if (busProvider.selectedBus != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_bus,
                      color: AppColors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Bus',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.white.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            'Bus ${busProvider.selectedBus!['license_plate']}',
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by line name, code, or description',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.white,
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(
              child: LoadingIndicator(),
            )
                : filteredLines.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: AppColors.mediumGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No lines available'
                        : 'No lines matching "$_searchQuery"',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredLines.length,
              itemBuilder: (context, index) {
                final line = filteredLines[index];

                return LineListItem(
                  line: line,
                  onTap: () => _onLineSelected(line),
                  showStops: true,
                  showSchedule: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}