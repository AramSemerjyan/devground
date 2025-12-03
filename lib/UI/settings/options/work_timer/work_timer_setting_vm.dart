import 'package:dartpad_lite/core/storage/work_timer_repo.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/work_timer/intervals.dart';

abstract class WorkTimerSettingVMInterface {
  ValueNotifier<WorkInterval> get workInterval;
  ValueNotifier<BreakInterval> get breakInterval;

  Future<void> setWorkInterval(WorkInterval interval);
  Future<void> setBreakInterval(BreakInterval interval);
}

class WorkTimerSettingVM implements WorkTimerSettingVMInterface {
  final WorkTimerRepoInterface _workTimerRepo = WorkTimerRepo();

  WorkTimerSettingVM() {
    _fetch();
  }

  @override
  final ValueNotifier<WorkInterval> workInterval = ValueNotifier<WorkInterval>(
    WorkInterval.work25,
  );
  @override
  final ValueNotifier<BreakInterval> breakInterval =
      ValueNotifier<BreakInterval>(BreakInterval.break5);

  @override
  Future<void> setBreakInterval(BreakInterval interval) async {
    await _workTimerRepo.setBreakInterval(interval.duration);
    breakInterval.value = interval;
  }

  @override
  Future<void> setWorkInterval(WorkInterval interval) async {
    await _workTimerRepo.setWorkInterval(interval.duration);
    workInterval.value = interval;
  }

  void _fetch() async {
    final workDuration = await _workTimerRepo.getWorkInterval();
    final breakDuration = await _workTimerRepo.getBreakInterval();

    final workIntervalValue = WorkInterval.values.firstWhere(
      (element) => element.duration == workDuration,
      orElse: () => WorkInterval.work25,
    );
    final breakIntervalValue = BreakInterval.values.firstWhere(
      (element) => element.duration == breakDuration,
      orElse: () => BreakInterval.break5,
    );

    workInterval.value = workIntervalValue;
    breakInterval.value = breakIntervalValue;
  }
}
