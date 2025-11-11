import 'dart:io';

import 'package:dartpad_lite/services/event_service.dart';
import 'package:dartpad_lite/storage/language_repo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

abstract class FileServiceInterface {
  Future<List<File>> getHistoryFiles();
  Future<File?> saveMonacoCodeToFile({required String raw, String? fileName});
  Future<bool> deleteFile({required File file});
  Future<void> revealInFinder({required File file});
}

class FileService implements FileServiceInterface {
  final LanguageRepoInterface _languageRepo;

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

      EventService.instance.onEvent.add(
        Event.success(title: 'Saved ${file.path}'),
      );
      return file;
    } catch (e) {
      EventService.instance.onEvent.add(Event.error(title: e.toString()));
      return null;
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
    } catch (e) {
      EventService.instance.onEvent.add(Event.error(title: e.toString()));
      return [];
    }
  }

  @override
  Future<bool> deleteFile({required File file}) async {
    try {
      if (await file.exists()) {
        await file.delete();
        EventService.instance.onEvent.add(
          Event.success(title: 'Successfully deleted'),
        );
        return true;
      }
      return false;
    } catch (e) {
      EventService.instance.onEvent.add(Event.error(title: e.toString()));
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
