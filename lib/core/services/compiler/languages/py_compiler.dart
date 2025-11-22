import 'dart:convert';
import 'dart:io';

import 'package:dartpad_lite/core/services/compiler/compiler_error.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../compiler_interface.dart';
import '../compiler_result.dart';

class PythonCompiler extends Compiler {
  String? _path;
  final uuid = const Uuid();

  @override
  Future<CompilerResult> formatCode(String code) async {
                if (_path == null) {
      throw CompilerSDKPathMissing();
    }

    final tmpDir = await getTemporaryDirectory();
    final id = uuid.v4();
    final file = File('${tmpDir.path}/snippet_fmt_$id.py');
    await file.writeAsString(code);

    final pythonFormatter = _path!.isNotEmpty
        ? '$_path/black'
        : 'black';

    // Run black formatter silently
    final proc = await Process.start(pythonFormatter, ['--quiet', file.path]);

    final exitCode = await proc.exitCode;
    if (exitCode == 0) {
      final formatted = await file.readAsString();
      return CompilerResult.message(data: formatted);
    } else {
      return CompilerResult.error(
        data: 'Python formatting failed with exit code $exitCode',
      );
    }
  }

  @override
  Future<void> runCode(String code) async {
                if (_path == null) {
      throw CompilerSDKPathMissing();
    }

    final tmpDir = await getTemporaryDirectory();
    final id = uuid.v4();
    final file = File('${tmpDir.path}/snippet_$id.py');
    await file.writeAsString(code);

    final pythonExecutable = _path!.isNotEmpty
        ? '$_path/python3'
        : 'python3'; // fallback to system Python

    final proc = await Process.start(pythonExecutable, [file.path]);

    final stdoutBuffer = StringBuffer();
    final stderrBuffer = StringBuffer();

    proc.stdout.transform(utf8.decoder).listen(stdoutBuffer.write);
    proc.stderr.transform(utf8.decoder).listen(stderrBuffer.write);

    final exitCode = await proc.exitCode;

    if (exitCode != 0) {
      resultStream.sink.add(
        CompilerResult.error(
          data: _extractPythonError(stderrBuffer.toString()),
        ),
      );
      return;
    }

    resultStream.sink.add(CompilerResult.done(data: stdoutBuffer.toString()));
  }

    @override
  Future<void> setPath(String? path) async {
    _path = path;
  }

  String _extractPythonError(String stderr) {
    // Simplify Python traceback by showing the last line (the actual error)
    final lines = stderr.trim().split('\n');
    if (lines.isEmpty) return stderr;
    final lastLine = lines.last;
    return '${lines.take(3).join('\n')}\n→ $lastLine';
  }
}
