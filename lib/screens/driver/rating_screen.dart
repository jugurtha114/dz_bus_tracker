// lib/screens/driver/rating_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme_config.dart';
import '../../providers/driver_provider.dart';
import '../../widgets/common/app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../helpers/error_handler.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({Key? key}) : super(key: key);

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      await driverProvider.fetchRatings();
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
    final driverProvider = Provider.of<DriverProvider>(context);
    final ratings = driverProvider.ratings;
    final driverRating = driverProvider.rating;

    return Scaffold(
      appBar: const DzAppBar(
        title: 'My Ratings',
      ),
      body: _isLoading
          ? const Center(
        child: LoadingIndicator(),
      )
          : Column(
        children: [
          // Rating summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkGrey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Star rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                        (index) => Icon(
                      index < driverRating ? Icons.star : Icons.star_border,
                      color: AppColors.white,
                      size: 32,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Rating value
                Text(
                  '${driverRating.toStringAsFixed(1)} / 5.0',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                // Ratings count
                Text(
                  'Based on ${ratings.length} ${ratings.length == 1 ? 'rating' : 'ratings'}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Rating breakdown
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildRatingBreakdown(ratings),
          ),

          // Recent ratings
          Expanded(
            child: ratings.isEmpty
                ? Center(
              child: Text(
                'No ratings yet',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.mediumGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ratings.length,
              itemBuilder: (context, index) {
                final rating = ratings[index];
                return _buildRatingItem(rating);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdown(List<Map<String, dynamic>> ratings) {
    // Count ratings by stars
    final Map<int, int> ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (final rating in ratings) {
      final stars = rating['rating'] as int? ?? 0;
      ratingCounts[stars] = (ratingCounts[stars] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating Breakdown',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.darkGrey,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // 5 to 1 star bars
        for (int i = 5; i >= 1; i--)
          _buildRatingBar(i, ratingCounts[i] ?? 0, ratings.length),
      ],
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    final percentage = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Star count
          Row(
            children: [
              Text(
                '$stars',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.star,
                color: AppColors.warning,
                size: 16,
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Progress bar
          Expanded(
            child: Stack(
              children: [
                // Background
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                // Fill
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getRatingColor(stars),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Count
          Text(
            count.toString(),
            style: AppTextStyles.body.copyWith(
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingItem(Map<String, dynamic> rating) {
    final stars = rating['rating'] as int? ?? 0;
    final comment = rating['comment'] as String? ?? '';

    // Format date
    final createdAt = rating['created_at'] != null
        ? DateTime.parse(rating['created_at'].toString())
        : DateTime.now();
    final formattedDate = DateFormat('MMM d, yyyy').format(createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stars and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Star rating
                Row(
                  children: List.generate(
                    5,
                        (index) => Icon(
                      index < stars ? Icons.star : Icons.star_border,
                      color: _getRatingColor(stars),
                      size: 20,
                    ),
                  ),
                ),

                // Date
                Text(
                  formattedDate,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),

            // Comment
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                comment,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.darkGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(int stars) {
    if (stars >= 4) {
      return AppColors.success;
    } else if (stars >= 3) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
}