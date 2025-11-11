import 'package:dartpad_lite/services/compiler/compiler_interface.dart';
import 'package:dartpad_lite/services/event_service.dart';
import 'package:dartpad_lite/services/save_file/save_file_service.dart';
import 'package:dartpad_lite/storage/language_repo.dart';
import 'package:dartpad_lite/storage/supported_language.dart';

enum SDKState { inProgress, ready, notReady }

class AppPageVM {
  late final Compiler compiler = Compiler();
  late final LanguageRepo languageRepo = LanguageRepo();
  late final FileServiceInterface fileService = FileService(languageRepo);

  void setUp() async {
    EventService.instance.onEvent.add(
      Event(type: EventType.idle, title: 'Initializing...'),
    );

    await languageRepo.setUp();

    final language = await languageRepo.getSelectedLanguage();

    if (language != null) {
      _setLanguage(language);
    }

    EventService.instance.onEvent.stream
        .where((event) => event.type == EventType.languageChanged)
        .listen((event) {
          final data = event.data as SupportedLanguage?;

          if (data != null) _setLanguage(data);
        });
  }

  void _setLanguage(SupportedLanguage language) {
    switch (language.supported) {
      case LanguageSupport.upcoming:
        compiler.resetCompiler();
        EventService.instance.onEvent.add(
          Event(type: EventType.warning, title: 'Upcoming support'),
        );
        break;
      case LanguageSupport.supported:
        try {
          compiler.setCompilerForLanguage(language: language);
          EventService.instance.onEvent.add(Event.success(title: 'Ready'));
        } catch (e) {
          EventService.instance.onEvent.add(
            Event(type: EventType.error, title: e.toString()),
          );
        }
        break;
      default:
        compiler.resetCompiler();
        EventService.instance.onEvent.add(
          Event(type: EventType.error, title: 'Not supported'),
        );
    }
  }
}
