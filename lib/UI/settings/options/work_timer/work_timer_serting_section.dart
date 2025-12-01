import 'package:dartpad_lite/UI/settings/options/setting_option.dart';
import 'package:dartpad_lite/UI/settings/options/work_timer/work_timer_setting_vm.dart';
import 'package:flutter/material.dart';

import '../../../../utils/app_colors.dart';
import '../setting_section.dart';

class WorkTimerSettingsSection extends StatefulWidget {
  const WorkTimerSettingsSection({super.key});

  @override
  State<WorkTimerSettingsSection> createState() =>
      _WorkTimerSettingsSectionState();
}

class _WorkTimerSettingsSectionState extends State<WorkTimerSettingsSection> {
  late final WorkTimerSettingVMInterface _vm = WorkTimerSettingVM();

  Duration _workInterval = const Duration(minutes: 25);
  Duration _breakInterval = const Duration(minutes: 5);

  final List<({String label, Duration duration})> _workIntervals = [
    (label: '25 min', duration: const Duration(minutes: 25)),
    (label: '45 min', duration: const Duration(minutes: 45)),
    (label: '1 hour', duration: const Duration(hours: 1)),
    (label: '2 hours', duration: const Duration(hours: 2)),
  ];

  final List<({String label, Duration duration})> _breakIntervals = [
    (label: '5 min', duration: const Duration(minutes: 5)),
    (label: '10 min', duration: const Duration(minutes: 10)),
    (label: '15 min', duration: const Duration(minutes: 15)),
    (label: '30 min', duration: const Duration(minutes: 30)),
  ];

  @override
  Widget build(BuildContext context) {
    return SettingSection(
      title: 'Work Timer',
      children: [
        ValueListenableBuilder(
          valueListenable: _vm.onSettingsUpdate,
          builder: (_, value, __) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                SettingOption(
                  height: 100,
                  title: 'Work Interval',
                  child: DropdownButtonFormField<Duration>(
                    initialValue: _workInterval,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    dropdownColor: Colors.grey[850],
                    style: const TextStyle(color: Colors.white),
                    items: _workIntervals.map((interval) {
                      return DropdownMenuItem<Duration>(
                        value: interval.duration,
                        child: Text(interval.label),
                      );
                    }).toList(),
                    onChanged: (Duration? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _workInterval = newValue;
                        });
                      }
                    },
                  ),
                ),
                SettingOption(
                  height: 100,
                  title: 'Break Interval',
                  child: DropdownButtonFormField<Duration>(
                    initialValue: _breakInterval,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    dropdownColor: Colors.grey[850],
                    style: const TextStyle(color: Colors.white),
                    items: _breakIntervals.map((interval) {
                      return DropdownMenuItem<Duration>(
                        value: interval.duration,
                        child: Text(interval.label),
                      );
                    }).toList(),
                    onChanged: (Duration? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _breakInterval = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
