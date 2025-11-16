import 'package:file_picker/file_picker.dart';

abstract class PathSelectorVMInterface {
  Future<String?> getFile();
  Future<String?> getPath();
}

class PathSelectorVM implements PathSelectorVMInterface {
  @override
  Future<String?> getFile() async {
    final result = await FilePicker.platform.pickFiles();

    return result?.files.first.path;
  }

  @override
  Future<String?> getPath() {
    return FilePicker.platform.getDirectoryPath();
  }
}
