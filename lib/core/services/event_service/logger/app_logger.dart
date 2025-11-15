import '../event_service.dart';

abstract class AppLoggerInterface {
  void log(Event event);
}

class AppLogger implements AppLoggerInterface {
  List<AppLoggerInterface> loggers;

  AppLogger(this.loggers);

  @override
  void log(Event event) {
    for (final logger in loggers) {
      logger.log(event);
    }
  }
}
