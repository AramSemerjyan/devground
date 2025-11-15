import 'dart:developer' as dev;

import 'package:dartpad_lite/core/services/event_service/event_service.dart';
import 'package:dartpad_lite/core/services/event_service/logger/app_logger.dart';
import 'package:flutter/foundation.dart';

enum _ConsoleLogType { debug, success, warning, error }

extension _LogTypeExt on _ConsoleLogType {
  String get title {
    switch (this) {
      case _ConsoleLogType.debug:
        return 'debug';
      case _ConsoleLogType.success:
        return 'success';
      case _ConsoleLogType.warning:
        return 'warning';
      case _ConsoleLogType.error:
        return 'error';
    }
  }

  String get symbol {
    switch (this) {
      case _ConsoleLogType.debug:
        return '👨‍💻';
      case _ConsoleLogType.success:
        return '✅';
      case _ConsoleLogType.warning:
        return '⚠️';
      case _ConsoleLogType.error:
        return '❌';
    }
  }
}

abstract class ConsoleLoggerInterface implements AppLoggerInterface {}

class ConsoleLogger implements ConsoleLoggerInterface {
  debug(Object? object, {String? title}) =>
      _print(object, _ConsoleLogType.debug, title);

  success(Object? object, {String? title}) =>
      _print(object, _ConsoleLogType.success, title);

  warning(Object? object, {String? title}) =>
      _print(object, _ConsoleLogType.warning, title);

  error(Object? object, {String? title}) {
    _print(object, _ConsoleLogType.error, title ?? 'ERROR');
  }

  _print(Object? object, _ConsoleLogType type, String? title) {
    if (kDebugMode) {
      String separator = '=================';

      if (title != null) {
        separator = '$separator $title $separator';
      }

      dev.log('''
    \n
      $separator
      ${type.symbol}:${type.title.toUpperCase()}: $object
      $separator
      ''');
    }
  }

  @override
  void log(Event event) {
    final status = event.status;

    if (status == null) {
      return;
    }

    switch (status.type) {
      case StatusType.error:
        error(status.error?.object, title: status.msg);
        break;
      case StatusType.warning:
        error(event.data, title: status.msg);
        break;
      case StatusType.success:
        success(event.data, title: status.msg);
      case StatusType.idle:
        debug(event.data, title: status.msg);
    }
  }
}
