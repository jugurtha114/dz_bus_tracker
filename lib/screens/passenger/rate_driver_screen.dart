// lib/screens/passenger/rate_driver_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';
import '../../providers/passenger_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/glassy_container.dart';
import '../../helpers/error_handler.dart';
import '../../widgets/common/custom_card.dart';

class RateDriverScreen extends StatefulWidget {
  final String driverId;
  final String? busId;
  final String? tripId;

  const RateDriverScreen({
    Key? key,
    required this.driverId,
    this.busId,
    this.tripId,
  }) : super(key: key);

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  double _rating = 3;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  // Rating aspects
  double _drivingRating = 3;
  double _safetyRating = 3;
  double _cleanlinessRating = 3;
  double _punctualityRating = 3;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a rating'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final passengerProvider = Provider.of<PassengerProvider>(context, listen: false);

      // Calculate average rating from all aspects
      _rating = (_drivingRating + _safetyRating + _cleanlinessRating + _punctualityRating) / 4;

      final success = await passengerProvider.rateDriver(
        driverId: widget.driverId,
        rating: _rating.round(),
        comment: _commentController.text.isNotEmpty ? _commentController.text : null,
      );

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Thank you for your feedback!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        // Go back
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
    return Scaffold(
      appBar: const DzAppBar(
        title: 'Rate Driver',
      ),
      body: Stack(
        children: [
          // Background with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ],
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Driver Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),

                const SizedBox(height: 16),

                // Driver name (in a real app, we would fetch this)
                Text(
                  'Your Driver',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Rating prompt
                Text(
                  'How was your ride?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 16),

                // Rating card
                CustomCard(type: CardType.elevated, 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Driving rating
                      _buildRatingItem(
                        'Driving',
                        'How was the driver\'s driving skill?',
                        _drivingRating,
                            (rating) {
                          setState(() {
                            _drivingRating = rating;
                          });
                        },
                      ),

                      const Divider(),

                      // Safety rating
                      _buildRatingItem(
                        'Safety',
                        'How safe did you feel during the trip?',
                        _safetyRating,
                            (rating) {
                          setState(() {
                            _safetyRating = rating;
                          });
                        },
                      ),

                      const Divider(),

                      // Cleanliness rating
                      _buildRatingItem(
                        'Cleanliness',
                        'How clean was the bus?',
                        _cleanlinessRating,
                            (rating) {
                          setState(() {
                            _cleanlinessRating = rating;
                          });
                        },
                      ),

                      const Divider(),

                      // Punctuality rating
                      _buildRatingItem(
                        'Punctuality',
                        'Was the bus on time?',
                        _punctualityRating,
                            (rating) {
                          setState(() {
                            _punctualityRating = rating;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Comment field
                CustomCard(type: CardType.elevated, 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Comments',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Share your experience...',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Submit button
                CustomButton(
        text: 'Submit Rating',
        onPressed: _submitRating,
        isLoading: _isLoading,
        ),

                const SizedBox(height: 16),

                // Skip button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Skip',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingItem(
      String title,
      String description,
      double value,
      Function(double) onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          // Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          const SizedBox(height: 16),

          // Rating bar
          Center(
            child: RatingBar.builder(
              initialRating: value,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: onChanged,
            ),
          ),

          // Rating value
          Center(
            child: Text(
              value.toStringAsFixed(1),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getRatingColor(value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4) {
      return Theme.of(context).colorScheme.primary;
    } else if (rating >= 3) {
      return Colors.amber;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }
}