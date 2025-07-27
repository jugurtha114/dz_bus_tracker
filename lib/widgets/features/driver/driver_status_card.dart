// lib/widgets/features/driver/driver_status_card.dart

import 'package:flutter/material.dart';
import '../../../config/design_system.dart';
import '../../foundation/enhanced_card.dart';
import '../../foundation/status_badge.dart';

class DriverStatusCard extends StatelessWidget {
  final String driverName;
  final bool isOnline;
  final String? currentBus;
  final String? currentLine;
  final VoidCallback onToggleStatus;
  final VoidCallback onSelectBus;
  final bool isLoading;

  const DriverStatusCard({
    super.key,
    required this.driverName,
    required this.isOnline,
    this.currentBus,
    this.currentLine,
    required this.onToggleStatus,
    required this.onSelectBus,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [DesignSystem.primaryColor, DesignSystem.primaryLightColor],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_getGreeting()},',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spacing4),
                    Text(
                      driverName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                status: isOnline ? 'Online' : 'Offline',
                color: isOnline ? DesignSystem.successColor : DesignSystem.errorColor,
                showDot: true,
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacing16),
          Row(
            children: [
              const Icon(Icons.directions_bus, color: Colors.white, size: 16),
              const SizedBox(width: DesignSystem.spacing8),
              Text(
                currentBus != null ? 'Bus $currentBus' : 'No bus selected',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              if (currentLine != null) ...[
                const SizedBox(width: DesignSystem.spacing16),
                const Icon(Icons.route, color: Colors.white, size: 16),
                const SizedBox(width: DesignSystem.spacing8),
                Text(
                  'Line $currentLine',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: DesignSystem.spacing16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onToggleStatus,
                  icon: isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(isOnline ? Icons.pause : Icons.play_arrow),
                  label: Text(isOnline ? 'Go Offline' : 'Go Online'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: DesignSystem.spacing12),
              OutlinedButton(
                onPressed: onSelectBus,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                child: Text(currentBus != null ? 'Change Bus' : 'Select Bus'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}