import 'package:dartpad_lite/core/services/event_service/event_service.dart';
import 'package:dartpad_lite/core/services/event_service/logger/app_logger.dart';

abstract class RemoteLoggerInterface implements AppLoggerInterface {}

class RemoteLogger implements RemoteLoggerInterface {
  @override
  void log(Event event) {}
}
