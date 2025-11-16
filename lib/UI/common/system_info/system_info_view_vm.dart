import 'package:dartpad_lite/core/services/system_info/system_info_service.dart';
import 'package:flutter/cupertino.dart';

class SystemInfo {
  final double cpuUsage;
  final double usedRam;
  final double freeRam;

  SystemInfo({this.cpuUsage = 0.0, this.usedRam = 0.0, this.freeRam = 0.0});
}

abstract class SystemInfoViewVMInterface {
  ValueNotifier<SystemInfo> get onSystemInfoUpdate;

  void fetch();
}

class SystemInfoViewVM implements SystemInfoViewVMInterface {
  final SystemInfoServiceInterface _systemInfoService = SystemInfoService();

  @override
  final ValueNotifier<SystemInfo> onSystemInfoUpdate = ValueNotifier(
    SystemInfo(),
  );

  @override
  void fetch() async {
    final cpu = await _getCPUUsage();
    final ram = await _getMemoryUsage();
    onSystemInfoUpdate.value = SystemInfo(
      cpuUsage: (cpu * 10).floor() / 10,
      usedRam: (ram.$1 * 10).floor() / 10,
      freeRam: (ram.$2 * 10).floor() / 10,
    );
  }

  Future<double> _getCPUUsage() {
    return _systemInfoService.getCPUUsage();
  }

  Future<(double, double)> _getMemoryUsage() {
    return _systemInfoService.getMemoryUsage();
  }
}
