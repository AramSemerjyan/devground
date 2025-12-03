import 'package:dartpad_lite/core/services/work_timer/work_timer_service.dart';
import 'package:flutter/material.dart';

abstract class WorkTimerWidgetVMInterface {
  ValueNotifier<WorkSessionStatus> get onStateChange;
  ValueNotifier<Duration> get remainingTime;

  void setWorkInterval(Duration duration);
  void setBreakInterval(Duration duration);

  void startWorkSession();
  void pauseWorkSession();
  void resetWorkSession();

  void startBreakSession();
  void pauseBreakSession();
  void resetBreakSession();

  void onTap();
}

class WorkTimerWidgetVM implements WorkTimerWidgetVMInterface {
  final WorkTimerServiceInterface _workTimerService = WorkTimerService();

  @override
  ValueNotifier<WorkSessionStatus> get onStateChange =>
      _workTimerService.onStateChange;

  @override
  ValueNotifier<Duration> get remainingTime => _workTimerService.remainingTime;

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
  void setBreakInterval(Duration duration) {
    _workTimerService.setBreakInterval(duration);
  }

  @override
  void setWorkInterval(Duration duration) {
    _workTimerService.setWorkInterval(duration);
  }

  @override
  void startBreakSession() {
    _workTimerService.startBreakSession();
  }

  @override
  void startWorkSession() {
    _workTimerService.startWorkSession();
  }

@override
  void onTap() {
    switch (onStateChange.value) {
      case WorkSessionStatus.idle:
      case WorkSessionStatus.workPaused:
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
      case WorkSessionStatus.breakCompleted:
        resetWorkSession();
        break;
    }
  }
}
