import 'package:dartpad_lite/core/services/work_timer/work_timer_service.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/work_timer/intervals.dart';

abstract class WorkTimerSettingVMInterface {
  ValueNotifier<WorkInterval> get workInterval;
  ValueNotifier<BreakInterval> get breakInterval;

  Future<void> setWorkInterval(WorkInterval interval);
  Future<void> setBreakInterval(BreakInterval interval);
}

class WorkTimerSettingVM implements WorkTimerSettingVMInterface {
  final WorkTimerServiceInterface _workTimerService = WorkTimerService();

  @override
  ValueNotifier<WorkInterval> get workInterval => _workTimerService.workInterval;
  @override
  ValueNotifier<BreakInterval> get breakInterval => _workTimerService.breakInterval;

  @override
  Future<void> setBreakInterval(BreakInterval interval) async {
    _workTimerService.setBreakInterval(interval);
    breakInterval.value = interval;
  }

  @override
  Future<void> setWorkInterval(WorkInterval interval) async {
    _workTimerService.setWorkInterval(interval);
    workInterval.value = interval;
    _workTimerService.resetWorkSession();
  }
}
