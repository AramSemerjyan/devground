import 'dart:async';

import 'package:dartpad_lite/core/pages_service/app_page.dart';
import 'package:dartpad_lite/core/pages_service/pages_service.dart';
import 'package:flutter/cupertino.dart';

import '../../core/services/event_service/event_service.dart';

abstract class EditorPageVMInterface {
  ValueNotifier<(List<AppPage>, int)> get onPagesUpdate;

  Future<void> onSelect(int pageIndex);
  Future<void> onClose(int pageIndex);
  Future<void> onCloseOthers(int pageIndex);
  Future<void> onCloseAll();
}

class EditorPageVM implements EditorPageVMInterface {
  final PagesServiceInterface pagesService;

  @override
  ValueNotifier<(List<AppPage>, int)> get onPagesUpdate =>
      pagesService.onPagesUpdate;

  EditorPageVM(this.pagesService);

  @override
  Future<void> onSelect(int pageIndex) async {
    if (pageIndex == onPagesUpdate.value.$2) return;

    onPagesUpdate.value = (onPagesUpdate.value.$1, pageIndex);

    final page = onPagesUpdate.value.$1[onPagesUpdate.value.$2];

    EventService.emit(
      type: EventType.languageChanged,
      data: page.file.language,
    );

    EventService.emit(
      type: EventType.aiModeChanged,
      data: page.isAIBoosted ?? false,
    );
  }

  @override
  Future<void> onClose(int pageIndex) async {
    pagesService.onClose(pageIndex);
  }

  @override
  Future<void> onCloseOthers(int pageIndex) async {
    pagesService.onCloseOthers(pageIndex);
  }

  @override
  Future<void> onCloseAll() async {
    pagesService.onCloseAll();
  }
}
