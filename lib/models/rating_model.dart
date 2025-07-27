// lib/models/rating_model.dart

/// Model for driver/service ratings
class Rating {
  final String id;
  final String userId;
  final String driverId;
  final String? tripId;
  final String? busId;
  final double rating; // 1-5 stars
  final String? comment;
  final List<String> categories; // punctuality, cleanliness, driving, etc.
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isAnonymous;

  const Rating({
    required this.id,
    required this.userId,
    required this.driverId,
    this.tripId,
    this.busId,
    required this.rating,
    this.comment,
    this.categories = const [],
    required this.createdAt,
    this.updatedAt,
    this.isAnonymous = false,
  });

  /// Check if rating is positive (4+ stars)
  bool get isPositive => rating >= 4.0;

  /// Check if rating is negative (2 or less stars)
  bool get isNegative => rating <= 2.0;

  /// Get rating as integer (for star display)
  int get ratingAsInt => rating.round();

  /// Get rating category
  String get ratingCategory {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 3.5) return 'Good';
    if (rating >= 2.5) return 'Average';
    if (rating >= 1.5) return 'Poor';
    return 'Very Poor';
  }

  /// Create from JSON
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      driverId: json['driverId'] ?? '',
      tripId: json['tripId'],
      busId: json['busId'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'],
      categories: List<String>.from(json['categories'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isAnonymous: json['isAnonymous'] ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'driverId': driverId,
      'tripId': tripId,
      'busId': busId,
      'rating': rating,
      'comment': comment,
      'categories': categories,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isAnonymous': isAnonymous,
    };
  }

  /// Create a copy with updated fields
  Rating copyWith({
    String? id,
    String? userId,
    String? driverId,
    String? tripId,
    String? busId,
    double? rating,
    String? comment,
    List<String>? categories,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAnonymous,
  }) {
    return Rating(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      driverId: driverId ?? this.driverId,
      tripId: tripId ?? this.tripId,
      busId: busId ?? this.busId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rating &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Rating{id: $id, rating: $rating, driverId: $driverId}';
  }
}

/// Rating summary for a driver
class RatingSummary {
  final String driverId;
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution; // star => count
  final List<String> topComments;
  final List<String> topCategories;
  final DateTime lastUpdated;

  const RatingSummary({
    required this.driverId,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
    required this.topComments,
    required this.topCategories,
    required this.lastUpdated,
  });

  /// Get percentage for a specific star rating
  double getPercentageForRating(int stars) {
    if (totalRatings == 0) return 0.0;
    final count = ratingDistribution[stars] ?? 0;
    return (count / totalRatings) * 100;
  }

  /// Check if driver has good ratings (4+ average)
  bool get hasGoodRatings => averageRating >= 4.0;

  /// Get rating category
  String get ratingCategory {
    if (averageRating >= 4.5) return 'Excellent';
    if (averageRating >= 3.5) return 'Good';
    if (averageRating >= 2.5) return 'Average';
    if (averageRating >= 1.5) return 'Poor';
    return 'Very Poor';
  }

  /// Create from JSON
  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    return RatingSummary(
      driverId: json['driverId'] ?? '',
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      ratingDistribution: Map<int, int>.from(json['ratingDistribution'] ?? {}),
      topComments: List<String>.from(json['topComments'] ?? []),
      topCategories: List<String>.from(json['topCategories'] ?? []),
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'ratingDistribution': ratingDistribution,
      'topComments': topComments,
      'topCategories': topCategories,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

/// Available rating categories
class RatingCategories {
  static const String punctuality = 'punctuality';
  static const String cleanliness = 'cleanliness';
  static const String driving = 'driving';
  static const String courtesy = 'courtesy';
  static const String comfort = 'comfort';
  static const String safety = 'safety';

  static const List<String> all = [
    punctuality,
    cleanliness,
    driving,
    courtesy,
    comfort,
    safety,
  ];

  static String getDisplayName(String category) {
    switch (category) {
      case punctuality:
        return 'Punctuality';
      case cleanliness:
        return 'Cleanliness';
      case driving:
        return 'Driving';
      case courtesy:
        return 'Courtesy';
      case comfort:
        return 'Comfort';
      case safety:
        return 'Safety';
      default:
        return category;
    }
  }
}