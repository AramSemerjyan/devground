import 'package:dartpad_lite/core/services/work_timer/intervals.dart';
import 'package:dartpad_lite/core/services/work_timer/work_timer_service.dart';
import 'package:flutter/material.dart';

import 'work_timer_state_audio_manager.dart';

abstract class WorkTimerVMInterface {
  ValueNotifier<WorkSessionStatus> get onStateChange;
  ValueNotifier<Duration> get remainingTime;

  ValueNotifier<WorkInterval> get workInterval;
  ValueNotifier<BreakInterval> get breakInterval;

  void startWorkSession();
  void pauseWorkSession();
  void resetWorkSession();

  void startBreakSession();
  void pauseBreakSession();
  void resetBreakSession();

  void onTap();
}

class WorkTimerVM implements WorkTimerVMInterface {
  final WorkTimerStateAudioManagerInterface _audioManager =
      WorkTimerStateAudioManager();
  final WorkTimerServiceInterface _workTimerService = WorkTimerService();

  @override
  ValueNotifier<WorkSessionStatus> get onStateChange =>
      _workTimerService.onStateChange;

  @override
  ValueNotifier<BreakInterval> get breakInterval =>
      _workTimerService.breakInterval;

  @override
  ValueNotifier<WorkInterval> get workInterval =>
      _workTimerService.workInterval;

  @override
  ValueNotifier<Duration> get remainingTime => _workTimerService.remainingTime;

  WorkTimerVM() {
    _audioManager.start(onStateChange);
  }

  @override
  void pauseBreakSession() {
    _workTimerService.pauseBreakSession();
  }

  @override
  void pauseWorkSession() {
    _workTimerService.pauseWorkSession();
  }

  @override
  void resetBreakSession() {
    _workTimerService.resetBreakSession();
  }

  @override
  void resetWorkSession() {
    _workTimerService.resetWorkSession();
  }

  @override
  void startBreakSession() {
    _workTimerService.startBreakSession();
  }

  @override
  void startWorkSession() async {
    await _workTimerService.initialize();
    _workTimerService.startWorkSession();
  }

  @override
  void onTap() {
    switch (onStateChange.value) {
      case WorkSessionStatus.idle:
      case WorkSessionStatus.workPaused:
      case WorkSessionStatus.breakCompleted:
        startWorkSession();
        break;
      case WorkSessionStatus.workInProgress:
        pauseWorkSession();
        break;
      case WorkSessionStatus.workCompleted:
      case WorkSessionStatus.breakPaused:
        startBreakSession();
        break;
      case WorkSessionStatus.breakInProgress:
        pauseBreakSession();
        break;
    }
  }
}
