// lib/widgets/features/driver/passenger_counter_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/design_system.dart';
import '../../foundation/enhanced_card.dart';

class PassengerCounter extends StatefulWidget {
  final int initialCount;
  final int maxCapacity;
  final Function(int) onCountChanged;
  final bool isEnabled;

  const PassengerCounter({
    super.key,
    required this.initialCount,
    required this.maxCapacity,
    required this.onCountChanged,
    this.isEnabled = true,
  });

  @override
  State<PassengerCounter> createState() => _PassengerCounterState();
}

class _PassengerCounterState extends State<PassengerCounter> {
  late int _count;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
    _controller = TextEditingController(text: _count.toString());
  }

  @override
  void didUpdateWidget(PassengerCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCount != oldWidget.initialCount) {
      setState(() {
        _count = widget.initialCount;
        _controller.text = _count.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    if (!widget.isEnabled || _count >= widget.maxCapacity) return;
    setState(() {
      _count++;
      _controller.text = _count.toString();
      widget.onCountChanged(_count);
    });
    HapticFeedback.lightImpact();
  }

  void _decrement() {
    if (!widget.isEnabled || _count <= 0) return;
    setState(() {
      _count--;
      _controller.text = _count.toString();
      widget.onCountChanged(_count);
    });
    HapticFeedback.lightImpact();
  }

  void _onTextChanged(String value) {
    if (!widget.isEnabled) return;
    final newCount = int.tryParse(value);
    if (newCount != null && newCount >= 0 && newCount <= widget.maxCapacity) {
      setState(() {
        _count = newCount;
        widget.onCountChanged(_count);
      });
    }
  }

  Color get _occupancyColor {
    final percentage = widget.maxCapacity > 0 ? _count / widget.maxCapacity : 0.0;
    if (percentage <= 0.5) return DesignSystem.successColor;
    if (percentage <= 0.8) return DesignSystem.warningColor;
    return DesignSystem.errorColor;
  }

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
                'Passenger Count',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSystem.spacing8,
                  vertical: DesignSystem.spacing4,
                ),
                decoration: BoxDecoration(
                  color: _occupancyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                ),
                child: Text(
                  '${(widget.maxCapacity > 0 ? (_count / widget.maxCapacity * 100) : 0).toInt()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _occupancyColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacing16),
          Row(
            children: [
              // Decrement button
              _CounterButton(
                icon: Icons.remove,
                onPressed: widget.isEnabled && _count > 0 ? _decrement : null,
                enabled: widget.isEnabled && _count > 0,
              ),
              const SizedBox(width: DesignSystem.spacing12),
              // Count display/input
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: widget.isEnabled 
                        ? DesignSystem.surfaceVariant
                        : DesignSystem.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                    border: Border.all(
                      color: widget.isEnabled 
                          ? DesignSystem.surfaceBorder
                          : DesignSystem.surfaceBorder.withOpacity(0.5),
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    enabled: widget.isEnabled,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.isEnabled 
                          ? DesignSystem.textPrimary
                          : DesignSystem.textDisabled,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: DesignSystem.spacing12),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    onChanged: _onTextChanged,
                  ),
                ),
              ),
              const SizedBox(width: DesignSystem.spacing12),
              // Increment button
              _CounterButton(
                icon: Icons.add,
                onPressed: widget.isEnabled && _count < widget.maxCapacity ? _increment : null,
                enabled: widget.isEnabled && _count < widget.maxCapacity,
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacing12),
          // Capacity info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Capacity: ${widget.maxCapacity}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
              Text(
                'Available: ${widget.maxCapacity - _count}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
            ],
          ),
          if (!widget.isEnabled) ...[
            const SizedBox(height: DesignSystem.spacing8),
            Text(
              'Start tracking to update passenger count',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DesignSystem.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool enabled;

  const _CounterButton({
    required this.icon,
    this.onPressed,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: enabled 
            ? DesignSystem.primaryColor
            : DesignSystem.surfaceVariant,
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
        boxShadow: enabled ? [
          BoxShadow(
            color: DesignSystem.primaryColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: enabled ? Colors.white : DesignSystem.textDisabled,
          size: 24,
        ),
      ),
    );
  }
}