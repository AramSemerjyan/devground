class CompilerResult {
  final bool hasError;
  final Object? error;
  final dynamic data;

  CompilerResult({this.hasError = false, this.data, this.error});
}

abstract class CompilerInterface {
  Future<CompilerResult> runCode(String code);
  Future<CompilerResult> formatCode(String code);
}
