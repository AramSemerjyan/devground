import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'compiler_interface.dart';

class ShellCompiler implements CompilerInterface {
  final String path;
  final uuid = const Uuid();

  ShellCompiler(this.path);

  @override
  Future<CompilerResult> runCode(String code) async {
    try {
      // Write code to a temporary file
      final tmpDir = await getTemporaryDirectory();
      final id = uuid.v4();
      final tempFile = File('${tmpDir.path}/snippet_fmt_$id.dart');
      await tempFile.writeAsString(code);

      final exe = path.isNotEmpty ? '$path/bash' : 'sh';

      // Ensure executable permissions
      if (Platform.isLinux || Platform.isMacOS) {
        await Process.run('chmod', ['+x', tempFile.path]);
      }

      // Run the shell script
      final result = await Process.run(exe, [tempFile.path]);

      // Combine stdout/stderr
      final output = result.stdout.toString();
      final error = result.stderr.toString().isNotEmpty
          ? result.stderr.toString()
          : null;

          if (error != null) {
            return CompilerResult(error: error);
          }

      return CompilerResult(data: output);
    } catch (e) {
      return CompilerResult(error: e.toString());
    }
  }

  @override
  Future<CompilerResult> formatCode(String code) async {
    try {
      // Basic shell formatting:
      // - Trim trailing spaces
      // - Ensure Unix line endings
      final formatted = code
          .split('\n')
          .map((line) => line.trimRight())
          .join('\n')
          .replaceAll('\r\n', '\n');

      return CompilerResult(data: formatted);
    } catch (e) {
      return CompilerResult(error: e.toString());
    }
  }
}
