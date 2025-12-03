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
      case .workInProgress:
        return WorkTimerAnimation(size: 14);
      case .breakInProgress:
        return Icon(Icons.pause_outlined, size: 14, color: Colors.white54);
      case .idle:
      default:
        return Icon(Icons.timer_outlined, size: 14, color: Colors.white54);
    }
  }

  String _getTooltipForStatus(WorkSessionStatus status) {
    switch (status) {
      case .workInProgress:
        return 'Press to pause work';
      case .breakInProgress:
        return 'Press to pause break';
      case .workPaused:
        return 'Press to resume work';
      case .breakPaused:
        return 'Press to resume break';
      case .idle:
      default:
        return 'Work Timer';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _vm.onStateChange,
      builder: (_, state, __) {
        return Tooltip(
          message: _getTooltipForStatus(state),
          child: InkWell(
            onTap: _vm.onTap,
            child: Row(
              spacing: 5,
              mainAxisSize: MainAxisSize.min,
              children: [
                _getIconForStatus(state),
                if (state == WorkSessionStatus.workInProgress ||
                    state == WorkSessionStatus.breakInProgress)
                  ValueListenableBuilder(
                    valueListenable: _vm.remainingTime,
                    builder: (_, remaining, __) {
                      String twoDigits(int n) => n.toString().padLeft(2, '0');
                      final minutes = twoDigits(
                        remaining.inMinutes.remainder(60),
                      );
                      final seconds = twoDigits(
                        remaining.inSeconds.remainder(60),
                      );
                      return Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          '$minutes:$seconds',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
