import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class WorkTimerSettings extends StatefulWidget {
  const WorkTimerSettings({super.key});

  @override
  State<WorkTimerSettings> createState() => _WorkTimerSettingsState();
}

class _WorkTimerSettingsState extends State<WorkTimerSettings> {
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
    return Material(
      color: Colors.grey[900],
      elevation: 12,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Work Interval',
                  style: TextStyle(
                    color: AppColor.mainGreyLighter,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Expanded(
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
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Break Interval',
                  style: TextStyle(
                    color: AppColor.mainGreyLighter,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Expanded(
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
            ),
          ],
        ),
      ),
    );
  }
}
