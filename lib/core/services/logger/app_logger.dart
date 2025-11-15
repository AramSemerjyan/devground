abstract class AppLoggerInterface {
  void log();
}

class AppLogger implements AppLoggerInterface {
  @override
  void log() {}
}
