import 'dart:async';

import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';

enum AppPage { editor }

enum EventType {
  error,
  success,
  warning,
  sdkSetUp,
  languageChangedForNewFile,
  languageChanged,
  sdkPathUpdated,
  importedFile,
  monacoDropFocus,
  idle;

  Color get color {
    switch (this) {
      case EventType.sdkSetUp:
      case EventType.error:
        return AppColor.error;
      case EventType.success:
        return AppColor.success;
      case EventType.warning:
        return AppColor.warning;
      default:
        return AppColor.mainGrey;
    }
  }
}

class Event {
  final EventType type;
  final Duration? duration;
  final String? title;
  final dynamic data;

  Event({required this.type, this.title, this.data, this.duration});

  factory Event.success({String? msg, String? title}) {
    return Event(
      type: EventType.success,
      data: msg,
      title: title,
      duration: const Duration(seconds: 1),
    );
  }

  factory Event.error({String? msg, String? title}) {
    return Event(type: EventType.error, data: msg, title: title);
  }

  factory Event.warning({String? msg, String? title}) {
    return Event(type: EventType.warning, data: msg, title: title);
  }
}

class EventService {
  final StreamController<Event> _controller = StreamController.broadcast();
  final List<Event> _buffer = [];

  EventService._internal();
  static final EventService instance = EventService._internal();

  static void error({String? msg, String? title}) {
    EventService.instance.emit(
      Event(type: EventType.error, data: msg, title: title),
    );
  }

  static event({required EventType type, dynamic data, String? title}) {
    print('EVENT: $type');
    EventService.instance.emit(Event(type: type, title: title, data: data));
  }

  Stream<Event> get stream => _controller.stream;
  // async* {
  //   // First send buffered events
  //   for (final e in _buffer) {
  //     yield e;
  //   }
  //   // Then forward new events
  //   yield* _controller.stream;
  // }

  void emit(Event event) {
    // _buffer.add(event);
    _controller.add(event);
  }
}
