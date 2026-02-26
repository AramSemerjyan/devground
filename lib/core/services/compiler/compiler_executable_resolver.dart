import 'dart:io';

typedef ConfiguredCandidatesBuilder =
    List<String> Function(String configuredPath);

mixin CompilerExecutableResolver {
  Future<String?> resolveCompilerExecutable({
    required String? configuredPath,
    required ConfiguredCandidatesBuilder configuredCandidates,
    required List<String> whichCandidates,
    List<String> probeArgs = const ['--version'],
  }) async {
    final normalizedPath = configuredPath?.trim();

    if (normalizedPath != null && normalizedPath.isNotEmpty) {
      final configured = _distinctCandidates(
        configuredCandidates(normalizedPath),
      );
      for (final executable in configured) {
        if (await _canStartExecutable(executable, probeArgs)) {
          return executable;
        }
      }
    }

    for (final candidate in whichCandidates) {
      final resolved = await _runWhich(candidate);
      if (resolved == null) continue;
      if (await _canStartExecutable(resolved, probeArgs)) {
        return resolved;
      }
    }

    for (final fallback in whichCandidates) {
      if (await _canStartExecutable(fallback, probeArgs)) {
        return fallback;
      }
    }

    return null;
  }

  static List<String> _distinctCandidates(List<String> candidates) {
    final seen = <String>{};
    final result = <String>[];
    for (final item in candidates) {
      final normalized = item.trim();
      if (normalized.isEmpty) continue;
      if (seen.add(normalized)) {
        result.add(normalized);
      }
    }
    return result;
  }

  Future<bool> _canStartExecutable(
    String executable,
    List<String> probeArgs,
  ) async {
    try {
      await Process.run(executable, probeArgs);
      return true;
    } on ProcessException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _runWhich(String executable) async {
    try {
      final result = await Process.run('which', [executable]);
      if (result.exitCode != 0) return null;
      final stdout = result.stdout.toString().trim();
      if (stdout.isEmpty) return null;
      return stdout.split('\n').first.trim();
    } catch (_) {
      return null;
    }
  }
}
