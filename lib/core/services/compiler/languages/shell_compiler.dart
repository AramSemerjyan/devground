import 'dart:io';

import 'package:dartpad_lite/core/services/compiler/compiler_error.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../compiler_interface.dart';
import '../compiler_result.dart';

class ShellCompiler extends Compiler {
  String? _path;
  final uuid = const Uuid();

  @override
  @override
  Future<void> runCode(String code) async {
                    if (_path == null) {
      throw CompilerSDKPathMissing();
    }

    try {
      // Write code to a temporary file
      final tmpDir = await getTemporaryDirectory();
      final id = uuid.v4();
      final tempFile = File('${tmpDir.path}/snippet_fmt_$id.dart');
      await tempFile.writeAsString(code);

      final exe = _path!.isNotEmpty ? '$_path/bash' : 'sh';

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
        resultStream.sink.add(CompilerResult.error(data: error));
        return;
      }

      resultStream.sink.add(CompilerResult.done(data: output));
    } catch (e) {
      resultStream.sink.add(CompilerResult.error(error: e.toString()));
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
  }
}
