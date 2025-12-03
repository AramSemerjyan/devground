import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

import '../../storage/compiler_repo.dart';
import '../event_service/app_error.dart';
import '../event_service/event_service.dart';

abstract class FileServiceInterface {
  Future<List<File>> getHistoryFiles();
  Future<File?> saveMonacoCodeToFile({required String raw, String? fileName});
  Future<void> saveToFile({
    required String raw,
    String? fileName,
    String? extension,
  });
  Future<bool> deleteFile({required File file});
  Future<void> revealInFinder({required File file});
}

class FileService implements FileServiceInterface {
  final CompilerRepoInterface _languageRepo;

  FileService(this._languageRepo);

  @override
  Future<File?> saveMonacoCodeToFile({
    required String raw,
    String? fileName,
  }) async {
    final name = fileName ?? 'main';
    final selectedLanguage = _languageRepo.selectedLanguage.value;

    final extension = selectedLanguage?.extension;
    final fullName = '$name$extension';

    try {
      final appDir = await getApplicationSupportDirectory();

      final historyDir = Directory('${appDir.path}/history');
      if (!await historyDir.exists()) await historyDir.create();

      final file = File('${historyDir.path}/$fullName');
      await file.writeAsString(raw);

      EventService.success(msg: 'Saved ${file.path}');
      return file;
    } catch (e, s) {
      EventService.error(
        msg: e.toString(),
        error: AppError(object: e, stackTrace: s),
      );
      return null;
    }
  }

  @override
  Future<void> saveToFile({
    required String raw,
    String? fileName,
    String? extension,
  }) async {
    final name = fileName ?? 'file';

    final fullName = '$name.$extension';

    try {
      final appDir = await getApplicationSupportDirectory();

      final historyDir = Directory('${appDir.path}/history');
      if (!await historyDir.exists()) await historyDir.create();

      final file = File('${historyDir.path}/$fullName');
      await file.writeAsString(raw);

      EventService.success(msg: 'Saved ${file.path}');
    } catch (e, s) {
      EventService.error(
        msg: e.toString(),
        error: AppError(object: e, stackTrace: s),
      );
    }
  }

  @override
  Future<List<File>> getHistoryFiles() async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final historyDir = Directory('${appDir.path}/history');

      if (!await historyDir.exists()) {
        // If folder doesn't exist, return empty list
        return [];
      }

      // List all files (non-recursive)
      final files = historyDir.listSync().whereType<File>().toList();

      // Optionally sort by modified time (newest first)
      files.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      return files;
    } catch (e, s) {
      EventService.error(
        msg: e.toString(),
        error: AppError(object: e, stackTrace: s),
      );
      return [];
    }
  }

  @override
  Future<bool> deleteFile({required File file}) async {
    try {
      if (await file.exists()) {
        await file.delete();
        EventService.success(msg: 'Successfully deleted');
        return true;
      }
      return false;
    } catch (e, s) {
      EventService.error(
        msg: e.toString(),
        error: AppError(object: e, stackTrace: s),
      );
      return false;
    }
  }

  @override
  Future<void> revealInFinder({required File file}) async {
    if (!await file.exists()) return;

    final shell = Shell();

    if (Platform.isMacOS) {
      await shell.run('open -R "${file.path}"');
    } else if (Platform.isWindows) {
      await shell.run('explorer /select,"${file.path.replaceAll('/', '\\')}"');
    } else if (Platform.isLinux) {
      // Try xdg-open to open the containing directory
      final dir = file.parent.path;
      await shell.run('xdg-open "$dir"');
    }
  }
}
