import 'dart:async';

import 'package:dartpad_lite/UI/common/system_info/system_info_view_vm.dart';
import 'package:flutter/material.dart';

class SystemInfoView extends StatefulWidget {
  const SystemInfoView({super.key});

  @override
  State<SystemInfoView> createState() => _SystemInfoViewState();
}

class _SystemInfoViewState extends State<SystemInfoView> {
  late final SystemInfoViewVMInterface _vm = SystemInfoViewVM();

  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();

    _syncTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _vm.fetch();
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _syncTimer = null;

    super.dispose();
  }

  Widget _buildItem(IconData icon, String title) {
    return Row(
      spacing: 5,
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _vm.onSystemInfoUpdate,
      builder: (_, value, __) {
        return Row(
          spacing: 10,
          children: [
            Tooltip(
              message: 'CPU',
              child: _buildItem(Icons.computer, '${value.cpuUsage}%'),
            ),
            Tooltip(
              message: 'RAM',
              child: _buildItem(
                Icons.memory,
                'Used: ${value.usedRam}Gb / Free: ${value.freeRam}Gb',
              ),
            ),
          ],
        );
      },
    );
  }
}
