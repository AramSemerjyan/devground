import 'package:dartpad_lite/UI/common/work_timer/work_timer_widget_vm.dart';
import 'package:flutter/material.dart';

import '../../../core/services/work_timer/work_timer_service.dart';
import '../Animations /ai_mode_animation.dart';

class WorkTimerWidget extends StatefulWidget {
  const WorkTimerWidget({super.key});

  @override
  State<WorkTimerWidget> createState() => _WorkTimerWidgetState();
}

class _WorkTimerWidgetState extends State<WorkTimerWidget> {
  final WorkTimerWidgetVMInterface _vm = WorkTimerWidgetVM();

  Widget _getIconForStatus(WorkSessionStatus status) {
    switch (status) {
      case WorkSessionStatus.workInProgress:
        return WorkTimerAnimation(size: 14);
      case WorkSessionStatus.breakInProgress:
        return Icon(Icons.pause_outlined, size: 14, color: Colors.white54);
      case WorkSessionStatus.idle:
      default:
        return Icon(Icons.timer_outlined, size: 14, color: Colors.white54);
    }
  }

  @override
  Widget build(BuildContext context) {
    _vm.onStateChange.value = WorkSessionStatus.workInProgress;

    return ValueListenableBuilder(
      valueListenable: _vm.onStateChange,
      builder: (_, state, __) {
        return Tooltip(message: 'Work Timer', child: _getIconForStatus(state));
      },
    );
  }
}
