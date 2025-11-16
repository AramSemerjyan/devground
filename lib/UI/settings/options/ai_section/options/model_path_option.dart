import 'package:dartpad_lite/UI/settings/options/ai_section/ai_setting_vm.dart';
import 'package:flutter/material.dart';

import '../../../widget/path_selector.dart';
import '../../setting_option.dart';

class ModelPathOption extends StatelessWidget {
  final AISettings settings;
  final Function(String)? onSave;

  const ModelPathOption({super.key, required this.settings, this.onSave});

  void _selectFileDir(String? path) {
    if (path != null) {
      onSave?.call(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingOption(
      title: 'Llama',
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PathSelector(
            type: PathSelectorType.file,
            path: settings.modelPath.isEmpty
                ? 'Only llama supported models'
                : settings.modelPath,
            label: "Select Model path",
            onPathSelect: _selectFileDir,
          ),
        ],
      ),
    );
  }
}
