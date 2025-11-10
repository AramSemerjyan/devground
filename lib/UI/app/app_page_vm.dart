import 'package:dartpad_lite/services/event_service.dart';

import '../../../settings_manager.dart';

enum SDKState { inProgress, ready, notReady }

class AppPageVM {
  void checkLanguageState() async {
    StatusEvent.instance.onEvent.add(
      Event(type: EventType.idle, title: 'Initializing...'),
    );

    final path = await SettingsManager.getFlutterPath();

    if (path != null && path.isNotEmpty) {
      StatusEvent.instance.onEvent.add(
        Event(type: EventType.idle, title: 'Ready'),
      );
    } else {
      StatusEvent.instance.onEvent.add(
        Event(type: EventType.sdkSetUp, title: 'Setup SDK path in setting'),
      );
    }
  }
}
