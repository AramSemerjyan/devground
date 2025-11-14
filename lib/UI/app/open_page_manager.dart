import 'package:flutter/foundation.dart';

import '../../core/services/event_service.dart';
import '../../core/services/import_file/imported_file.dart';

abstract class OpenPageManagerInterface {
  ValueNotifier<(List<ImportedFile>, int)> get onPagesUpdate;
}

class OpenPageManager implements OpenPageManagerInterface {
  @override
  ValueNotifier<(List<ImportedFile>, int)> onPagesUpdate = ValueNotifier((
    [],
    -1,
  ));

  OpenPageManager() {
    EventService.instance.stream
        .where((event) => event.type == EventType.importedFile)
        .listen((event) {
          final updatedPages = [
            ...onPagesUpdate.value.$1,
            event.data as ImportedFile,
          ];
          final selectedPage = updatedPages.length - 1;

          onPagesUpdate.value = (updatedPages, selectedPage);
        });
  }
}
