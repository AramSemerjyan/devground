enum CompilerResultStatus { message, error, waitingForInput, done }

class CompilerResult {
  final CompilerResultStatus status;
  final dynamic data;
  final Object? error;

  CompilerResult({required this.status, this.data, this.error});

  factory CompilerResult.message({dynamic data}) {
    return CompilerResult(status: CompilerResultStatus.message, data: data);
  }

  factory CompilerResult.done({dynamic data}) {
    return CompilerResult(status: CompilerResultStatus.done, data: data);
  }

  factory CompilerResult.error({Object? error, dynamic data}) {
    return CompilerResult(
      status: CompilerResultStatus.error,
      error: error,
      data: data,
    );
  }
}
