enum CompilerResultStatus { message, error, waitingForInput, done }

class CompilerResult {
  final CompilerResultStatus status;
  final String? message;
  final dynamic data;
  final Object? error;
  final StackTrace? stackTrace;
  
  CompilerResult({required this.status, this.message, this.data, this.error, this.stackTrace});

  factory CompilerResult.message({String? message, dynamic data}) {
    return CompilerResult(status: CompilerResultStatus.message, message: message, data: data);
  }

  factory CompilerResult.done({String? message, dynamic data}) {
    return CompilerResult(status: CompilerResultStatus.done, message: message, data: data);
  }

  factory CompilerResult.error({Object? error, dynamic data, String? message, StackTrace? stackTrace}) {
    return CompilerResult(
      status: CompilerResultStatus.error,
      error: error,
      data: data,
      message: message,
      stackTrace: stackTrace,
    );
  }

  factory CompilerResult.empty() {
    return CompilerResult(status: CompilerResultStatus.message, data: '');
  }
}
