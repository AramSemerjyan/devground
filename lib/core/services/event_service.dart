import 'dart:async';

import 'package:dartpad_lite/core/services/logger/app_logger.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';

enum EventType {
  sdkSetUp,
  languageChangedForNewFile,
  languageChanged,
  sdkPathUpdated,
  importedFile,
  monacoDropFocus,

  onAppInactive,
  onAppResume,
}

class Event {
  final EventType? type;
  final StatusEvent? status;
  final dynamic data;

  Event({this.type, this.data, this.status});
}

enum StatusType {
  error,
  success,
  warning,
  idle;

  Color get color {
    switch (this) {
      case StatusType.error:
        return AppColor.error;
      case StatusType.success:
        return AppColor.success;
      case StatusType.warning:
        return AppColor.warning;
      default:
        return AppColor.mainGrey;
    }
  }
}

class StatusEvent {
  final StatusType type;
  final String? msg;
  final Error? error;
  final Duration? duration;

  StatusEvent({required this.type, this.msg, this.error, this.duration});

  factory StatusEvent.success({String? msg, Duration? duration}) {
    return StatusEvent(type: StatusType.success, msg: msg, duration: duration);
  }

  factory StatusEvent.error({String? msg, Error? error, Duration? duration}) {
    return StatusEvent(
      type: StatusType.error,
      msg: msg,
      error: error,
      duration: duration,
    );
  }

  factory StatusEvent.warning({String? msg, Duration? duration}) {
    return StatusEvent(type: StatusType.warning, msg: msg, duration: duration);
  }

  factory StatusEvent.idle({String? msg, Duration? duration}) {
    return StatusEvent(type: StatusType.idle, msg: msg, duration: duration);
  }
}

class EventService {
  final AppLoggerInterface logger = AppLogger();
  final StreamController<Event> _controller = StreamController.broadcast();

  EventService._internal();
  static final EventService instance = EventService._internal();

  Stream<Event> get stream => _controller.stream;

  static void emit({
    required EventType type,
    StatusEvent? status,
    dynamic data,
    Duration? duration,
  }) {
    _send(Event(type: type, status: status, data: data));
  }

  static void success({
    EventType? type,
    dynamic data,
    Duration? duration,
    String? msg,
  }) {
    _send(
      Event(
        type: type,
        data: data,
        status: StatusEvent(
          type: StatusType.success,
          msg: msg,
          duration: duration ?? Duration(seconds: 1),
        ),
      ),
    );
  }

  static void error({
    EventType? type,
    dynamic data,
    Duration? duration,
    String? msg,
    Error? error,
  }) {
    _send(
      Event(
        type: type,
        data: data,
        status: StatusEvent(
          type: StatusType.error,
          msg: msg,
          error: error,
          duration: duration ?? Duration(seconds: 1),
        ),
      ),
    );
  }

  static void warning({
    EventType? type,
    dynamic data,
    Duration? duration,
    String? msg,
  }) {
    _send(
      Event(
        type: type,
        data: data,
        status: StatusEvent(
          type: StatusType.warning,
          msg: msg,
          duration: duration ?? Duration(seconds: 1),
        ),
      ),
    );
  }

  static void idle({
    EventType? type,
    dynamic data,
    Duration? duration,
    String? msg,
  }) {
    _send(
      Event(
        type: type,
        data: data,
        status: StatusEvent(
          type: StatusType.idle,
          msg: msg,
          duration: duration ?? Duration(seconds: 1),
        ),
      ),
    );
  }

  static void _send(Event event) {
    /// TODO: implement logger logic
    EventService.instance.logger.log();

    EventService.instance._controller.add(event);
  }
}
