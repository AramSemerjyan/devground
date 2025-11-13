import 'package:flutter/material.dart';

enum AppPages {
  editor('Editor'),
  settings('Settings'),
  history('History');

  final String value;

  const AppPages(this.value);

  IconData get icon {
    switch (this) {
      case AppPages.editor:
        return Icons.copy_sharp;
      case AppPages.history:
        return Icons.history_edu;
      case AppPages.settings:
        return Icons.settings;
    }
  }
}
