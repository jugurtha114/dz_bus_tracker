// lib/screens/passenger/rate_driver_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system.dart';
import '../../config/route_config.dart';
import '../../providers/passenger_provider.dart';
import '../../providers/driver_provider.dart';
import '../../widgets/widgets.dart';
import '../../models/driver_model.dart';

/// Modern driver rating screen with comprehensive feedback system
class RateDriverScreen extends StatefulWidget {
  final String driverId;
  final String? busId;
  final String? tripId;

  const RateDriverScreen({
    super.key,
    required this.driverId,
    this.busId,
    this.tripId,
  });

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final _commentController = TextEditingController();
  bool _isLoading = false;
  Driver? _driverData;

  // Rating aspects
  double _overallRating = 0;
  double _drivingRating = 0;
  double _safetyRating = 0;
  double _cleanlinessRating = 0;
  double _punctualityRating = 0;
  double _courtesyRating = 0;

  // Selected quick feedback tags
  final Set<String> _selectedTags = {};
  final List<String> _quickFeedbackTags = [
    'Smooth driving',
    'On time',
    'Friendly',
    'Professional',
    'Clean bus',
    'Safe driving',
    'Helpful',
    'Good route knowledge',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadDriverDetails();
  }

  Future<void> _loadDriverDetails() async {
    try {
      final driverProvider = context.read<DriverProvider>();
      await driverProvider.fetchDriverById(widget.driverId);
      
      setState(() {
        _driverData = driverProvider.selectedDriver;
      });
    } catch (error) {
      // Driver details are optional for rating
      debugPrint('Failed to load driver details: $error');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Rate Your Experience',
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              // Driver header
              _buildDriverHeader(context),
              
              const SizedBox(height: DesignSystem.space24),
              
              // Overall rating
              _buildOverallRating(context),
              
              const SizedBox(height: DesignSystem.space24),
              
              // Detailed ratings
              _buildDetailedRatings(context),
              
              const SizedBox(height: DesignSystem.space24),
              
              // Quick feedback tags
              _buildQuickFeedback(context),
              
              const SizedBox(height: DesignSystem.space24),
              
              // Comment section
              _buildCommentSection(context),
              
              const SizedBox(height: DesignSystem.space32),
              
              // Action buttons
              _buildActionButtons(context),
              
              const SizedBox(height: DesignSystem.space16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverHeader(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space20),
        child: Column(
          children: [
            // Driver avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: _driverData?.profileImage != null
                  ? ClipOval(
                      child: Image.network(
                        _driverData!.profileImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(
                              Icons.person,
                              size: 40,
                              color: context.colors.onPrimaryContainer,
                            ),
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 40,
                      color: context.colors.onPrimaryContainer,
                    ),
            ),
            
            const SizedBox(height: DesignSystem.space16),
            
            // Driver name
            Text(
              _driverData?.name ?? 'Your Driver',
              style: context.textStyles.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            // Bus info
            if (widget.busId != null)
              Text(
                'Bus ${widget.busId}',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            
            const SizedBox(height: DesignSystem.space8),
            
            // Driver stats
            if (_driverData != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDriverStat(
                    'Rating',
                    '${_driverData!.rating?.toStringAsFixed(1) ?? '0.0'}',
                    Icons.star,
                  ),
                  _buildDriverStat(
                    'Trips',
                    '${_driverData!.totalTrips ?? 0}',
                    Icons.route,
                  ),
                  _buildDriverStat(
                    'Experience',
                    '${_driverData!.experienceYears ?? 0}y',
                    Icons.timeline,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: context.colors.primary,
        ),
        const SizedBox(height: DesignSystem.space4),
        Text(
          value,
          style: context.textStyles.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildOverallRating(BuildContext context) {
    return SectionLayout(
      title: 'Overall Experience',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space20),
          child: Column(
            children: [
              Text(
                'How was your ride?',
                style: context.textStyles.titleMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              
              const SizedBox(height: DesignSystem.space16),
              
              // Star rating
              _buildStarRating(
                rating: _overallRating,
                onRatingUpdate: (rating) {
                  setState(() {
                    _overallRating = rating;
                  });
                },
                size: 32,
              ),
              
              const SizedBox(height: DesignSystem.space8),
              
              // Rating description
              Text(
                _getRatingDescription(_overallRating),
                style: context.textStyles.bodyMedium?.copyWith(
                  color: _getRatingColor(_overallRating),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedRatings(BuildContext context) {
    return SectionLayout(
      title: 'Rate Different Aspects',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            children: [
              _buildRatingItem(
                'Driving Skill',
                'How smooth and skilled was the driving?',
                Icons.drive_eta,
                _drivingRating,
                (rating) => setState(() => _drivingRating = rating),
              ),
              
              const Divider(height: DesignSystem.space24),
              
              _buildRatingItem(
                'Safety',
                'How safe did you feel during the trip?',
                Icons.security,
                _safetyRating,
                (rating) => setState(() => _safetyRating = rating),
              ),
              
              const Divider(height: DesignSystem.space24),
              
              _buildRatingItem(
                'Punctuality',
                'Was the driver on time?',
                Icons.schedule,
                _punctualityRating,
                (rating) => setState(() => _punctualityRating = rating),
              ),
              
              const Divider(height: DesignSystem.space24),
              
              _buildRatingItem(
                'Cleanliness',
                'How clean was the bus?',
                Icons.cleaning_services,
                _cleanlinessRating,
                (rating) => setState(() => _cleanlinessRating = rating),
              ),
              
              const Divider(height: DesignSystem.space24),
              
              _buildRatingItem(
                'Courtesy',
                'How friendly and professional was the driver?',
                Icons.emoji_emotions,
                _courtesyRating,
                (rating) => setState(() => _courtesyRating = rating),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingItem(
    String title,
    String description,
    IconData icon,
    double rating,
    ValueChanged<double> onRatingUpdate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: context.colors.primary,
            ),
            const SizedBox(width: DesignSystem.space8),
            Expanded(
              child: Text(
                title,
                style: context.textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              rating > 0 ? rating.toStringAsFixed(1) : '',
              style: context.textStyles.bodyMedium?.copyWith(
                color: _getRatingColor(rating),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: DesignSystem.space4),
        
        Text(
          description,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        
        const SizedBox(height: DesignSystem.space12),
        
        _buildStarRating(
          rating: rating,
          onRatingUpdate: onRatingUpdate,
        ),
      ],
    );
  }

  Widget _buildStarRating({
    required double rating,
    required ValueChanged<double> onRatingUpdate,
    double size = 24,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => onRatingUpdate(index + 1.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: index < rating ? Colors.amber : context.colors.outline,
              size: size,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuickFeedback(BuildContext context) {
    return SectionLayout(
      title: 'Quick Feedback',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What did you like? (Optional)',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              
              const SizedBox(height: DesignSystem.space12),
              
              Wrap(
                spacing: DesignSystem.space8,
                runSpacing: DesignSystem.space8,
                children: _quickFeedbackTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    selectedColor: context.colors.primaryContainer,
                    backgroundColor: context.colors.surfaceContainerHighest,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentSection(BuildContext context) {
    return SectionLayout(
      title: 'Additional Comments',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share your experience (Optional)',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              
              const SizedBox(height: DesignSystem.space12),
              
              AppInput(
                controller: _commentController,
                label: 'Tell us about your ride...',
                maxLines: 4,
                textInputAction: TextInputAction.newline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final hasRating = _overallRating > 0 || 
                     _drivingRating > 0 || 
                     _safetyRating > 0 || 
                     _punctualityRating > 0 || 
                     _cleanlinessRating > 0 || 
                     _courtesyRating > 0;

    return Column(
      children: [
        AppButton(
          text: 'Submit Rating',
          onPressed: hasRating ? _submitRating : null,
          isLoading: _isLoading,
          icon: Icons.send,
        ),
        
        const SizedBox(height: DesignSystem.space8),
        
        AppButton.text(
          text: 'Skip for Now',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  String _getRatingDescription(double rating) {
    if (rating == 0) return 'Tap to rate';
    if (rating <= 1) return 'Poor';
    if (rating <= 2) return 'Fair';
    if (rating <= 3) return 'Good';
    if (rating <= 4) return 'Very Good';
    return 'Excellent';
  }

  Color _getRatingColor(double rating) {
    if (rating == 0) return context.colors.onSurfaceVariant;
    if (rating <= 2) return context.colors.error;
    if (rating <= 3) return context.warningColor;
    return context.successColor;
  }

  Future<void> _submitRating() async {
    // Calculate overall rating if not set
    double finalRating = _overallRating;
    if (finalRating == 0) {
      final ratings = [_drivingRating, _safetyRating, _punctualityRating, _cleanlinessRating, _courtesyRating];
      final validRatings = ratings.where((r) => r > 0).toList();
      if (validRatings.isNotEmpty) {
        finalRating = validRatings.reduce((a, b) => a + b) / validRatings.length;
      }
    }

    if (finalRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide at least one rating')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final passengerProvider = context.read<PassengerProvider>();
      
      final ratingData = {
        'overall': finalRating,
        'driving': _drivingRating,
        'safety': _safetyRating,
        'punctuality': _punctualityRating,
        'cleanliness': _cleanlinessRating,
        'courtesy': _courtesyRating,
        'comment': _commentController.text.trim(),
        'tags': _selectedTags.toList(),
        'busId': widget.busId,
        'tripId': widget.tripId,
      };

      await passengerProvider.submitDriverRating(
        driverId: widget.driverId,
        rating: _overallRating,
        comment: _commentController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate back with delay to show success message
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit rating: $error')),
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