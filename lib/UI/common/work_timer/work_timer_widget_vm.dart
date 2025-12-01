import 'package:dartpad_lite/core/services/work_timer/work_timer_service.dart';
import 'package:flutter/material.dart';

abstract class WorkTimerWidgetVMInterface {
  ValueNotifier<WorkSessionStatus> get onStateChange;

  void setWorkInterval(Duration duration);
  void setBreakInterval(Duration duration);

  void startWorkSession();
  void pauseWorkSession();
  void resetWorkSession();

  void startBreakSession();
  void pauseBreakSession();
  void resetBreakSession();
}

class WorkTimerWidgetVM implements WorkTimerWidgetVMInterface {
  final WorkTimerServiceInterface _workTimerService = WorkTimerService();

  @override
  ValueNotifier<WorkSessionStatus> get onStateChange =>
      _workTimerService.onStateChange;

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
}
