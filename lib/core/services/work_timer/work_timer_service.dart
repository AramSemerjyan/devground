import 'dart:async';

import 'package:dartpad_lite/core/storage/work_timer_repo.dart';
import 'package:flutter/foundation.dart';

abstract class WorkTimerServiceInterface {
  ValueNotifier<WorkSessionStatus> get onStateChange;
  ValueNotifier<Duration> get remainingTime;
  ValueNotifier<Duration> get workInterval;
  ValueNotifier<Duration> get breakInterval;

  Future<void> initialize();

  void setWorkInterval(Duration duration);
  void setBreakInterval(Duration duration);

  void startWorkSession();
  void pauseWorkSession();
  void resetWorkSession();

  void startBreakSession();
  void pauseBreakSession();
  void resetBreakSession();

  void dispose();
}

enum WorkSessionStatus {
  idle,
  workInProgress,
  workPaused,
  breakInProgress,
  breakPaused,
  workCompleted,
  breakCompleted,
}

class WorkTimerService implements WorkTimerServiceInterface {
  @override
  final ValueNotifier<WorkSessionStatus> onStateChange =
      ValueNotifier<WorkSessionStatus>(WorkSessionStatus.idle);
  @override
  final ValueNotifier<Duration> remainingTime = ValueNotifier<Duration>(
    Duration.zero,
  );
  @override
  final ValueNotifier<Duration> workInterval = ValueNotifier<Duration>(
    const Duration(minutes: 30),
  );
  @override
  final ValueNotifier<Duration> breakInterval = ValueNotifier<Duration>(
    const Duration(minutes: 15),
  );

  final WorkTimerRepoInterface _workTimerRepo = WorkTimerRepo();

  Timer? _timer;
  Duration _currentSessionDuration = Duration.zero;
  bool _isInitialized = false;

  // Singleton pattern
  static final WorkTimerService _instance = WorkTimerService._internal();

  factory WorkTimerService() {
    return _instance;
  }

  WorkTimerService._internal();

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Load saved intervals from storage
    final savedWorkInterval = await _workTimerRepo.getWorkInterval();
    final savedBreakInterval = await _workTimerRepo.getBreakInterval();

    workInterval.value = savedWorkInterval;
    breakInterval.value = savedBreakInterval;
    remainingTime.value = Duration.zero;

    _isInitialized = true;
  }

  @override
  void setWorkInterval(Duration duration) {
    workInterval.value = duration;
    _workTimerRepo.setWorkInterval(duration);

    // If currently in work session and paused/idle, update remaining time
    if (onStateChange.value == WorkSessionStatus.idle ||
        onStateChange.value == WorkSessionStatus.workPaused) {
      remainingTime.value = duration;
    }
  }

  @override
  void setBreakInterval(Duration duration) {
    breakInterval.value = duration;
    _workTimerRepo.setBreakInterval(duration);

    // If currently in break session and paused/idle, update remaining time
    if (onStateChange.value == WorkSessionStatus.breakPaused) {
      remainingTime.value = duration;
    }
  }

  @override
  void startWorkSession() {
    _cancelTimer();

    // If starting fresh or resuming from completion
    if (onStateChange.value == WorkSessionStatus.idle ||
        onStateChange.value == WorkSessionStatus.workCompleted ||
        onStateChange.value == WorkSessionStatus.breakCompleted) {
      _currentSessionDuration = workInterval.value;
      remainingTime.value = _currentSessionDuration;
    } else if (onStateChange.value == WorkSessionStatus.workPaused) {
      // Resuming from pause - keep current remaining time
      _currentSessionDuration = remainingTime.value;
    }

    onStateChange.value = WorkSessionStatus.workInProgress;
    _startTimer();
  }

  @override
  void pauseWorkSession() {
    if (onStateChange.value != WorkSessionStatus.workInProgress) return;

    _cancelTimer();
    onStateChange.value = WorkSessionStatus.workPaused;
  }

  @override
  void resetWorkSession() {
    _cancelTimer();
    remainingTime.value = workInterval.value;
    onStateChange.value = WorkSessionStatus.idle;
  }

  @override
  void startBreakSession() {
    _cancelTimer();

    // If starting fresh or resuming from completion
    if (onStateChange.value == WorkSessionStatus.idle ||
        onStateChange.value == WorkSessionStatus.workCompleted ||
        onStateChange.value == WorkSessionStatus.breakCompleted) {
      _currentSessionDuration = breakInterval.value;
      remainingTime.value = _currentSessionDuration;
    } else if (onStateChange.value == WorkSessionStatus.breakPaused) {
      // Resuming from pause - keep current remaining time
      _currentSessionDuration = remainingTime.value;
    }

    onStateChange.value = WorkSessionStatus.breakInProgress;
    _startTimer();
  }

  @override
  void pauseBreakSession() {
    if (onStateChange.value != WorkSessionStatus.breakInProgress) return;

    _cancelTimer();
    onStateChange.value = WorkSessionStatus.breakPaused;
  }

  @override
  void resetBreakSession() {
    _cancelTimer();
    remainingTime.value = breakInterval.value;
    onStateChange.value = WorkSessionStatus.idle;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSessionDuration.inSeconds > 0) {
        _currentSessionDuration = Duration(
          seconds: _currentSessionDuration.inSeconds - 1,
        );
        remainingTime.value = _currentSessionDuration;
      } else {
        // Session completed
        _cancelTimer();

        if (onStateChange.value == WorkSessionStatus.workInProgress) {
          onStateChange.value = WorkSessionStatus.workCompleted;
          remainingTime.value = Duration.zero;
        } else if (onStateChange.value == WorkSessionStatus.breakInProgress) {
          onStateChange.value = WorkSessionStatus.breakCompleted;
          remainingTime.value = Duration.zero;
        }
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    onStateChange.dispose();
    remainingTime.dispose();
    workInterval.dispose();
    breakInterval.dispose();
  }
}
