import 'dart:io';

import 'package:dartpad_lite/core/services/compiler/compiler_error.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../compiler_interface.dart';
import '../compiler_result.dart';

class ShellCompiler extends Compiler {
  String? _path;
  String? _resolvedShellExecutable;
  final uuid = const Uuid();

  @override
  Future<void> runCode(String code) async {
    try {
      // Write code to a temporary file
      final tmpDir = await getTemporaryDirectory();
      final id = uuid.v4();
      final tempFile = File('${tmpDir.path}/snippet_shell_$id.sh');
      await tempFile.writeAsString(code);

      final exe = await _resolveShellExecutable();

      // Ensure executable permissions
      if (Platform.isLinux || Platform.isMacOS) {
        await Process.run('chmod', ['+x', tempFile.path]);
      }

      // Run the shell script
      final result = await Process.run(exe, [tempFile.path]);

      final output = result.stdout.toString();
      final error = result.stderr.toString().isNotEmpty
          ? result.stderr.toString()
          : null;

      if (error != null) {
        resultStream.sink.add(
          CompilerResult.error(
            data: error,
            error: CompilerExecutionError('Shell script failed with errors'),
            message: 'Shell script failed with errors',
          ),
        );
        return;
      }

      resultStream.sink.add(
        CompilerResult.done(
          data: output,
          message: 'Shell script executed successfully',
        ),
      );
    } catch (e, s) {
      resultStream.sink.add(CompilerResult.error(error: e, stackTrace: s));
    }
  }

  @override
  Future<CompilerResult> formatCode(String code) async {
    if (_path == null) {
      throw CompilerSDKPathMissing();
    }

    try {
      // Basic shell formatting:
      // - Trim trailing spaces
      // - Ensure Unix line endings
      final formatted = code
          .split('\n')
          .map((line) => line.trimRight())
          .join('\n')
          .replaceAll('\r\n', '\n');

      return CompilerResult.message(data: formatted);
    } catch (e) {
      return CompilerResult.error(error: e.toString());
    }
  }

  @override
  Future<void> setPath(String? path) async {
    _path = path;
    _resolvedShellExecutable = null;
  }

  Future<String> _resolveShellExecutable() async {
    final cached = _resolvedShellExecutable;
    if (cached != null && cached.isNotEmpty) return cached;

    final resolved = await resolveCompilerExecutable(
      configuredPath: _path,
      configuredCandidates: (path) => [path, '$path/bash'],
      whichCandidates: const ['bash'],
    );

    if (resolved == null) {
      throw CompilerSDKPathMissing();
    }

    _resolvedShellExecutable = resolved;
    return resolved;
  }
}
