import 'dart:async';

import 'package:dartpad_lite/core/services/work_timer/intervals.dart';
import 'package:dartpad_lite/core/storage/work_timer_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class WorkTimerServiceInterface {
  ValueNotifier<WorkSessionStatus> get onStateChange;
  ValueNotifier<Duration> get remainingTime;
  ValueNotifier<WorkInterval> get workInterval;
  ValueNotifier<BreakInterval> get breakInterval;

  Future<void> initialize();

  void setWorkInterval(WorkInterval interval);
  void setBreakInterval(BreakInterval interval);

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
  final ValueNotifier<WorkInterval> workInterval = ValueNotifier<WorkInterval>(
    .work25,
  );
  @override
  final ValueNotifier<BreakInterval> breakInterval =
      ValueNotifier<BreakInterval>(.break5);

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

    // Convert saved Duration to enum
    workInterval.value = _durationToWorkInterval(savedWorkInterval);
    breakInterval.value = _durationToBreakInterval(savedBreakInterval);
    remainingTime.value = Duration.zero;

    _isInitialized = true;
  }

  @override
  void setWorkInterval(WorkInterval interval) {
    workInterval.value = interval;
    _workTimerRepo.setWorkInterval(interval.duration);

    // If currently in work session and paused/idle, update remaining time
    if (onStateChange.value == WorkSessionStatus.idle ||
        onStateChange.value == WorkSessionStatus.workPaused) {
      remainingTime.value = interval.duration;
    }
  }

  @override
  void setBreakInterval(BreakInterval interval) {
    breakInterval.value = interval;
    _workTimerRepo.setBreakInterval(interval.duration);

    // If currently in break session and paused/idle, update remaining time
    if (onStateChange.value == WorkSessionStatus.breakPaused) {
      remainingTime.value = interval.duration;
    }
  }

  @override
  void startWorkSession() {
    _cancelTimer();

    // If starting fresh or resuming from completion
    if (onStateChange.value == WorkSessionStatus.idle ||
        onStateChange.value == WorkSessionStatus.workCompleted ||
        onStateChange.value == WorkSessionStatus.breakCompleted) {
      _currentSessionDuration = workInterval.value.duration;
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
    remainingTime.value = workInterval.value.duration;
    onStateChange.value = WorkSessionStatus.idle;
  }

  @override
  void startBreakSession() {
    _cancelTimer();

    // If starting fresh or resuming from completion
    if (onStateChange.value == WorkSessionStatus.idle ||
        onStateChange.value == WorkSessionStatus.workCompleted ||
        onStateChange.value == WorkSessionStatus.breakCompleted) {
      _currentSessionDuration = breakInterval.value.duration;
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
    remainingTime.value = breakInterval.value.duration;
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
        _cancelTimer();

        if (onStateChange.value == WorkSessionStatus.workInProgress) {
          onStateChange.value = WorkSessionStatus.workCompleted;
          remainingTime.value = workInterval.value.duration;
        } else if (onStateChange.value == WorkSessionStatus.breakInProgress) {
          onStateChange.value = WorkSessionStatus.breakCompleted;
          remainingTime.value = workInterval.value.duration;
        }
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  WorkInterval _durationToWorkInterval(Duration duration) {
    return WorkInterval.values.firstWhere(
      (interval) => interval.duration == duration,
      orElse: () => WorkInterval.work25,
    );
  }

  BreakInterval _durationToBreakInterval(Duration duration) {
    return BreakInterval.values.firstWhere(
      (interval) => interval.duration == duration,
      orElse: () => BreakInterval.break5,
    );
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
