// lib/models/gamification_model.dart

import 'package:flutter/material.dart';

/// Achievement types for gamification system
enum AchievementType {
  trips('trips', 'Number of Trips'),
  distance('distance', 'Distance Traveled'),
  streak('streak', 'Day Streak'),
  eco('eco', 'Environmental Impact'),
  social('social', 'Social Engagement'),
  special('special', 'Special Achievement'),
  level('level', 'Level Based');

  const AchievementType(this.value, this.displayName);
  final String value;
  final String displayName;

  static AchievementType fromValue(String value) {
    return AchievementType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AchievementType.special,
    );
  }
}

/// Rarity levels for achievements and rewards
enum Rarity {
  common('common', 'Common'),
  uncommon('uncommon', 'Uncommon'),
  rare('rare', 'Rare'),
  epic('epic', 'Epic'),
  legendary('legendary', 'Legendary');

  const Rarity(this.value, this.displayName);
  final String value;
  final String displayName;

  static Rarity fromValue(String value) {
    return Rarity.values.firstWhere(
      (rarity) => rarity.value == value,
      orElse: () => Rarity.common,
    );
  }
}

/// Challenge types
enum ChallengeType {
  individual('individual', 'Individual Challenge'),
  community('community', 'Community Challenge'),
  route('route', 'Route Challenge'),
  eco('eco', 'Eco Challenge');

  const ChallengeType(this.value, this.displayName);
  final String value;
  final String displayName;

  static ChallengeType fromValue(String value) {
    return ChallengeType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ChallengeType.individual,
    );
  }
}

/// Reward types
enum RewardType {
  discount('discount', 'Discount Code'),
  freeRide('free_ride', 'Free Ride'),
  merchandise('merchandise', 'Merchandise'),
  donation('donation', 'Charity Donation'),
  special('special', 'Special Reward');

  const RewardType(this.value, this.displayName);
  final String value;
  final String displayName;

  static RewardType fromValue(String value) {
    return RewardType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => RewardType.special,
    );
  }
}

/// Transaction types for point transactions
enum TransactionType {
  tripComplete('trip_complete', 'Trip Completed'),
  achievement('achievement', 'Achievement Unlocked'),
  dailyBonus('daily_bonus', 'Daily Bonus'),
  streakBonus('streak_bonus', 'Streak Bonus'),
  referral('referral', 'Referral Bonus'),
  specialEvent('special_event', 'Special Event'),
  penalty('penalty', 'Penalty');

  const TransactionType(this.value, this.displayName);
  final String value;
  final String displayName;

  static TransactionType fromValue(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TransactionType.specialEvent,
    );
  }
}

/// User type enum
enum UserType {
  admin('admin', 'Admin'),
  driver('driver', 'Driver'),
  passenger('passenger', 'Passenger');

  const UserType(this.value, this.displayName);
  final String value;
  final String displayName;

  static UserType fromValue(String value) {
    return UserType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => UserType.passenger,
    );
  }
}

/// Achievement model for gamification
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementType achievementType;
  final int? thresholdValue;
  final int? pointsReward;
  final Rarity? rarity;
  final bool isUnlocked;
  final int progress;
  final double progressPercentage;

  // Convenience getters for UI compatibility
  String get title => name;
  int get points => pointsReward ?? 0;
  
  // Category mapping based on achievement type
  String get category {
    switch (achievementType) {
      case AchievementType.trips:
        return 'trips';
      case AchievementType.distance:
        return 'travel';
      case AchievementType.eco:
        return 'eco';
      case AchievementType.social:
        return 'social';
      case AchievementType.streak:
        return 'travel';
      default:
        return 'general';
    }
  }

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.achievementType,
    this.thresholdValue,
    this.pointsReward,
    this.rarity,
    required this.isUnlocked,
    required this.progress,
    required this.progressPercentage,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      achievementType: AchievementType.fromValue(
        json['achievement_type'] as String,
      ),
      thresholdValue: json['threshold_value'] as int?,
      pointsReward: json['points_reward'] as int?,
      rarity: json['rarity'] != null
          ? Rarity.fromValue(json['rarity'] as String)
          : null,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      progress: json['progress'] as int? ?? 0,
      progressPercentage:
          (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'achievement_type': achievementType.value,
      'threshold_value': thresholdValue,
      'points_reward': pointsReward,
      'rarity': rarity?.value,
      'is_unlocked': isUnlocked,
      'progress': progress,
      'progress_percentage': progressPercentage,
    };
  }

  // Helper getters
  Color get rarityColor {
    switch (rarity) {
      case Rarity.common:
        return Colors.grey;
      case Rarity.uncommon:
        return Colors.green;
      case Rarity.rare:
        return Colors.blue;
      case Rarity.epic:
        return Colors.purple;
      case Rarity.legendary:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData get typeIcon {
    switch (achievementType) {
      case AchievementType.trips:
        return Icons.route;
      case AchievementType.distance:
        return Icons.straighten;
      case AchievementType.streak:
        return Icons.local_fire_department;
      case AchievementType.eco:
        return Icons.eco;
      case AchievementType.social:
        return Icons.people;
      case AchievementType.special:
        return Icons.star;
      case AchievementType.level:
        return Icons.trending_up;
    }
  }

  String get statusText => isUnlocked ? 'Unlocked' : 'Locked';
  Color get statusColor => isUnlocked ? Colors.green : Colors.grey;

  String get progressText =>
      '$progress${thresholdValue != null ? '/${thresholdValue}' : ''}';
  String get progressPercentageText =>
      '${progressPercentage.toStringAsFixed(1)}%';

  bool get isCompleted => progressPercentage >= 100.0;
  bool get isNearCompletion => progressPercentage >= 80.0 && !isCompleted;

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    AchievementType? achievementType,
    int? thresholdValue,
    int? pointsReward,
    Rarity? rarity,
    bool? isUnlocked,
    int? progress,
    double? progressPercentage,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      achievementType: achievementType ?? this.achievementType,
      thresholdValue: thresholdValue ?? this.thresholdValue,
      pointsReward: pointsReward ?? this.pointsReward,
      rarity: rarity ?? this.rarity,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }
}

/// Challenge model for gamification
class Challenge {
  final String id;
  final String name;
  final String description;
  final ChallengeType challengeType;
  final DateTime startDate;
  final DateTime endDate;
  final int targetValue;
  final int currentValue;
  final String progressPercentage;
  final int pointsReward;
  final bool isActive;
  final bool isCompleted;
  final bool isJoined;
  final Map<String, dynamic> userProgress;
  final int participantsCount;
  final String timeRemaining;

  const Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.challengeType,
    required this.startDate,
    required this.endDate,
    required this.targetValue,
    required this.currentValue,
    required this.progressPercentage,
    required this.pointsReward,
    required this.isActive,
    required this.isCompleted,
    required this.isJoined,
    required this.userProgress,
    required this.participantsCount,
    required this.timeRemaining,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      challengeType: ChallengeType.fromValue(json['challenge_type'] as String),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      targetValue: json['target_value'] as int? ?? 0,
      currentValue: json['current_value'] as int? ?? 0,
      progressPercentage: json['progress_percentage'] as String? ?? '0%',
      pointsReward: json['points_reward'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? false,
      isCompleted: json['is_completed'] as bool? ?? false,
      isJoined: json['is_joined'] as bool? ?? false,
      userProgress: json['user_progress'] as Map<String, dynamic>? ?? {},
      participantsCount: json['participants_count'] as int? ?? 0,
      timeRemaining: json['time_remaining'] as String? ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'challenge_type': challengeType.value,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'target_value': targetValue,
      'current_value': currentValue,
      'progress_percentage': progressPercentage,
      'points_reward': pointsReward,
      'is_active': isActive,
      'is_completed': isCompleted,
      'is_joined': isJoined,
      'user_progress': userProgress,
      'participants_count': participantsCount,
      'time_remaining': timeRemaining,
    };
  }

  // Helper getters
  Color get typeColor {
    switch (challengeType) {
      case ChallengeType.individual:
        return Colors.blue;
      case ChallengeType.community:
        return Colors.green;
      case ChallengeType.route:
        return Colors.orange;
      case ChallengeType.eco:
        return Colors.teal;
    }
  }

  IconData get typeIcon {
    switch (challengeType) {
      case ChallengeType.individual:
        return Icons.person;
      case ChallengeType.community:
        return Icons.group;
      case ChallengeType.route:
        return Icons.route;
      case ChallengeType.eco:
        return Icons.eco;
    }
  }

  String get statusText {
    if (isCompleted) return 'Completed';
    if (isActive) return 'Active';
    return 'Upcoming';
  }

  Color get statusColor {
    if (isCompleted) return Colors.green;
    if (isActive) return Colors.blue;
    return Colors.grey;
  }

  Duration get duration => endDate.difference(startDate);
  Duration? get timeLeft =>
      isActive ? endDate.difference(DateTime.now()) : null;

  String get formattedStartDate =>
      '${startDate.day}/${startDate.month}/${startDate.year}';
  String get formattedEndDate =>
      '${endDate.day}/${endDate.month}/${endDate.year}';
  String get formattedDuration => '${duration.inDays} days';

  double get progressValue {
    if (targetValue == 0) return 0.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  bool get canJoin => isActive && !isJoined && !isCompleted;
  bool get hasStarted => DateTime.now().isAfter(startDate);
  bool get hasEnded => DateTime.now().isAfter(endDate);

  Challenge copyWith({
    String? id,
    String? name,
    String? description,
    ChallengeType? challengeType,
    DateTime? startDate,
    DateTime? endDate,
    int? targetValue,
    int? currentValue,
    String? progressPercentage,
    int? pointsReward,
    bool? isActive,
    bool? isCompleted,
    bool? isJoined,
    Map<String, dynamic>? userProgress,
    int? participantsCount,
    String? timeRemaining,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      challengeType: challengeType ?? this.challengeType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      pointsReward: pointsReward ?? this.pointsReward,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      isJoined: isJoined ?? this.isJoined,
      userProgress: userProgress ?? this.userProgress,
      participantsCount: participantsCount ?? this.participantsCount,
      timeRemaining: timeRemaining ?? this.timeRemaining,
    );
  }
}

/// Reward model for gamification
class Reward {
  final String id;
  final String name;
  final String description;
  final RewardType rewardType;
  final int pointsCost;
  final int quantityAvailable;
  final int quantityRedeemed;
  final DateTime validFrom;
  final DateTime validUntil;
  final String? image;
  final String? partnerName;
  final String isAvailable;
  final bool canAfford;

  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.rewardType,
    required this.pointsCost,
    required this.quantityAvailable,
    required this.quantityRedeemed,
    required this.validFrom,
    required this.validUntil,
    this.image,
    this.partnerName,
    required this.isAvailable,
    required this.canAfford,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      rewardType: RewardType.fromValue(json['reward_type'] as String),
      pointsCost: json['points_cost'] as int? ?? 0,
      quantityAvailable: json['quantity_available'] as int? ?? 0,
      quantityRedeemed: json['quantity_redeemed'] as int? ?? 0,
      validFrom: DateTime.parse(json['valid_from'] as String),
      validUntil: DateTime.parse(json['valid_until'] as String),
      image: json['image'] as String?,
      partnerName: json['partner_name'] as String?,
      isAvailable: json['is_available'] as String? ?? 'false',
      canAfford: json['can_afford'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'reward_type': rewardType.value,
      'points_cost': pointsCost,
      'quantity_available': quantityAvailable,
      'quantity_redeemed': quantityRedeemed,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'image': image,
      'partner_name': partnerName,
      'is_available': isAvailable,
      'can_afford': canAfford,
    };
  }

  // Helper getters
  Color get typeColor {
    switch (rewardType) {
      case RewardType.discount:
        return Colors.green;
      case RewardType.freeRide:
        return Colors.blue;
      case RewardType.merchandise:
        return Colors.purple;
      case RewardType.donation:
        return Colors.red;
      case RewardType.special:
        return Colors.orange;
    }
  }

  IconData get typeIcon {
    switch (rewardType) {
      case RewardType.discount:
        return Icons.local_offer;
      case RewardType.freeRide:
        return Icons.directions_bus;
      case RewardType.merchandise:
        return Icons.card_giftcard;
      case RewardType.donation:
        return Icons.favorite;
      case RewardType.special:
        return Icons.star;
    }
  }

  bool get isCurrentlyAvailable => isAvailable.toLowerCase() == 'true';
  bool get isValidNow {
    final now = DateTime.now();
    return now.isAfter(validFrom) && now.isBefore(validUntil);
  }

  bool get isExpired => DateTime.now().isAfter(validUntil);
  bool get isUpcoming => DateTime.now().isBefore(validFrom);

  int get remainingQuantity =>
      quantityAvailable == -1 ? -1 : quantityAvailable - quantityRedeemed;
  bool get isOutOfStock => quantityAvailable != -1 && remainingQuantity <= 0;
  bool get isUnlimited => quantityAvailable == -1;

  String get availabilityText {
    if (isExpired) return 'Expired';
    if (isUpcoming) return 'Coming Soon';
    if (isOutOfStock) return 'Out of Stock';
    if (!canAfford) return 'Insufficient Points';
    return 'Available';
  }

  Color get availabilityColor {
    if (isExpired || isOutOfStock) return Colors.red;
    if (isUpcoming) return Colors.orange;
    if (!canAfford) return Colors.grey;
    return Colors.green;
  }

  String get quantityText {
    if (isUnlimited) return 'Unlimited';
    return '$remainingQuantity remaining';
  }

  String get formattedValidFrom =>
      '${validFrom.day}/${validFrom.month}/${validFrom.year}';
  String get formattedValidUntil =>
      '${validUntil.day}/${validUntil.month}/${validUntil.year}';
  String get validityPeriod => '$formattedValidFrom - $formattedValidUntil';

  bool get canRedeem =>
      isCurrentlyAvailable && canAfford && isValidNow && !isOutOfStock;

  Reward copyWith({
    String? id,
    String? name,
    String? description,
    RewardType? rewardType,
    int? pointsCost,
    int? quantityAvailable,
    int? quantityRedeemed,
    DateTime? validFrom,
    DateTime? validUntil,
    String? image,
    String? partnerName,
    String? isAvailable,
    bool? canAfford,
  }) {
    return Reward(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      rewardType: rewardType ?? this.rewardType,
      pointsCost: pointsCost ?? this.pointsCost,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      quantityRedeemed: quantityRedeemed ?? this.quantityRedeemed,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      image: image ?? this.image,
      partnerName: partnerName ?? this.partnerName,
      isAvailable: isAvailable ?? this.isAvailable,
      canAfford: canAfford ?? this.canAfford,
    );
  }
}

/// Point transaction model
class PointTransaction {
  final String id;
  final TransactionType transactionType;
  final int points;
  final String description;
  final DateTime createdAt;

  const PointTransaction({
    required this.id,
    required this.transactionType,
    required this.points,
    required this.description,
    required this.createdAt,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] as String,
      transactionType: TransactionType.fromValue(
        json['transaction_type'] as String,
      ),
      points: json['points'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_type': transactionType.value,
      'points': points,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper getters
  bool get isPositive => points > 0;
  bool get isNegative => points < 0;

  Color get pointsColor => isPositive ? Colors.green : Colors.red;
  String get pointsText => '${isPositive ? '+' : ''}$points';

  IconData get typeIcon {
    switch (transactionType) {
      case TransactionType.tripComplete:
        return Icons.route;
      case TransactionType.achievement:
        return Icons.star;
      case TransactionType.dailyBonus:
        return Icons.today;
      case TransactionType.streakBonus:
        return Icons.local_fire_department;
      case TransactionType.referral:
        return Icons.person_add;
      case TransactionType.specialEvent:
        return Icons.celebration;
      case TransactionType.penalty:
        return Icons.remove_circle;
    }
  }

  Color get typeColor {
    switch (transactionType) {
      case TransactionType.tripComplete:
        return Colors.blue;
      case TransactionType.achievement:
        return Colors.orange;
      case TransactionType.dailyBonus:
        return Colors.green;
      case TransactionType.streakBonus:
        return Colors.red;
      case TransactionType.referral:
        return Colors.purple;
      case TransactionType.specialEvent:
        return Colors.pink;
      case TransactionType.penalty:
        return Colors.grey;
    }
  }

  String get formattedDate =>
      '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  String get formattedTime =>
      '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  String get formattedDateTime => '$formattedDate $formattedTime';

  PointTransaction copyWith({
    String? id,
    TransactionType? transactionType,
    int? points,
    String? description,
    DateTime? createdAt,
  }) {
    return PointTransaction(
      id: id ?? this.id,
      transactionType: transactionType ?? this.transactionType,
      points: points ?? this.points,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// User brief model
class UserBrief {
  final String id;
  final String email;
  final String fullName;
  final UserType? userType;

  const UserBrief({
    required this.id,
    required this.email,
    required this.fullName,
    this.userType,
  });

  factory UserBrief.fromJson(Map<String, dynamic> json) {
    return UserBrief(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      userType: json['user_type'] != null
          ? UserType.fromValue(json['user_type'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'user_type': userType?.value,
    };
  }
}

/// User profile model for gamification
class UserProfile {
  final String id;
  final UserBrief user;
  final int totalPoints;
  final int currentLevel;
  final int experiencePoints;
  final int nextLevelPoints;
  final int levelProgress;
  final int totalTrips;
  final double totalDistance;
  final double carbonSaved;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastTripDate;
  final bool receiveAchievementNotifications;
  final bool displayOnLeaderboard;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Convenience getters for UI compatibility
  int get level => currentLevel;
  int get points => totalPoints;
  int get streak => currentStreak;
  double get carbonFootprintSaved => carbonSaved;
  double get nextLevelProgress => levelProgress / 100.0;

  const UserProfile({
    required this.id,
    required this.user,
    required this.totalPoints,
    required this.currentLevel,
    required this.experiencePoints,
    required this.nextLevelPoints,
    required this.levelProgress,
    required this.totalTrips,
    required this.totalDistance,
    required this.carbonSaved,
    required this.currentStreak,
    required this.longestStreak,
    this.lastTripDate,
    required this.receiveAchievementNotifications,
    required this.displayOnLeaderboard,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      user: UserBrief.fromJson(json['user'] as Map<String, dynamic>),
      totalPoints: json['total_points'] as int? ?? 0,
      currentLevel: json['current_level'] as int? ?? 1,
      experiencePoints: json['experience_points'] as int? ?? 0,
      nextLevelPoints: json['next_level_points'] as int? ?? 0,
      levelProgress: json['level_progress'] as int? ?? 0,
      totalTrips: json['total_trips'] as int? ?? 0,
      totalDistance:
          double.tryParse(json['total_distance']?.toString() ?? '0') ?? 0.0,
      carbonSaved:
          double.tryParse(json['carbon_saved']?.toString() ?? '0') ?? 0.0,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastTripDate: json['last_trip_date'] != null
          ? DateTime.parse(json['last_trip_date'] as String)
          : null,
      receiveAchievementNotifications:
          json['receive_achievement_notifications'] as bool? ?? true,
      displayOnLeaderboard: json['display_on_leaderboard'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'total_points': totalPoints,
      'current_level': currentLevel,
      'experience_points': experiencePoints,
      'next_level_points': nextLevelPoints,
      'level_progress': levelProgress,
      'total_trips': totalTrips,
      'total_distance': totalDistance.toString(),
      'carbon_saved': carbonSaved.toString(),
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_trip_date': lastTripDate?.toIso8601String(),
      'receive_achievement_notifications': receiveAchievementNotifications,
      'display_on_leaderboard': displayOnLeaderboard,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  String get formattedTotalDistance => '${totalDistance.toStringAsFixed(1)} km';
  String get formattedCarbonSaved => '${carbonSaved.toStringAsFixed(1)} kg';

  String get levelProgressText => '$levelProgress%';
  double get levelProgressValue => levelProgress / 100.0;

  int get pointsToNextLevel => nextLevelPoints - experiencePoints;
  String get pointsToNextLevelText =>
      '$pointsToNextLevel points to level ${currentLevel + 1}';

  bool get hasRecentTrip =>
      lastTripDate != null &&
      DateTime.now().difference(lastTripDate!).inDays < 7;

  String get streakText => '$currentStreak day${currentStreak != 1 ? 's' : ''}';
  String get longestStreakText =>
      '$longestStreak day${longestStreak != 1 ? 's' : ''}';

  String get lastTripText => lastTripDate != null
      ? '${lastTripDate!.day}/${lastTripDate!.month}/${lastTripDate!.year}'
      : 'No trips yet';

  UserProfile copyWith({
    String? id,
    UserBrief? user,
    int? totalPoints,
    int? currentLevel,
    int? experiencePoints,
    int? nextLevelPoints,
    int? levelProgress,
    int? totalTrips,
    double? totalDistance,
    double? carbonSaved,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastTripDate,
    bool? receiveAchievementNotifications,
    bool? displayOnLeaderboard,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      user: user ?? this.user,
      totalPoints: totalPoints ?? this.totalPoints,
      currentLevel: currentLevel ?? this.currentLevel,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      nextLevelPoints: nextLevelPoints ?? this.nextLevelPoints,
      levelProgress: levelProgress ?? this.levelProgress,
      totalTrips: totalTrips ?? this.totalTrips,
      totalDistance: totalDistance ?? this.totalDistance,
      carbonSaved: carbonSaved ?? this.carbonSaved,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastTripDate: lastTripDate ?? this.lastTripDate,
      receiveAchievementNotifications:
          receiveAchievementNotifications ??
          this.receiveAchievementNotifications,
      displayOnLeaderboard: displayOnLeaderboard ?? this.displayOnLeaderboard,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Leaderboard entry model
class LeaderboardEntry {
  final String userId;
  final String userName;
  final int points;
  final int rank;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.points,
    required this.rank,
    required this.isCurrentUser,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      points: json['points'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      isCurrentUser: json['is_current_user'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'points': points,
      'rank': rank,
      'is_current_user': isCurrentUser,
    };
  }

  // Helper getters
  String get rankText {
    switch (rank) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      default:
        return '${rank}th';
    }
  }

  Color get rankColor {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  IconData? get rankIcon {
    switch (rank) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      default:
        return null;
    }
  }

  bool get isTopThree => rank <= 3;
}

/// Request models for gamification operations

class UserProfileUpdateRequest {
  final bool? receiveAchievementNotifications;
  final bool? displayOnLeaderboard;

  const UserProfileUpdateRequest({
    this.receiveAchievementNotifications,
    this.displayOnLeaderboard,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (receiveAchievementNotifications != null) {
      json['receive_achievement_notifications'] =
          receiveAchievementNotifications;
    }
    if (displayOnLeaderboard != null) {
      json['display_on_leaderboard'] = displayOnLeaderboard;
    }
    return json;
  }
}

class TripCompletionRequest {
  final String tripId;
  final double? distance;
  final int? duration;

  const TripCompletionRequest({
    required this.tripId,
    this.distance,
    this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'trip_id': tripId,
      if (distance != null) 'distance': distance.toString(),
      if (duration != null) 'duration': duration,
    };
  }
}
