import 'dart:convert';
import 'dart:io';

import 'package:dartpad_lite/core/services/compiler/compiler_error.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../compiler_interface.dart';
import '../compiler_result.dart';

class PythonCompiler extends Compiler {
  String? _path;
  String? _resolvedPythonExecutable;
  final uuid = const Uuid();

  @override
  Future<CompilerResult> formatCode(String code) async {
    return CompilerResult.warning(
      message: 'No formatting available for Python.',
    );
  }

  @override
  Future<void> runCode(String code) async {
    try {
      final tmpDir = await getTemporaryDirectory();
      final id = uuid.v4();
      final file = File('${tmpDir.path}/snippet_$id.py');
      await file.writeAsString(code);

      final pythonExecutable = await _resolvePythonExecutable();

      final proc = await Process.start(pythonExecutable, [file.path]);

      final stdoutBuffer = StringBuffer();
      final stderrBuffer = StringBuffer();

      proc.stdout.transform(utf8.decoder).listen(stdoutBuffer.write);
      proc.stderr.transform(utf8.decoder).listen(stderrBuffer.write);

      final exitCode = await proc.exitCode;

      if (exitCode != 0) {
        resultStream.sink.add(
          CompilerResult.error(
            data: stdoutBuffer.toString(),
            error: CompilerExecutionError(
              _extractPythonError(stderrBuffer.toString()),
            ),
            message: 'Process exited with code $exitCode',
          ),
        );
        return;
      }

      resultStream.add(
        CompilerResult.done(
          data: stdoutBuffer.toString(),
          message: 'Process exited with code 0',
        ),
      );

      resultStream.sink.add(CompilerResult.done(data: stdoutBuffer.toString()));
    } catch (e, s) {
      resultStream.sink.add(CompilerResult.error(error: e, data: s.toString()));
    }
  }

  @override
  Future<void> setPath(String? path) async {
    _path = path;
    _resolvedPythonExecutable = null;
  }

  String _extractPythonError(String stderr) {
    // Simplify Python traceback by showing the last line (the actual error)
    final lines = stderr.trim().split('\n');
    if (lines.isEmpty) return stderr;
    final lastLine = lines.last;
    return '${lines.take(3).join('\n')}\n→ $lastLine';
  }

  Future<String> _resolvePythonExecutable() async {
    final cached = _resolvedPythonExecutable;
    if (cached != null && cached.isNotEmpty) return cached;

    final resolved = await resolveCompilerExecutable(
      configuredPath: _path,
      configuredCandidates: (path) => [path, '$path/python3'],
      whichCandidates: const ['python3'],
    );

    if (resolved == null) {
      throw CompilerSDKPathMissing();
    }

    _resolvedPythonExecutable = resolved;
    return resolved;
  }
}
