class CompilerResult {
  final bool hasError;
  final Object? error;
  final dynamic data;

  CompilerResult({this.hasError = false, this.data, this.error});
}