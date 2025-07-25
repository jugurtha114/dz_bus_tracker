// lib/screens/driver/schedules_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/driver_provider.dart';
import '../../providers/line_provider.dart';
import '../../models/tracking_model.dart';
import '../../services/navigation_service.dart';
import '../../widgets/common/app_layout.dart';
import '../../widgets/common/glassy_container.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../localization/app_localizations.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({Key? key}) : super(key: key);

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  bool _isLoading = true;
  String _selectedDay = DateTime.now().weekday.toString();
  Map<String, dynamic>? _selectedLine;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);
    
    try {
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      await driverProvider.fetchDriverSchedules();
      
      // Get current line if available
      if (driverProvider.currentBus != null) {
        // For now, use a placeholder line
        setState(() {
          _selectedLine = {'id': 'line1', 'name': 'Current Line'};
        });
      }
    } catch (e) {
      // Error handling
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final driverProvider = Provider.of<DriverProvider>(context);
    final lineProvider = Provider.of<LineProvider>(context);

    return AppLayout(
      title: localizations.translate('schedules'),
      child: _isLoading
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day selector
                  _buildDaySelector(localizations),
                  const SizedBox(height: 16),
                  
                  // Current schedule
                  _buildCurrentSchedule(localizations, driverProvider),
                  const SizedBox(height: 16),
                  
                  // Upcoming trips
                  _buildUpcomingTrips(localizations, driverProvider),
                  const SizedBox(height: 16),
                  
                  // Line schedules
                  _buildLineSchedules(localizations, lineProvider),
                ],
              ),
            ),
    );
  }

  Widget _buildDaySelector(AppLocalizations localizations) {
    final days = [
      {'value': '1', 'label': localizations.translate('monday')},
      {'value': '2', 'label': localizations.translate('tuesday')},
      {'value': '3', 'label': localizations.translate('wednesday')},
      {'value': '4', 'label': localizations.translate('thursday')},
      {'value': '5', 'label': localizations.translate('friday')},
      {'value': '6', 'label': localizations.translate('saturday')},
      {'value': '7', 'label': localizations.translate('sunday')},
    ];

    return SizedBox(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = _selectedDay == day['value'];
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(day['label']!),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedDay = day['value']!;
                  });
                  _loadSchedules();
                }
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentSchedule(AppLocalizations localizations, DriverProvider driverProvider) {
    final currentSchedule = driverProvider.schedules
        .where((s) => s['day_of_week'].toString() == _selectedDay)
        .toList();

    return CustomCard(type: CardType.elevated, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate('current_schedule'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          if (currentSchedule.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.translate('no_schedule_today'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...currentSchedule.map((schedule) => _buildScheduleItem(schedule, localizations)),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(Map<String, dynamic> schedule, AppLocalizations localizations) {
    final startTime = schedule['start_time'] ?? '';
    final endTime = schedule['end_time'] ?? '';
    final frequency = schedule['frequency_minutes'] ?? 0;
    final line = schedule['line'] ?? _selectedLine;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
        
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.schedule,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          '${_formatTime(startTime)} - ${_formatTime(endTime)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (line != null)
              Text('${localizations.translate('line')}: ${line['code'] ?? ''} - ${line['name'] ?? ''}'),
            Text('${localizations.translate('frequency')}: ${localizations.translate('every')} $frequency ${localizations.translate('minutes')}'),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildUpcomingTrips(AppLocalizations localizations, DriverProvider driverProvider) {
    final now = DateTime.now();
    final upcomingTrips = driverProvider.trips
        .where((trip) {
          // For now, check if trip is not completed
          if (trip.isCompleted) return false;
          return trip.startTime.isAfter(now);
        })
        .take(5)
        .toList();

    return CustomCard(type: CardType.elevated, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.translate('upcoming_trips'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to trips screen
                  NavigationService.navigateTo('/driver/trips');
                },
                child: Text(localizations.translate('view_all')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (upcomingTrips.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  localizations.translate('no_upcoming_trips'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            )
          else
            ...upcomingTrips.map((trip) => _buildTripItem(trip, localizations)),
        ],
      ),
    );
  }

  Widget _buildTripItem(Trip trip, AppLocalizations localizations) {
    final scheduledTime = trip.startTime;
    final line = trip.line;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.directions_bus,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          '${localizations.translate('trip')} #${trip.id.substring(0, 8)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (line.isNotEmpty)
              Text('${localizations.translate('line')}: ${line['code'] ?? ''} - ${line['name'] ?? ''}'),
            Text('${localizations.translate('departure')}: ${DzDateUtils.formatTime(scheduledTime)}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DzDateUtils.getTimeAgo(scheduledTime),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineSchedules(AppLocalizations localizations, LineProvider lineProvider) {
    if (_selectedLine == null) return const SizedBox();

    // TODO: Get line schedules from line provider
    final lineSchedules = <Map<String, dynamic>>[];

    return CustomCard(type: CardType.elevated, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${localizations.translate('line_schedule')}: ${_selectedLine!['code'] ?? ''}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          if (lineSchedules.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  localizations.translate('no_schedules_available'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            )
          else
            DataTable(
              columns: [
                DataColumn(label: Text(localizations.translate('day'))),
                DataColumn(label: Text(localizations.translate('hours'))),
                DataColumn(label: Text(localizations.translate('frequency'))),
              ],
              rows: lineSchedules.map((schedule) {
                return DataRow(
                  cells: [
                    DataCell(Text(_getDayName(schedule['day_of_week'], localizations))),
                    DataCell(Text('${_formatTime(schedule['start_time'])} - ${_formatTime(schedule['end_time'])}')),
                    DataCell(Text('${schedule['frequency_minutes']} min')),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '--:--';
    
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      }
    } catch (e) {
      // Handle error
    }
    
    return time;
  }

  String _getDayName(dynamic dayOfWeek, AppLocalizations localizations) {
    final day = dayOfWeek?.toString() ?? '';
    switch (day) {
      case '1': return localizations.translate('monday');
      case '2': return localizations.translate('tuesday');
      case '3': return localizations.translate('wednesday');
      case '4': return localizations.translate('thursday');
      case '5': return localizations.translate('friday');
      case '6': return localizations.translate('saturday');
      case '7': return localizations.translate('sunday');
      default: return '';
    }
  }
}