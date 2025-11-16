import 'package:flutter/services.dart';

class SystemInfoChannel {
  static const _channel = MethodChannel('system_monitor');

  static Future<Map<Object?, Object?>?> get cpuUsage async =>
      await _channel.invokeMethod('cpu');

  static Future<Map<Object?, Object?>?> get memoryUsage async =>
      await _channel.invokeMethod('memory');
}
