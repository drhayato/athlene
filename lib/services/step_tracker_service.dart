import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepTrackerService {
  static final StepTrackerService _instance = StepTrackerService._internal();
  factory StepTrackerService() => _instance;
  StepTrackerService._internal();

  final StreamController<int> _stepsController =
      StreamController<int>.broadcast();
  Stream<int> get stepsStream => _stepsController.stream;

  int _todaySteps = 0;
  int _prevTotalSteps = -1;
  StreamSubscription<StepCount>? _stepSubscription;

  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;
    try {
      PermissionStatus status =
          await Permission.activityRecognition.request();
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  Future<void> initPlatformState() async {
    // Always load any saved steps first so the UI shows something immediately
    await _loadCurrentSteps();

    if (kIsWeb) return;

    try {
      bool granted = await requestPermissions();
      if (!granted) return;

      // Cancel any existing subscription before starting a new one
      if (_stepSubscription != null) {
        await _stepSubscription!.cancel();
        _stepSubscription = null;
      }

      _stepSubscription = Pedometer.stepCountStream.listen(
        (StepCount event) => _onStepCount(event),
        onError: _onStepCountError,
        cancelOnError: false,
      );
    } catch (e) {
      // Silently handle devices without step sensor
      debugPrint('Step sensor not available: $e');
    }
  }

  Future<void> _loadCurrentSteps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _todaySteps = prefs.getInt('current_steps') ?? 0;
      if (!_stepsController.isClosed) {
        _stepsController.add(_todaySteps);
      }
    } catch (e) {
      debugPrint('Error loading steps: $e');
    }
  }

  void _onStepCount(StepCount event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int totalSteps = event.steps;

      if (_prevTotalSteps == -1) {
        _prevTotalSteps = prefs.getInt('prev_total_steps') ?? totalSteps;
        String today =
            DateTime.now().toIso8601String().substring(0, 10);
        String? lastReset = prefs.getString('last_reset_date');
        if (lastReset != today) {
          await _saveHistory(_todaySteps);
          _prevTotalSteps = totalSteps;
          await prefs.setString('last_reset_date', today);
        }
        await prefs.setInt('prev_total_steps', _prevTotalSteps);
      }

      _todaySteps = totalSteps - _prevTotalSteps;
      if (_todaySteps < 0) _todaySteps = 0;

      if (!_stepsController.isClosed) {
        _stepsController.add(_todaySteps);
      }
      await _saveHistory(_todaySteps);
    } catch (e) {
      debugPrint('Error processing step count: $e');
    }
  }

  Future<void> _saveHistory(int steps) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String today = DateTime.now().toIso8601String().substring(0, 10);
      await prefs.setInt('steps_$today', steps);
      await prefs.setInt('current_steps', steps);
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }

  void _onStepCountError(Object error) {
    debugPrint('Step count error: $error');
    // Don't propagate the error — just silently fail
  }

  Future<List<int>> getWeeklyHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<int> history = [];
      for (int i = 6; i >= 0; i--) {
        String date = DateTime.now()
            .subtract(Duration(days: i))
            .toIso8601String()
            .substring(0, 10);
        history.add(prefs.getInt('steps_$date') ?? 0);
      }
      return history;
    } catch (e) {
      return List.filled(7, 0);
    }
  }

  Future<int> getGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('step_goal') ?? 10000;
    } catch (e) {
      return 10000;
    }
  }

  Future<void> setGoal(int goal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('step_goal', goal);
    } catch (e) {
      debugPrint('Error setting goal: $e');
    }
  }

  Future<double> getAverageSteps() async {
    try {
      final history = await getWeeklyHistory();
      if (history.isEmpty) return 0;
      return history.reduce((a, b) => a + b) / history.length;
    } catch (e) {
      return 0;
    }
  }

  void dispose() {
    _stepSubscription?.cancel();
    if (!_stepsController.isClosed) {
      _stepsController.close();
    }
  }
}
