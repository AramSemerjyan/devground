import 'package:file_picker/file_picker.dart';

abstract class PathSelectorVMInterface {
  Future<String?> getPath();
}

class PathSelectorVM implements PathSelectorVMInterface {
  @override
  Future<String?> getPath() {
    return FilePicker.platform.getDirectoryPath();
  }
}
