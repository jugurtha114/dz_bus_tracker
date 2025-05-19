// lib/widgets/driver/passenger_counter.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class PassengerCounter extends StatefulWidget {
  final Function(int) onCountChanged;
  final bool isEnabled;
  final int initialCount;
  final int minCount;
  final int maxCount;
  final int step;

  const PassengerCounter({
    Key? key,
    required this.onCountChanged,
    this.isEnabled = true,
    this.initialCount = 0,
    this.minCount = 0,
    this.maxCount = 100,
    this.step = 1,
  }) : super(key: key);

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PassengerCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCount != oldWidget.initialCount && widget.initialCount != _count) {
      setState(() {
        _count = widget.initialCount;
        _controller.text = _count.toString();
      });
    }
  }

  void _increment() {
    if (!widget.isEnabled) return;
    if (_count + widget.step <= widget.maxCount) {
      setState(() {
        _count += widget.step;
        _controller.text = _count.toString();
        widget.onCountChanged(_count);
      });
    }
  }

  void _decrement() {
    if (!widget.isEnabled) return;
    if (_count - widget.step >= widget.minCount) {
      setState(() {
        _count -= widget.step;
        _controller.text = _count.toString();
        widget.onCountChanged(_count);
      });
    }
  }

  void _updateCount(String value) {
    if (!widget.isEnabled) return;
    final newCount = int.tryParse(value) ?? widget.initialCount;
    if (newCount >= widget.minCount && newCount <= widget.maxCount) {
      setState(() {
        _count = newCount;
        widget.onCountChanged(_count);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color enabledColor = widget.isEnabled ? AppColors.white : AppColors.white.withOpacity(0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Passenger Count',
          style: AppTextStyles.body.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Decrement button
            IconButton(
              icon: Container(
                decoration: BoxDecoration(
                  color: widget.isEnabled ? AppColors.primary : AppColors.mediumGrey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.remove,
                  color: AppColors.white,
                ),
              ),
              onPressed: widget.isEnabled ? _decrement : null,
            ),

            // Count field
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: AppTextStyles.h2.copyWith(
                  color: enabledColor,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.primary.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: enabledColor.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: enabledColor.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: enabledColor,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                enabled: widget.isEnabled,
                onChanged: _updateCount,
              ),
            ),

            // Increment button
            IconButton(
              icon: Container(
                decoration: BoxDecoration(
                  color: widget.isEnabled ? AppColors.primary : AppColors.mediumGrey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.white,
                ),
              ),
              onPressed: widget.isEnabled ? _increment : null,
            ),
          ],
        ),

        // Controls description
        if (widget.isEnabled)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Tap + or - to update passenger count',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Start tracking to update passenger count',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}