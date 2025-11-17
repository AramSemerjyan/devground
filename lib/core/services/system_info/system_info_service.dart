import 'package:dartpad_lite/core/platform_channel/app_platform_channel.dart';

abstract class SystemInfoServiceInterface {
  Future<double> getCPUUsage();
  Future<(double, double)> getMemoryUsage();
}

class SystemInfoService implements SystemInfoServiceInterface {
  @override
  Future<double> getCPUUsage() async {
    final info = await PlatformSystemInfoChannel.cpuUsage;

    return info?['cpu'] as double? ?? 0.0;
  }

  @override
  Future<(double, double)> getMemoryUsage() async {
    final info = await PlatformSystemInfoChannel.memoryUsage;

    return ((info?['used'] as double? ?? 0), (info?['free'] as double? ?? 0));
  }
}
