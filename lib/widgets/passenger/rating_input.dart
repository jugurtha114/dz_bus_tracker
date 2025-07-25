// lib/widgets/passenger/rating_input.dart

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../config/theme_config.dart';
import '../common/custom_button.dart';

class RatingInput extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double> onRatingChanged;
  final ValueChanged<String>? onCommentChanged;
  final Future<void> Function(double rating, String comment)? onSubmit;
  final bool allowHalfRating;
  final double itemSize;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showSubmitButton;
  final String submitButtonText;
  final bool isLoading;
  final String? commentHint;
  final bool useGlassyContainer;

  const RatingInput({
    Key? key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.onCommentChanged,
    this.onSubmit,
    this.allowHalfRating = false,
    this.itemSize = 40,
    this.activeColor,
    this.inactiveColor,
    this.showSubmitButton = true,
    this.submitButtonText = 'Submit Rating',
    this.isLoading = false,
    this.commentHint = 'Add a comment (optional)',
    this.useGlassyContainer = false,
  }) : super(key: key);

  @override
  State<RatingInput> createState() => _RatingInputState();
}

class _RatingInputState extends State<RatingInput> {
  late double _currentRating;
  final TextEditingController _commentController = TextEditingController();
  bool _hasRated = false;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
    _hasRated = widget.initialRating > 0;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleRatingUpdate(double rating) {
    setState(() {
      _currentRating = rating;
      _hasRated = true;
    });
    widget.onRatingChanged(rating);
  }

  void _handleCommentChanged(String comment) {
    if (widget.onCommentChanged != null) {
      widget.onCommentChanged!(comment);
    }
  }

  Future<void> _handleSubmit() async {
    if (widget.onSubmit != null && _hasRated) {
      await widget.onSubmit!(_currentRating, _commentController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Rating stars
        RatingBar.builder(
          initialRating: _currentRating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: widget.allowHalfRating,
          itemCount: 5,
          itemSize: widget.itemSize,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: widget.activeColor ?? Theme.of(context).colorScheme.primary,
          ),
          unratedColor: widget.useGlassyContainer
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : widget.inactiveColor ?? Theme.of(context).colorScheme.primary,
          onRatingUpdate: _handleRatingUpdate,
        ),

        const SizedBox(height: 16),

        // Rating description
        Text(
          _getRatingDescription(_currentRating),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: widget.useGlassyContainer
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // Comment field
        Container(
          decoration: BoxDecoration(
            color: widget.useGlassyContainer
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.useGlassyContainer
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
          child: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: widget.commentHint,
              hintStyle: TextStyle(
                color: widget.useGlassyContainer
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Theme.of(context).colorScheme.primary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: TextStyle(
              color: widget.useGlassyContainer
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary,
            ),
            maxLines: 3,
            onChanged: _handleCommentChanged,
          ),
        ),

        if (widget.showSubmitButton) ...[
          const SizedBox(height: 16),

          // Submit button
          CustomButton(
        text: widget.submitButtonText,
        onPressed: _hasRated ? _handleSubmit : () {},
            isLoading: widget.isLoading,
            isDisabled: !_hasRated,
            color: widget.useGlassyContainer
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary,
          ),
        ],
      ],
    );

    if (widget.useGlassyContainer) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: content,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }

  String _getRatingDescription(double rating) {
    if (rating == 0) {
      return 'Tap to rate';
    } else if (rating <= 1) {
      return 'Very Poor';
    } else if (rating <= 2) {
      return 'Poor';
    } else if (rating <= 3) {
      return 'Fair';
    } else if (rating <= 4) {
      return 'Good';
    } else {
      return 'Excellent';
    }
  }
}

class RateDriverDialog extends StatefulWidget {
  final String driverId;
  final String? driverName;
  final Future<bool> Function(String driverId, int rating, String comment) onSubmitRating;

  const RateDriverDialog({
    Key? key,
    required this.driverId,
    this.driverName,
    required this.onSubmitRating,
  }) : super(key: key);

  @override
  State<RateDriverDialog> createState() => _RateDriverDialogState();
}

class _RateDriverDialogState extends State<RateDriverDialog> {
  double _rating = 0;
  String _comment = '';
  bool _isLoading = false;

  void _handleRatingChanged(double rating) {
    setState(() {
      _rating = rating;
    });
  }

  void _handleCommentChanged(String comment) {
    _comment = comment;
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await widget.onSubmitRating(
        widget.driverId,
        _rating.round(),
        _comment,
      );

      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit rating: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
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
    return AlertDialog(
      title: Text(
        'Rate ${widget.driverName ?? 'Driver'}',
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: RatingInput(
          initialRating: _rating,
          onRatingChanged: _handleRatingChanged,
          onCommentChanged: _handleCommentChanged,
          onSubmit: (rating, comment) async {
            await _handleSubmit();
          },
          showSubmitButton: false,
          commentHint: 'Leave feedback for the driver (optional)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _rating > 0 ? (_isLoading ? null : _handleSubmit) : null,
          child: _isLoading
              ? SizedBox(
            width: 20,
        
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
          )
              : const Text('Submit'),
        ),
      ],
    );
  }
}