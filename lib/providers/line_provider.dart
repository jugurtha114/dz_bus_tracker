// lib/providers/line_provider.dart

import 'package:flutter/foundation.dart';
import '../core/exceptions/app_exceptions.dart';
import '../services/line_service.dart';
import '../models/line_model.dart';
import '../models/api_response_models.dart';

class LineProvider with ChangeNotifier {
  final LineService _lineService;

  LineProvider({LineService? lineService})
    : _lineService = lineService ?? LineService();

  // State
  List<Line> _lines = [];
  Line? _selectedLine;
  List<LineStop> _lineStops = [];
  List<Schedule> _lineSchedule = [];
  PaginatedResponse<Line>? _linesResponse;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Line> get lines => _lines;
  Line? get selectedLine => _selectedLine;
  List<LineStop> get lineStops => _lineStops;
  List<Schedule> get lineSchedule => _lineSchedule;
  PaginatedResponse<Line>? get linesResponse => _linesResponse;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch lines
  Future<void> fetchLines({LineQueryParameters? queryParams}) async {
    _setLoading(true);

    try {
      final response = await _lineService.getLines(queryParams: queryParams);

      if (response.isSuccess && response.data != null) {
        _linesResponse = response.data!;
        _lines = response.data!.results;
        _clearError();
      } else {
        _setError(response.message ?? 'Failed to fetch lines');
      }

      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Select a line
  Future<void> selectLine(String lineId) async {
    _setLoading(true);

    try {
      final response = await _lineService.getLineById(lineId);

      if (response.isSuccess && response.data != null) {
        _selectedLine = response.data!;
        _clearError();

        // Fetch stops and schedule for the selected line
        await fetchLineStops();
        await fetchLineSchedule();
      } else {
        _setError(response.message ?? 'Failed to fetch line details');
      }

      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Set selected line directly
  void setSelectedLine(Line line) {
    _selectedLine = line;
    notifyListeners();
  }

  // Clear selected line
  void clearSelectedLine() {
    _selectedLine = null;
    _lineStops = [];
    _lineSchedule = [];
    notifyListeners();
  }

  // Fetch stops for the selected line
  Future<void> fetchLineStops() async {
    if (_selectedLine == null) {
      _setError('No line selected');
      return;
    }

    _setLoading(true);

    try {
      final response = await _lineService.getLineStops(_selectedLine!.id);
      if (response.isSuccess && response.data != null) {
        _lineStops = response.data!.stops;
        _clearError();
      } else {
        _setError(response.message ?? 'Failed to fetch line stops');
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Fetch schedule for the selected line
  Future<void> fetchLineSchedule() async {
    if (_selectedLine == null) {
      _setError('No line selected');
      return;
    }

    _setLoading(true);

    try {
      final queryParams = ScheduleQueryParameters(lineId: _selectedLine!.id);
      final response = await _lineService.getSchedules(
        queryParams: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        _lineSchedule = response.data!.results;
        _clearError();
      } else {
        _setError(response.message ?? 'Failed to fetch line schedule');
      }

      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Create new line
  Future<bool> createLine({
    required String name,
    required String code,
    String? description,
    String? color,
    int? frequency,
  }) async {
    _setLoading(true);

    try {
      final request = LineCreateRequest(
        name: name,
        code: code,
        description: description,
        color: color,
        frequency: frequency,
      );

      final response = await _lineService.createLine(request);

      if (response.isSuccess && response.data != null) {
        // Add to lines list
        _lines.add(response.data!);
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to create line');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update line
  Future<bool> updateLine({
    required String lineId,
    String? name,
    String? code,
    String? description,
    String? color,
    int? frequency,
    bool? isActive,
  }) async {
    _setLoading(true);

    try {
      final request = LineUpdateRequest(
        name: name,
        code: code,
        description: description,
        color: color,
        frequency: frequency,
        isActive: isActive,
      );

      final response = await _lineService.updateLine(lineId, request);

      if (response.isSuccess && response.data != null) {
        final updatedLine = response.data!;

        // Update lines list
        final index = _lines.indexWhere((line) => line.id == lineId);
        if (index != -1) {
          _lines[index] = updatedLine;
        }

        // Update selected line if it's the same line
        if (_selectedLine != null && _selectedLine!.id == lineId) {
          _selectedLine = updatedLine;
        }

        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to update line');
        return false;
      }
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add stop to line
  Future<bool> addStopToLine({
    required String stopId,
    required int order,
    double? distanceFromPrevious,
    int? averageTimeFromPrevious,
  }) async {
    if (_selectedLine == null) {
      _setError('No line selected');
      return false;
    }

    _setLoading(true);

    try {
      // TODO: Fix service method signature
      // await _lineService.addStopToLine(...);
      print('TODO: Implement addStopToLine');

      // Refresh line stops
      await fetchLineStops();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Remove stop from line
  Future<bool> removeStopFromLine(String stopId) async {
    if (_selectedLine == null) {
      _setError('No line selected');
      return false;
    }

    _setLoading(true);

    try {
      final request = RemoveStopFromLineRequest(stopId: stopId);
      await _lineService.removeStopFromLine(_selectedLine!.id, request);

      // Refresh line stops
      await fetchLineStops();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add schedule to line
  Future<bool> addSchedule({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required int frequencyMinutes,
  }) async {
    if (_selectedLine == null) {
      _setError('No line selected');
      return false;
    }

    _setLoading(true);

    try {
      // TODO: Fix service method signature
      // await _lineService.createSchedule(...);
      print('TODO: Implement createSchedule');

      // Refresh line schedule
      await fetchLineSchedule();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(dynamic error) {
    if (error is AppException) {
      _error = error.message;
    } else {
      _error = error.toString();
    }
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Load recent searches
  Future<void> loadRecentSearches() async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual recent searches loading
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Load popular lines
  Future<void> loadPopularLines() async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual popular lines loading
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Get recent searches
  List<Line> get recentSearches => []; // Mock - should return actual recent searches

  /// Get popular lines
  List<Line> get popularLines => _lines.take(5).toList(); // Mock - return first 5 lines as popular
  
  /// Get nearby lines based on location
  List<Line> get nearbyLines => _lines.take(3).toList(); // Mock - return first 3 lines as nearby

  /// Search lines by query
  Future<void> searchLines({
    String? query,
    String? fromStopId,
    String? toStopId,
    Set<String>? features,
    double? maxFare,
    double? maxDistance,
    String sortBy = 'distance',
    bool onlyActive = true,
    bool accessibleOnly = false,
  }) async {
    _setLoading(true);
    try {
      // Mock search implementation - replace with actual search
      await Future.delayed(const Duration(seconds: 1));
      // In real implementation, search lines by name/number/route
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Get search results
  List<Line> get searchResults => _lines.where((line) => line.name.toLowerCase().contains('search')).toList(); // Mock search results

  /// Add line to recent searches
  void addToRecentSearches(Line line) {
    // Mock implementation - add to recent searches list
    // In real implementation, save to local storage/preferences
  }

  /// Clear recent searches
  void clearRecentSearches() {
    // Mock implementation - clear recent searches
    // In real implementation, clear from local storage/preferences
  }

  /// Fetch line by ID
  Future<void> fetchLineById(String lineId) async {
    _setLoading(true);
    try {
      // Mock implementation - replace with actual API call to get line by ID
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load all lines (alias for fetchLines)
  Future<void> loadAllLines() async {
    await fetchLines();
  }
  
  /// Additional methods for UI compatibility
  Future<void> fetchAvailableLines() async {
    await fetchLines();
  }
  
  List<Line> get availableLines => _lines;
  
  Future<void> getLinesForStop(String stopId) async {
    // Mock implementation - replace with actual API call
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      _clearError();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }
}
