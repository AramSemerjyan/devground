abstract class CompilerError implements Exception {
  final String message;
  CompilerError(this.message);

  @override
  String toString() => "CompilerError: $message";
}

class CompilerUpcomingSupport extends CompilerError {
  CompilerUpcomingSupport() : super("Upcoming support");
}

class CompilerSDKPathMissing extends CompilerError {
  CompilerSDKPathMissing() : super("SDK path missing");
}

class CompilerNotSelected extends CompilerError {
  CompilerNotSelected() : super("Compiler not selected");
}
