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

  static AppPages fromString(String name) {
    switch (name) {
      case 'Editor':
        return AppPages.editor;
      case 'History':
        return AppPages.history;
      case 'Settings':
        return AppPages.settings;
      default:
        return AppPages.editor;
    }
  }
}
