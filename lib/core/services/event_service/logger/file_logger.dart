import 'package:dartpad_lite/core/services/event_service/event_service.dart';
import 'package:dartpad_lite/core/services/event_service/logger/app_logger.dart';

abstract class FileLoggerInterface implements AppLoggerInterface {}

class FileLogger implements FileLoggerInterface {
  @override
  void log(Event event) {
    // TODO: implement log
  }
}
