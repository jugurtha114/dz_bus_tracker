// lib/services/gamification_service.dart

import '../config/api_config.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';
import '../models/gamification_model.dart';
import '../models/api_response_models.dart';

class GamificationService {
  final ApiClient _apiClient;

  GamificationService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Achievement management methods

  /// Get all achievements with optional filtering
  Future<ApiResponse<PaginatedResponse<Achievement>>> getAchievements({
    AchievementQueryParameters? queryParams,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.achievements),
        queryParameters: queryParams?.toMap(),
      );

      final paginatedResponse = PaginatedResponse<Achievement>.fromJson(
        response,
        (json) => Achievement.fromJson(json as Map<String, dynamic>),
      );

      return ApiResponse.success(data: paginatedResponse);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get achievements: ${e.toString()}');
    }
  }

  /// Get achievement by ID
  Future<ApiResponse<Achievement>> getAchievementById(String achievementId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.achievementById(achievementId)));
      final achievement = Achievement.fromJson(response);
      return ApiResponse.success(data: achievement);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get achievement details: ${e.toString()}');
    }
  }

  /// Get user's achievement progress
  Future<ApiResponse<List<Achievement>>> getAchievementProgress() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.achievementProgress));
      
      List<Achievement> achievements = [];
      if (response is List) {
        achievements = response
            .map((item) => Achievement.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic> && response.containsKey('results')) {
        final results = response['results'] as List<dynamic>;
        achievements = results
            .map((item) => Achievement.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return ApiResponse.success(data: achievements);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get achievement progress: ${e.toString()}');
    }
  }

  /// Get unlocked achievements
  Future<ApiResponse<List<Achievement>>> getUnlockedAchievements() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.unlockedAchievements));
      
      List<Achievement> achievements = [];
      if (response is List) {
        achievements = response
            .map((item) => Achievement.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic> && response.containsKey('results')) {
        final results = response['results'] as List<dynamic>;
        achievements = results
            .map((item) => Achievement.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return ApiResponse.success(data: achievements);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get unlocked achievements: ${e.toString()}');
    }
  }

  // Challenge management methods

  /// Get all challenges with optional filtering
  Future<ApiResponse<PaginatedResponse<Challenge>>> getChallenges({
    ChallengeQueryParameters? queryParams,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.challenges),
        queryParameters: queryParams?.toMap(),
      );

      final paginatedResponse = PaginatedResponse<Challenge>.fromJson(
        response,
        (json) => Challenge.fromJson(json as Map<String, dynamic>),
      );

      return ApiResponse.success(data: paginatedResponse);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get challenges: ${e.toString()}');
    }
  }

  /// Get challenge by ID
  Future<ApiResponse<Challenge>> getChallengeById(String challengeId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.challengeById(challengeId)));
      final challenge = Challenge.fromJson(response);
      return ApiResponse.success(data: challenge);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get challenge details: ${e.toString()}');
    }
  }

  /// Join a challenge
  Future<ApiResponse<Challenge>> joinChallenge(String challengeId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.joinChallenge(challengeId)),
        body: {},
      );

      final challenge = Challenge.fromJson(response);
      return ApiResponse.success(data: challenge);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to join challenge: ${e.toString()}');
    }
  }

  /// Get user's challenges
  Future<ApiResponse<List<Challenge>>> getMyChallenges() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.myChallenges));
      
      List<Challenge> challenges = [];
      if (response is List) {
        challenges = response
            .map((item) => Challenge.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic> && response.containsKey('results')) {
        final results = response['results'] as List<dynamic>;
        challenges = results
            .map((item) => Challenge.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return ApiResponse.success(data: challenges);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get my challenges: ${e.toString()}');
    }
  }

  // Reward management methods

  /// Get all rewards with optional filtering
  Future<ApiResponse<PaginatedResponse<Reward>>> getRewards({
    RewardQueryParameters? queryParams,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.rewards),
        queryParameters: queryParams?.toMap(),
      );

      final paginatedResponse = PaginatedResponse<Reward>.fromJson(
        response,
        (json) => Reward.fromJson(json as Map<String, dynamic>),
      );

      return ApiResponse.success(data: paginatedResponse);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get rewards: ${e.toString()}');
    }
  }

  /// Get reward by ID
  Future<ApiResponse<Reward>> getRewardById(String rewardId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.rewardById(rewardId)));
      final reward = Reward.fromJson(response);
      return ApiResponse.success(data: reward);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get reward details: ${e.toString()}');
    }
  }

  /// Redeem a reward
  Future<ApiResponse<Map<String, dynamic>>> redeemReward(String rewardId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.redeemReward(rewardId)),
        body: {},
      );

      return ApiResponse.success(data: response as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to redeem reward: ${e.toString()}');
    }
  }

  /// Get user's redeemed rewards
  Future<ApiResponse<List<Reward>>> getMyRewards() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.myRewards));
      
      List<Reward> rewards = [];
      if (response is List) {
        rewards = response
            .map((item) => Reward.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic> && response.containsKey('results')) {
        final results = response['results'] as List<dynamic>;
        rewards = results
            .map((item) => Reward.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return ApiResponse.success(data: rewards);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get my rewards: ${e.toString()}');
    }
  }

  // Leaderboard methods

  /// Get all-time leaderboard
  Future<ApiResponse<List<LeaderboardEntry>>> getAllTimeLeaderboard({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.allTimeLeaderboard),
        queryParameters: queryParams,
      );

      List<LeaderboardEntry> entries = [];
      if (response is List) {
        entries = response
            .map((item) => LeaderboardEntry.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic> && response.containsKey('results')) {
        final results = response['results'] as List<dynamic>;
        entries = results
            .map((item) => LeaderboardEntry.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return ApiResponse.success(data: entries);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get all-time leaderboard: ${e.toString()}');
    }
  }

  /// Get daily leaderboard
  Future<ApiResponse<List<LeaderboardEntry>>> getDailyLeaderboard({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.dailyLeaderboard),
        queryParameters: queryParams,
      );

      List<LeaderboardEntry> entries = [];
      if (response is List) {
        entries = response
            .map((item) => LeaderboardEntry.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic> && response.containsKey('results')) {
        final results = response['results'] as List<dynamic>;
        entries = results
            .map((item) => LeaderboardEntry.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return ApiResponse.success(data: entries);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get daily leaderboard: ${e.toString()}');
    }
  }

  /// Get weekly leaderboard
  Future<ApiResponse<List<LeaderboardEntry>>> getWeeklyLeaderboard({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.weeklyLeaderboard),
        queryParameters: queryParams,
      );

      List<LeaderboardEntry> entries = [];
      if (response is List) {
        entries = response
            .map((item) => LeaderboardEntry.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic> && response.containsKey('results')) {
        final results = response['results'] as List<dynamic>;
        entries = results
            .map((item) => LeaderboardEntry.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return ApiResponse.success(data: entries);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get weekly leaderboard: ${e.toString()}');
    }
  }

  /// Get monthly leaderboard
  Future<ApiResponse<List<LeaderboardEntry>>> getMonthlyLeaderboard({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.monthlyLeaderboard),
        queryParameters: queryParams,
      );

      List<LeaderboardEntry> entries = [];
      if (response is List) {
        entries = response
            .map((item) => LeaderboardEntry.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic> && response.containsKey('results')) {
        final results = response['results'] as List<dynamic>;
        entries = results
            .map((item) => LeaderboardEntry.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return ApiResponse.success(data: entries);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get monthly leaderboard: ${e.toString()}');
    }
  }

  /// Get user's rank in leaderboard
  Future<ApiResponse<Map<String, dynamic>>> getMyRank() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.myRank));
      return ApiResponse.success(data: response as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get my rank: ${e.toString()}');
    }
  }

  // User profile methods

  /// Get user's gamification profile
  Future<ApiResponse<UserProfile>> getMyProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.myProfile));
      final profile = UserProfile.fromJson(response);
      return ApiResponse.success(data: profile);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get profile: ${e.toString()}');
    }
  }

  /// Update user's preferences
  Future<ApiResponse<UserProfile>> updatePreferences(UserProfileUpdateRequest request) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.buildUrl(ApiEndpoints.updatePreferences),
        body: request.toJson(),
      );

      final profile = UserProfile.fromJson(response);
      return ApiResponse.success(data: profile);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to update preferences: ${e.toString()}');
    }
  }

  /// Complete a trip for gamification points
  Future<ApiResponse<Map<String, dynamic>>> completeTrip(TripCompletionRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.buildUrl(ApiEndpoints.completeTrip),
        body: request.toJson(),
      );

      return ApiResponse.success(data: response as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to complete trip: ${e.toString()}');
    }
  }

  // Transaction methods

  /// Get point transactions
  Future<ApiResponse<PaginatedResponse<PointTransaction>>> getTransactions({
    PointTransactionQueryParameters? queryParams,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.buildUrl(ApiEndpoints.transactions),
        queryParameters: queryParams?.toMap(),
      );

      final paginatedResponse = PaginatedResponse<PointTransaction>.fromJson(
        response,
        (json) => PointTransaction.fromJson(json as Map<String, dynamic>),
      );

      return ApiResponse.success(data: paginatedResponse);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get transactions: ${e.toString()}');
    }
  }

  /// Get transaction by ID
  Future<ApiResponse<PointTransaction>> getTransactionById(String transactionId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.transactionById(transactionId)));
      final transaction = PointTransaction.fromJson(response);
      return ApiResponse.success(data: transaction);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get transaction details: ${e.toString()}');
    }
  }

  /// Get transactions summary
  Future<ApiResponse<Map<String, dynamic>>> getTransactionsSummary() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.buildUrl(ApiEndpoints.transactionsSummary));
      return ApiResponse.success(data: response as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) {
        return ApiResponse.error(message: e.message);
      }
      return ApiResponse.error(message: 'Failed to get transactions summary: ${e.toString()}');
    }
  }

  // Helper methods

  /// Get available rewards that user can afford
  Future<ApiResponse<List<Reward>>> getAffordableRewards() async {
    try {
      final response = await getRewards();
      if (response.isSuccess && response.data != null) {
        final affordableRewards = response.data!.results
            .where((reward) => reward.canAfford && reward.canRedeem)
            .toList();
        return ApiResponse.success(data: affordableRewards);
      }
      return ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: 'Failed to get affordable rewards: ${e.toString()}');
    }
  }

  /// Get active challenges user can join
  Future<ApiResponse<List<Challenge>>> getJoinableChallenges() async {
    try {
      final queryParams = ChallengeQueryParameters(
        isCompleted: false,
        startsAfter: DateTime.now().subtract(const Duration(days: 1)),
      );

      final response = await getChallenges(queryParams: queryParams);
      if (response.isSuccess && response.data != null) {
        final joinableChallenges = response.data!.results
            .where((challenge) => challenge.canJoin)
            .toList();
        return ApiResponse.success(data: joinableChallenges);
      }
      return ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: 'Failed to get joinable challenges: ${e.toString()}');
    }
  }

  /// Get recent achievements (unlocked in last 30 days)
  Future<ApiResponse<List<Achievement>>> getRecentAchievements() async {
    try {
      final response = await getUnlockedAchievements();
      if (response.isSuccess && response.data != null) {
        // Note: This assumes the API returns achievements in chronological order
        // In a real implementation, you might need to filter based on unlock date
        final recentAchievements = response.data!.take(10).toList();
        return ApiResponse.success(data: recentAchievements);
      }
      return ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: 'Failed to get recent achievements: ${e.toString()}');
    }
  }

  /// Get achievements by type
  Future<ApiResponse<List<Achievement>>> getAchievementsByType(AchievementType type) async {
    try {
      final queryParams = AchievementQueryParameters(
        achievementType: [type.value],
      );

      final response = await getAchievements(queryParams: queryParams);
      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(data: response.data!.results);
      }
      return ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: 'Failed to get achievements by type: ${e.toString()}');
    }
  }

  /// Get rewards by type
  Future<ApiResponse<List<Reward>>> getRewardsByType(RewardType type) async {
    try {
      final queryParams = RewardQueryParameters(
        rewardType: [type.value],
      );

      final response = await getRewards(queryParams: queryParams);
      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(data: response.data!.results);
      }
      return ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: 'Failed to get rewards by type: ${e.toString()}');
    }
  }

  /// Get latest transactions
  Future<ApiResponse<List<PointTransaction>>> getLatestTransactions({int limit = 10}) async {
    try {
      final queryParams = PointTransactionQueryParameters(
        orderBy: ['-created_at'],
        pageSize: limit,
      );

      final response = await getTransactions(queryParams: queryParams);
      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(data: response.data!.results);
      }
      return ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: 'Failed to get latest transactions: ${e.toString()}');
    }
  }

  /// Get user's level information
  Future<ApiResponse<Map<String, dynamic>>> getLevelInfo() async {
    try {
      final profileResponse = await getMyProfile();
      if (profileResponse.isSuccess && profileResponse.data != null) {
        final profile = profileResponse.data!;
        
        final levelInfo = {
          'current_level': profile.currentLevel,
          'total_points': profile.totalPoints,
          'experience_points': profile.experiencePoints,
          'next_level_points': profile.nextLevelPoints,
          'level_progress': profile.levelProgress,
          'points_to_next_level': profile.pointsToNextLevel,
        };
        
        return ApiResponse.success(data: levelInfo);
      }
      return ApiResponse.error(message: profileResponse.message);
    } catch (e) {
      return ApiResponse.error(message: 'Failed to get level info: ${e.toString()}');
    }
  }
}