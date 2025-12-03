import 'package:dartpad_lite/UI/settings/options/setting_option.dart';
import 'package:dartpad_lite/UI/settings/options/work_timer/work_timer_setting_vm.dart';
import 'package:dartpad_lite/core/services/work_timer/intervals.dart';
import 'package:flutter/material.dart';

import '../setting_section.dart';

class WorkTimerSettingsSection extends StatefulWidget {
  const WorkTimerSettingsSection({super.key});

  @override
  State<WorkTimerSettingsSection> createState() =>
      _WorkTimerSettingsSectionState();
}

class _WorkTimerSettingsSectionState extends State<WorkTimerSettingsSection> {
  late final WorkTimerSettingVMInterface _vm = WorkTimerSettingVM();

  @override
  Widget build(BuildContext context) {
    return SettingSection(
      title: 'Work Timer',
      children: [
        SettingOption(
          height: 100,
          title: 'Work Interval',
          child: ValueListenableBuilder(
            valueListenable: _vm.workInterval,
            builder: (_, value, _) {
              return DropdownButtonFormField<WorkInterval>(
                initialValue: value,
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
                items: WorkInterval.values.map((interval) {
                  return DropdownMenuItem<WorkInterval>(
                    value: interval,
                    child: Text(interval.title),
                  );
                }).toList(),
                onChanged: (WorkInterval? newValue) {
                  if (newValue != null) {
                    _vm.setWorkInterval(newValue);
                  }
                },
              );
            },
          ),
        ),
        SettingOption(
          height: 100,
          title: 'Break Interval',
          child: ValueListenableBuilder(
            valueListenable: _vm.breakInterval,
            builder: (_, value, _) {
              return DropdownButtonFormField<BreakInterval>(
                initialValue: value,
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
                items: BreakInterval.values.map((interval) {
                  return DropdownMenuItem<BreakInterval>(
                    value: interval,
                    child: Text(interval.title),
                  );
                }).toList(),
                onChanged: (BreakInterval? newValue) {
                  if (newValue != null) {
                    _vm.setBreakInterval(newValue);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
