import 'package:dartpad_lite/UI/common/work_timer/work_timer_progress_painter.dart';
import 'package:dartpad_lite/core/services/work_timer/work_timer_service.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';

import 'work_timer_vm.dart';

class WorkTimerButton extends StatefulWidget {
  const WorkTimerButton({super.key});

  @override
  State<WorkTimerButton> createState() => _WorkTimerButtonState();
}

class _WorkTimerButtonState extends State<WorkTimerButton> {
  late final WorkTimerVMInterface _vm = WorkTimerVM();

  String _formatDuration(Duration duration) {
    if (duration.inHours >= 1) {
      // Show HH:MM when >= 1 hour
      final hours = duration.inHours.toString().padLeft(2, '0');
      final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
      return '$hours:$minutes';
    } else {
      // Show MM:SS when < 1 hour
      final minutes = duration.inMinutes.toString().padLeft(2, '0');
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    }
  }

  String _getTooltipForStatus(WorkSessionStatus status) {
    switch (status) {
      case .workInProgress:
        return 'Press to pause work';
      case .breakInProgress:
        return 'Press to pause break';
      case .workPaused:
      case .breakCompleted:
        return 'Press to work';
      case .breakPaused:
      case .workCompleted:
        return 'Press to break';
      case .idle:
        return 'Work Timer';
    }
  }

  String _getTitleForStatus(WorkSessionStatus status) {
    switch (status) {
      case .workInProgress:
        return 'Work';
      case .breakInProgress:
        return 'Break';
      case .workPaused:
        return 'Work';
      case .breakPaused:
        return 'Break';
      case .breakCompleted:
        return 'Work';
      case .workCompleted:
        return 'Break';
      case .idle:
        return '';
    }
  }

  Widget _getIconForStatus(WorkSessionStatus status, double size) {
    switch (status) {
      case .workInProgress:
      case .breakInProgress:
        return Icon(Icons.pause_outlined, size: size, color: Colors.white54);
      case .workCompleted:
      case .breakPaused:
        return Icon(Icons.coffee_outlined, size: size, color: Colors.white54);
      case .breakCompleted:
      case .idle:
      default:
        return Icon(Icons.timer_outlined, size: size, color: Colors.white54);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _vm.onTap,
      child: ValueListenableBuilder<WorkSessionStatus>(
        valueListenable: _vm.onStateChange,
        builder: (context, status, _) {
          return ValueListenableBuilder<Duration>(
            valueListenable: _vm.remainingTime,
            builder: (context, remainingTime, _) {
              final totalDuration =
                  status == WorkSessionStatus.breakInProgress ||
                      status == WorkSessionStatus.breakPaused ||
                      status == WorkSessionStatus.breakCompleted
                  ? _vm.breakInterval.value.duration
                  : _vm.workInterval.value.duration;

              final progress =
                  remainingTime.inSeconds / totalDuration.inSeconds;

              final color = AppColor.mainGreyLighter;

              return Tooltip(
                message: _getTooltipForStatus(status),
                child: SizedBox(
                  width: 45,
                  height: 45,
                  child: CustomPaint(
                    painter: CircularProgressPainter(
                      progress: progress,
                      color: color,
                      backgroundColor: color.withValues(alpha: 0.2),
                      strokeWidth: 3,
                    ),
                    child: Column(
                      crossAxisAlignment: .center,
                      children: [
                        const SizedBox(height: 4),
                        _getIconForStatus(status, 12),
                        const SizedBox(height: 1),
                        Text(
                          _formatDuration(remainingTime),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          _getTitleForStatus(status),
                          style: TextStyle(fontSize: 6, color: color),
                        ),
                        const SizedBox(height: 3),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
