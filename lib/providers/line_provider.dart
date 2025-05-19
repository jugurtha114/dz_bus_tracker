// lib/providers/line_provider.dart

import 'package:flutter/foundation.dart';
import '../core/exceptions/app_exceptions.dart';
import '../services/line_service.dart';

class LineProvider with ChangeNotifier {
  final LineService _lineService;

  LineProvider({LineService? lineService})
      : _lineService = lineService ?? LineService();

  // State
  List<Map<String, dynamic>> _lines = [];
  Map<String, dynamic>? _selectedLine;
  List<Map<String, dynamic>> _lineStops = [];
  List<Map<String, dynamic>> _lineSchedule = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get lines => _lines;
  Map<String, dynamic>? get selectedLine => _selectedLine;
  List<Map<String, dynamic>> get lineStops => _lineStops;
  List<Map<String, dynamic>> get lineSchedule => _lineSchedule;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch lines
  Future<void> fetchLines({
    bool? isActive,
    String? stopId,
  }) async {
    _setLoading(true);

    try {
      _lines = await _lineService.getLines(
        isActive: isActive,
        stopId: stopId,
      );

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
      final line = await _lineService.getLineById(lineId);
      _selectedLine = line;

      // Fetch stops and schedule for the selected line
      await fetchLineStops();
      await fetchLineSchedule();

      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Set selected line directly
  void setSelectedLine(Map<String, dynamic> line) {
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
      _lineStops = await _lineService.getLineStops(_selectedLine!['id']);
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
      _lineSchedule = await _lineService.getLineSchedule(_selectedLine!['id']);
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
      final newLine = await _lineService.createLine(
        name: name,
        code: code,
        description: description,
        color: color,
        frequency: frequency,
      );

      // Add to lines list
      _lines.add(newLine);
      notifyListeners();

      return true;
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
      final updatedLine = await _lineService.updateLine(
        lineId: lineId,
        name: name,
        code: code,
        description: description,
        color: color,
        frequency: frequency,
        isActive: isActive,
      );

      // Update lines list
      final index = _lines.indexWhere((line) => line['id'] == lineId);
      if (index != -1) {
        _lines[index] = updatedLine;
      }

      // Update selected line if it's the same line
      if (_selectedLine != null && _selectedLine!['id'] == lineId) {
        _selectedLine = updatedLine;
      }

      notifyListeners();

      return true;
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
      await _lineService.addStopToLine(
        lineId: _selectedLine!['id'],
        stopId: stopId,
        order: order,
        distanceFromPrevious: distanceFromPrevious,
        averageTimeFromPrevious: averageTimeFromPrevious,
      );

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
      await _lineService.removeStopFromLine(
        lineId: _selectedLine!['id'],
        stopId: stopId,
      );

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
      await _lineService.addSchedule(
        lineId: _selectedLine!['id'],
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        frequencyMinutes: frequencyMinutes,
      );

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
}