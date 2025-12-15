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

class CompilerNotSupported extends CompilerError {
  CompilerNotSupported(String feature)
      : super("The feature '$feature' is not supported by the selected compiler.");
} 

class CompilerExecutionError extends CompilerError {
  CompilerExecutionError(super.message);
}
