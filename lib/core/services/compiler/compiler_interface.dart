import 'dart:async';
import 'dart:io';

import 'package:dartpad_lite/core/services/compiler/compiler_error.dart';
import 'package:dartpad_lite/core/services/compiler/compiler_result.dart';

abstract class CompilerInterface {
  Sink<dynamic> get inputSink;
  Stream<CompilerResult> get outputStream;

  Future<void> runCode(String code);
  Future<CompilerResult> formatCode(String code);
}

class Compiler implements CompilerInterface {
  late StreamController<dynamic> inpSink = StreamController();
  late StreamController<CompilerResult> resultStream = StreamController();

  @override
  Sink get inputSink => inpSink.sink;

  @override
  Stream<CompilerResult> get outputStream => resultStream.stream;

  Process? currentProcess;

  @override
  Future<CompilerResult> formatCode(String code) {
    throw CompilerNotSelected();
  }

  @override
  Future<void> runCode(String code) {
    throw CompilerNotSelected();
  }
}
