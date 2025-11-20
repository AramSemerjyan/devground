import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_logger.dart';
import '../event_service.dart';

class FileLogger implements AppLoggerInterface {
  @override
  void log(Event event) async {
        try {
      final now = DateTime.now();
      final dd = now.day.toString().padLeft(2, '0');
      final mm = now.month.toString().padLeft(2, '0');
      final yy = (now.year % 100).toString().padLeft(2, '0');

      final fileName = 'log_${dd}_${mm}_$yy.txt';

      final dir = await getApplicationDocumentsDirectory();
      final logsDir = Directory(p.join(dir.path, 'logs'));
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final file = File(p.join(logsDir.path, fileName));

      final timestamp = now.toIso8601String();
      final entry = _formatEventLine(timestamp, event);

      await file.writeAsString(
        '$entry\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  String _formatEventLine(String timestamp, Event event) {
    final buffer = StringBuffer();
    buffer.write('[$timestamp] ');
    if (event.type != null) {
      buffer.write('type=${event.type} ');
    }
    if (event.status != null) {
      buffer.write('status=${event.status!.type} ');
      if (event.status!.msg != null) {
        buffer.write('msg="${event.status!.msg}" ');
      }
      if (event.status!.error != null) {
        buffer.write('error=${event.status!.error?.stackTrace.toString()} ');
        buffer.write('error=${event.status!.error.toString()} ');
      }
    }
    if (event.data != null) {
      buffer.write('data=${event.data}');
    }
    return buffer.toString();
  }
}
