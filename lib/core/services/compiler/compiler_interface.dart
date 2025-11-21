import 'dart:async';
import 'dart:io';

import 'package:dartpad_lite/core/services/compiler/compiler_error.dart';
import 'package:dartpad_lite/core/services/compiler/compiler_result.dart';

abstract class CompilerInterface {
  Sink<dynamic> get inputSink;
  Stream<CompilerResult> get outputStream;

  Future<void> runCode(String code);
  Future<CompilerResult> formatCode(String code);
  void dispose();
}

class Compiler implements CompilerInterface {
  late StreamController<dynamic> inpSink = StreamController();
  late StreamController<CompilerResult> resultStream = StreamController();

  List<StreamSubscription> subscriptions = [];

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

  @override
  void dispose() {
    for (final s in subscriptions) {
      s.cancel();
    }
    inpSink.close();
    resultStream.close();
    currentProcess?.kill(ProcessSignal.sigkill);
    subscriptions.clear();
  }
}
