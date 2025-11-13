import 'dart:io';

import 'package:intl/intl.dart';

extension FileExtension on File {
  String get name => uri.pathSegments.last;

  String get updatedDate {
    final modified = lastModifiedSync();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(modified);
  }
}
