// lib/providers/gamification_provider.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/gamification_model.dart';
import '../models/api_response_models.dart';
import '../services/gamification_service.dart';

class GamificationProvider extends ChangeNotifier {
  final GamificationService _gamificationService;

  GamificationProvider({GamificationService? gamificationService})
      : _gamificationService = gamificationService ?? GamificationService();

  // State variables
  bool _isLoading = false;
  String? _error;

  // Achievements state
  List<Achievement> _achievements = [];
  List<Achievement> _unlockedAchievements = [];
  List<Achievement> _recentAchievements = [];
  Achievement? _selectedAchievement;

  // Challenges state
  List<Challenge> _challenges = [];
  List<Challenge> _myChallenges = [];
  List<Challenge> _joinableChallenges = [];
  Challenge? _selectedChallenge;

  // Rewards state
  List<Reward> _rewards = [];
  List<Reward> _myRewards = [];
  List<Reward> _affordableRewards = [];
  Reward? _selectedReward;

  // Leaderboard state
  List<LeaderboardEntry> _allTimeLeaderboard = [];
  List<LeaderboardEntry> _dailyLeaderboard = [];
  List<LeaderboardEntry> _weeklyLeaderboard = [];
  List<LeaderboardEntry> _monthlyLeaderboard = [];
  Map<String, dynamic>? _myRank;

  // User profile state
  UserProfile? _userProfile;
  Map<String, dynamic>? _levelInfo;

  // Transactions state
  List<PointTransaction> _transactions = [];
  List<PointTransaction> _latestTransactions = [];
  Map<String, dynamic>? _transactionsSummary;

  // Pagination state
  int _currentPage = 1;
  bool _hasNextPage = false;
  bool _hasPreviousPage = false;
  int _totalCount = 0;

  // Auto-refresh state
  Timer? _refreshTimer;
  bool _autoRefreshEnabled = false;
  Duration _refreshInterval = const Duration(minutes: 5);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Achievements getters
  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements => _unlockedAchievements;
  List<Achievement> get recentAchievements => _recentAchievements;
  Achievement? get selectedAchievement => _selectedAchievement;

  // Challenges getters
  List<Challenge> get challenges => _challenges;
  List<Challenge> get myChallenges => _myChallenges;
  List<Challenge> get joinableChallenges => _joinableChallenges;
  Challenge? get selectedChallenge => _selectedChallenge;

  // Rewards getters
  List<Reward> get rewards => _rewards;
  List<Reward> get myRewards => _myRewards;
  List<Reward> get affordableRewards => _affordableRewards;
  Reward? get selectedReward => _selectedReward;

  // Leaderboard getters
  List<LeaderboardEntry> get allTimeLeaderboard => _allTimeLeaderboard;
  List<LeaderboardEntry> get dailyLeaderboard => _dailyLeaderboard;
  List<LeaderboardEntry> get weeklyLeaderboard => _weeklyLeaderboard;
  List<LeaderboardEntry> get monthlyLeaderboard => _monthlyLeaderboard;
  Map<String, dynamic>? get myRank => _myRank;

  // User profile getters
  UserProfile? get userProfile => _userProfile;
  Map<String, dynamic>? get levelInfo => _levelInfo;

  // Transactions getters
  List<PointTransaction> get transactions => _transactions;
  List<PointTransaction> get latestTransactions => _latestTransactions;
  Map<String, dynamic>? get transactionsSummary => _transactionsSummary;

  // Pagination getters
  int get currentPage => _currentPage;
  bool get hasNextPage => _hasNextPage;
  bool get hasPreviousPage => _hasPreviousPage;
  int get totalCount => _totalCount;

  // Auto-refresh getters
  bool get autoRefreshEnabled => _autoRefreshEnabled;
  Duration get refreshInterval => _refreshInterval;

  // Helper getters
  bool get hasError => _error != null;
  bool get hasProfile => _userProfile != null;
  int get totalPoints => _userProfile?.totalPoints ?? 0;
  int get currentLevel => _userProfile?.currentLevel ?? 1;
  int get currentStreak => _userProfile?.currentStreak ?? 0;
  int get unlockedAchievementsCount => _unlockedAchievements.length;
  int get activeChallengesCount => _myChallenges.where((c) => c.isActive && !c.isCompleted).length;
  int get availableRewardsCount => _affordableRewards.length;

  // Achievement management methods

  /// Load achievements with optional filtering
  Future<void> loadAchievements({
    AchievementQueryParameters? queryParams,
    bool append = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _gamificationService.getAchievements(queryParams: queryParams);

      if (response.isSuccess && response.data != null) {
        if (append) {
          _achievements.addAll(response.data!.results);
        } else {
          _achievements = response.data!.results;
        }
        _updatePaginationState(response.data!);
      } else {
        _setError(response.message ?? 'Failed to load achievements');
      }
    } catch (e) {
      _setError('Failed to load achievements: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Get achievement by ID
  Future<void> getAchievementById(String achievementId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _gamificationService.getAchievementById(achievementId);

      if (response.isSuccess && response.data != null) {
        _selectedAchievement = response.data!;
      } else {
        _setError(response.message ?? 'Failed to get achievement details');
      }
    } catch (e) {
      _setError('Failed to get achievement details: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load user's achievement progress
  Future<void> loadAchievementProgress() async {
    try {
      final response = await _gamificationService.getAchievementProgress();

      if (response.isSuccess && response.data != null) {
        _achievements = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load achievement progress: $e');
    }
  }

  /// Load unlocked achievements
  Future<void> loadUnlockedAchievements() async {
    try {
      final response = await _gamificationService.getUnlockedAchievements();

      if (response.isSuccess && response.data != null) {
        _unlockedAchievements = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load unlocked achievements: $e');
    }
  }

  /// Load recent achievements
  Future<void> loadRecentAchievements() async {
    try {
      final response = await _gamificationService.getRecentAchievements();

      if (response.isSuccess && response.data != null) {
        _recentAchievements = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load recent achievements: $e');
    }
  }

  /// Get achievements by type
  Future<void> loadAchievementsByType(AchievementType type) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _gamificationService.getAchievementsByType(type);

      if (response.isSuccess && response.data != null) {
        _achievements = response.data!;
      } else {
        _setError(response.message ?? 'Failed to load achievements by type');
      }
    } catch (e) {
      _setError('Failed to load achievements by type: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Challenge management methods

  /// Load challenges with optional filtering
  Future<void> loadChallenges({
    ChallengeQueryParameters? queryParams,
    bool append = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _gamificationService.getChallenges(queryParams: queryParams);

      if (response.isSuccess && response.data != null) {
        if (append) {
          _challenges.addAll(response.data!.results);
        } else {
          _challenges = response.data!.results;
        }
        _updatePaginationState(response.data!);
      } else {
        _setError(response.message ?? 'Failed to load challenges');
      }
    } catch (e) {
      _setError('Failed to load challenges: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Get challenge by ID
  Future<void> getChallengeById(String challengeId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _gamificationService.getChallengeById(challengeId);

      if (response.isSuccess && response.data != null) {
        _selectedChallenge = response.data!;
      } else {
        _setError(response.message ?? 'Failed to get challenge details');
      }
    } catch (e) {
      _setError('Failed to get challenge details: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Join a challenge
  Future<bool> joinChallenge(String challengeId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _gamificationService.joinChallenge(challengeId);

      if (response.isSuccess && response.data != null) {
        final joinedChallenge = response.data!;
        
        // Update in challenges list
        final index = _challenges.indexWhere((c) => c.id == challengeId);
        if (index != -1) {
          _challenges[index] = joinedChallenge;
        }

        // Add to my challenges
        if (!_myChallenges.any((c) => c.id == challengeId)) {
          _myChallenges.add(joinedChallenge);
        }

        // Update selected challenge if it's the same
        if (_selectedChallenge?.id == challengeId) {
          _selectedChallenge = joinedChallenge;
        }

        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to join challenge');
        return false;
      }
    } catch (e) {
      _setError('Failed to join challenge: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load user's challenges
  Future<void> loadMyChallenges() async {
    try {
      final response = await _gamificationService.getMyChallenges();

      if (response.isSuccess && response.data != null) {
        _myChallenges = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load my challenges: $e');
    }
  }

  /// Load joinable challenges
  Future<void> loadJoinableChallenges() async {
    try {
      final response = await _gamificationService.getJoinableChallenges();

      if (response.isSuccess && response.data != null) {
        _joinableChallenges = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load joinable challenges: $e');
    }
  }

  // Reward management methods

  /// Load rewards with optional filtering
  Future<void> loadRewards({
    RewardQueryParameters? queryParams,
    bool append = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _gamificationService.getRewards(queryParams: queryParams);

      if (response.isSuccess && response.data != null) {
        if (append) {
          _rewards.addAll(response.data!.results);
        } else {
          _rewards = response.data!.results;
        }
        _updatePaginationState(response.data!);
      } else {
        _setError(response.message ?? 'Failed to load rewards');
      }
    } catch (e) {
      _setError('Failed to load rewards: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Get reward by ID
  Future<void> getRewardById(String rewardId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _gamificationService.getRewardById(rewardId);

      if (response.isSuccess && response.data != null) {
        _selectedReward = response.data!;
      } else {
        _setError(response.message ?? 'Failed to get reward details');
      }
    } catch (e) {
      _setError('Failed to get reward details: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Redeem a reward
  Future<bool> redeemReward(String rewardId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _gamificationService.redeemReward(rewardId);

      if (response.isSuccess) {
        // Refresh user profile to update points
        await loadUserProfile();
        
        // Refresh rewards to update availability
        await loadRewards();
        
        // Refresh my rewards
        await loadMyRewards();

        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to redeem reward');
        return false;
      }
    } catch (e) {
      _setError('Failed to redeem reward: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load user's redeemed rewards
  Future<void> loadMyRewards() async {
    try {
      final response = await _gamificationService.getMyRewards();

      if (response.isSuccess && response.data != null) {
        _myRewards = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load my rewards: $e');
    }
  }

  /// Load affordable rewards
  Future<void> loadAffordableRewards() async {
    try {
      final response = await _gamificationService.getAffordableRewards();

      if (response.isSuccess && response.data != null) {
        _affordableRewards = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load affordable rewards: $e');
    }
  }

  /// Get rewards by type
  Future<void> loadRewardsByType(RewardType type) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _gamificationService.getRewardsByType(type);

      if (response.isSuccess && response.data != null) {
        _rewards = response.data!;
      } else {
        _setError(response.message ?? 'Failed to load rewards by type');
      }
    } catch (e) {
      _setError('Failed to load rewards by type: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Leaderboard methods

  /// Load all-time leaderboard
  Future<void> loadAllTimeLeaderboard({int? limit}) async {
    try {
      final response = await _gamificationService.getAllTimeLeaderboard(limit: limit);

      if (response.isSuccess && response.data != null) {
        _allTimeLeaderboard = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load all-time leaderboard: $e');
    }
  }

  /// Load daily leaderboard
  Future<void> loadDailyLeaderboard({int? limit}) async {
    try {
      final response = await _gamificationService.getDailyLeaderboard(limit: limit);

      if (response.isSuccess && response.data != null) {
        _dailyLeaderboard = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load daily leaderboard: $e');
    }
  }

  /// Load weekly leaderboard
  Future<void> loadWeeklyLeaderboard({int? limit}) async {
    try {
      final response = await _gamificationService.getWeeklyLeaderboard(limit: limit);

      if (response.isSuccess && response.data != null) {
        _weeklyLeaderboard = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load weekly leaderboard: $e');
    }
  }

  /// Load monthly leaderboard
  Future<void> loadMonthlyLeaderboard({int? limit}) async {
    try {
      final response = await _gamificationService.getMonthlyLeaderboard(limit: limit);

      if (response.isSuccess && response.data != null) {
        _monthlyLeaderboard = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load monthly leaderboard: $e');
    }
  }

  /// Load user's rank
  Future<void> loadMyRank() async {
    try {
      final response = await _gamificationService.getMyRank();

      if (response.isSuccess && response.data != null) {
        _myRank = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load my rank: $e');
    }
  }

  // User profile methods

  /// Load user's gamification profile
  Future<void> loadUserProfile() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _gamificationService.getMyProfile();

      if (response.isSuccess && response.data != null) {
        _userProfile = response.data!;
      } else {
        _setError(response.message ?? 'Failed to load profile');
      }
    } catch (e) {
      _setError('Failed to load profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Update user preferences
  Future<bool> updatePreferences(UserProfileUpdateRequest request) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _gamificationService.updatePreferences(request);

      if (response.isSuccess && response.data != null) {
        _userProfile = response.data!;
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to update preferences');
        return false;
      }
    } catch (e) {
      _setError('Failed to update preferences: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Complete a trip for gamification points
  Future<bool> completeTrip(TripCompletionRequest request) async {
    try {
      final response = await _gamificationService.completeTrip(request);

      if (response.isSuccess) {
        // Refresh user profile to update points and stats
        await loadUserProfile();
        
        // Refresh recent transactions
        await loadLatestTransactions();
        
        // Refresh achievement progress
        await loadAchievementProgress();

        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Failed to complete trip: $e');
    }
    return false;
  }

  /// Load level information
  Future<void> loadLevelInfo() async {
    try {
      final response = await _gamificationService.getLevelInfo();

      if (response.isSuccess && response.data != null) {
        _levelInfo = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load level info: $e');
    }
  }

  // Transaction methods

  /// Load point transactions
  Future<void> loadTransactions({
    PointTransactionQueryParameters? queryParams,
    bool append = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _gamificationService.getTransactions(queryParams: queryParams);

      if (response.isSuccess && response.data != null) {
        if (append) {
          _transactions.addAll(response.data!.results);
        } else {
          _transactions = response.data!.results;
        }
        _updatePaginationState(response.data!);
      } else {
        _setError(response.message ?? 'Failed to load transactions');
      }
    } catch (e) {
      _setError('Failed to load transactions: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load latest transactions
  Future<void> loadLatestTransactions({int limit = 10}) async {
    try {
      final response = await _gamificationService.getLatestTransactions(limit: limit);

      if (response.isSuccess && response.data != null) {
        _latestTransactions = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load latest transactions: $e');
    }
  }

  /// Load transactions summary
  Future<void> loadTransactionsSummary() async {
    try {
      final response = await _gamificationService.getTransactionsSummary();

      if (response.isSuccess && response.data != null) {
        _transactionsSummary = response.data!;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load transactions summary: $e');
    }
  }

  // Auto-refresh methods

  /// Start auto-refresh for real-time updates
  void startAutoRefresh() {
    if (_refreshTimer?.isActive == true) return;

    _autoRefreshEnabled = true;
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      _performAutoRefresh();
    });
    notifyListeners();
  }

  /// Stop auto-refresh
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _autoRefreshEnabled = false;
    notifyListeners();
  }

  /// Set refresh interval
  void setRefreshInterval(Duration interval) {
    _refreshInterval = interval;
    if (_autoRefreshEnabled) {
      stopAutoRefresh();
      startAutoRefresh();
    }
  }

  /// Perform auto-refresh
  Future<void> _performAutoRefresh() async {
    try {
      // Refresh user profile
      await loadUserProfile();
      
      // Refresh leaderboards
      await loadDailyLeaderboard(limit: 10);
      await loadMyRank();
      
      // Refresh latest transactions
      await loadLatestTransactions();
      
      // Refresh recent achievements
      await loadRecentAchievements();
      
      // Refresh joinable challenges
      await loadJoinableChallenges();
      
      // Refresh affordable rewards
      await loadAffordableRewards();
    } catch (e) {
      debugPrint('Auto-refresh failed: $e');
    }
  }

  // Comprehensive load method for dashboard

  /// Load all gamification data for dashboard
  Future<void> loadDashboardData() async {
    try {
      _setLoading(true);
      _clearError();

      // Load core data in parallel
      await Future.wait([
        loadUserProfile(),
        loadUnlockedAchievements(),
        loadMyChallenges(),
        loadAffordableRewards(),
        loadLatestTransactions(limit: 5),
        loadDailyLeaderboard(limit: 10),
      ]);

      // Load additional data
      await Future.wait([
        loadMyRank(),
        loadLevelInfo(),
        loadJoinableChallenges(),
        loadRecentAchievements(),
      ]);

    } catch (e) {
      _setError('Failed to load dashboard data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Utility methods

  /// Clear error
  void clearError() {
    _clearError();
  }

  /// Clear all data
  void clearData() {
    _achievements.clear();
    _unlockedAchievements.clear();
    _recentAchievements.clear();
    _challenges.clear();
    _myChallenges.clear();
    _joinableChallenges.clear();
    _rewards.clear();
    _myRewards.clear();
    _affordableRewards.clear();
    _allTimeLeaderboard.clear();
    _dailyLeaderboard.clear();
    _weeklyLeaderboard.clear();
    _monthlyLeaderboard.clear();
    _transactions.clear();
    _latestTransactions.clear();
    _selectedAchievement = null;
    _selectedChallenge = null;
    _selectedReward = null;
    _userProfile = null;
    _myRank = null;
    _levelInfo = null;
    _transactionsSummary = null;
    _currentPage = 1;
    _hasNextPage = false;
    _hasPreviousPage = false;
    _totalCount = 0;
    notifyListeners();
  }

  /// Set selected achievement
  void setSelectedAchievement(Achievement? achievement) {
    _selectedAchievement = achievement;
    notifyListeners();
  }

  /// Set selected challenge
  void setSelectedChallenge(Challenge? challenge) {
    _selectedChallenge = challenge;
    notifyListeners();
  }

  /// Set selected reward
  void setSelectedReward(Reward? reward) {
    _selectedReward = reward;
    notifyListeners();
  }

  // Pagination methods

  /// Load next page
  Future<void> loadNextPage() async {
    if (!_hasNextPage || _isLoading) return;

    _currentPage++;
    await loadAchievements(
      queryParams: AchievementQueryParameters(page: _currentPage),
      append: true,
    );
  }

  /// Load previous page
  Future<void> loadPreviousPage() async {
    if (!_hasPreviousPage || _isLoading || _currentPage <= 1) return;

    _currentPage--;
    await loadAchievements(
      queryParams: AchievementQueryParameters(page: _currentPage),
    );
  }

  /// Reset pagination
  void resetPagination() {
    _currentPage = 1;
    _hasNextPage = false;
    _hasPreviousPage = false;
    _totalCount = 0;
  }

  // Private helper methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _updatePaginationState<T>(PaginatedResponse<T> response) {
    _totalCount = response.count;
    _hasNextPage = response.hasNextPage;
    _hasPreviousPage = response.hasPreviousPage;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}