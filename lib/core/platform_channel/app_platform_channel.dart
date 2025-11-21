import 'package:flutter/services.dart';

class PlatformLlamaChannel {
  static const method = MethodChannel('llama.method');
  static const stream = EventChannel('llama.stream');
}

class PlatformFileOpenChannel {
  static const channel = MethodChannel('file_open_channel');
}

class PlatformSystemInfoChannel {
  static const _channel = MethodChannel('system_monitor');

  static Future<Map<Object?, Object?>?> get cpuUsage async =>
      await _channel.invokeMethod('cpu');

  static Future<Map<Object?, Object?>?> get memoryUsage async =>
      await _channel.invokeMethod('memory');
}
