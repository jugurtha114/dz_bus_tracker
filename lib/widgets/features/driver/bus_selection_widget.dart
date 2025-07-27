// lib/widgets/features/driver/bus_selection_widget.dart

import 'package:flutter/material.dart';
import '../../../config/design_system.dart';
import '../../../models/bus_model.dart';
import '../../foundation/enhanced_card.dart';
import '../../foundation/status_badge.dart';

class BusSelectionWidget extends StatelessWidget {
  final List<Bus> buses;
  final Bus? selectedBus;
  final Function(Bus) onBusSelected;
  final VoidCallback? onAddBus;
  final bool isLoading;

  const BusSelectionWidget({
    super.key,
    required this.buses,
    this.selectedBus,
    required this.onBusSelected,
    this.onAddBus,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Bus',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onAddBus != null)
                TextButton.icon(
                  onPressed: onAddBus,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Bus'),
                ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacing16),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (buses.isEmpty)
            _EmptyBusState(onAddBus: onAddBus)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: buses.length,
              separatorBuilder: (context, index) => const SizedBox(height: DesignSystem.spacing8),
              itemBuilder: (context, index) => _BusCard(
                bus: buses[index],
                isSelected: selectedBus?.id == buses[index].id,
                onTap: () => onBusSelected(buses[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _BusCard extends StatelessWidget {
  final Bus bus;
  final bool isSelected;
  final VoidCallback onTap;

  const _BusCard({
    required this.bus,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
      child: Container(
        padding: const EdgeInsets.all(DesignSystem.spacing12),
        decoration: BoxDecoration(
          color: isSelected 
              ? DesignSystem.primaryColor.withOpacity(0.1)
              : DesignSystem.surfaceVariant,
          borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
          border: Border.all(
            color: isSelected 
                ? DesignSystem.primaryColor
                : DesignSystem.surfaceBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected 
                    ? DesignSystem.primaryColor
                    : DesignSystem.textSecondary,
                borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
              ),
              child: Icon(
                Icons.directions_bus,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: DesignSystem.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        bus.licensePlate ?? 'Unknown',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? DesignSystem.primaryColor
                              : DesignSystem.textPrimary,
                        ),
                      ),
                      const SizedBox(width: DesignSystem.spacing8),
                      if (bus.isAirConditioned == true)
                        Icon(
                          Icons.ac_unit,
                          size: 16,
                          color: DesignSystem.infoColor,
                        ),
                    ],
                  ),
                  const SizedBox(height: DesignSystem.spacing4),
                  Text(
                    '${bus.manufacturer ?? ''} ${bus.model ?? ''} (${bus.year ?? 'N/A'})',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: DesignSystem.textSecondary,
                    ),
                  ),
                  if (bus.capacity != null) ...[
                    const SizedBox(height: DesignSystem.spacing4),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 14,
                          color: DesignSystem.textSecondary,
                        ),
                        const SizedBox(width: DesignSystem.spacing4),
                        Text(
                          'Capacity: ${bus.capacity}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: DesignSystem.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                StatusBadge(
                  status: bus.isApproved == true ? 'Approved' : 'Pending',
                  color: bus.isApproved == true 
                      ? DesignSystem.successColor 
                      : DesignSystem.warningColor,
                ),
                if (isSelected) ...[
                  const SizedBox(height: DesignSystem.spacing8),
                  Icon(
                    Icons.check_circle,
                    color: DesignSystem.primaryColor,
                    size: 20,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBusState extends StatelessWidget {
  final VoidCallback? onAddBus;

  const _EmptyBusState({this.onAddBus});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignSystem.spacing24),
      child: Column(
        children: [
          Icon(
            Icons.directions_bus_outlined,
            size: 64,
            color: DesignSystem.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: DesignSystem.spacing16),
          Text(
            'No buses available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing8),
          Text(
            'You need to add a bus to start driving',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: DesignSystem.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (onAddBus != null) ...[
            const SizedBox(height: DesignSystem.spacing16),
            ElevatedButton.icon(
              onPressed: onAddBus,
              icon: const Icon(Icons.add),
              label: const Text('Add Bus'),
            ),
          ],
        ],
      ),
    );
  }
}