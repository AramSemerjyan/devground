import 'package:flutter/material.dart';

import 'options/ai_type_selector_option.dart';
import 'options/model_path_option.dart';
import '../setting_section.dart';
import 'ai_setting_vm.dart';
import 'options/api_key_option.dart';

class AISettingSection extends StatefulWidget {
  const AISettingSection({super.key});

  @override
  State<AISettingSection> createState() => _AISettingSectionState();
}

class _AISettingSectionState extends State<AISettingSection> {
  late final _vm = AISettingVM();

  @override
  void initState() {
    super.initState();

    _vm.fetchAISettings();
  }

  @override
  Widget build(BuildContext context) {
    return SettingSection(
      title: 'AI',
      children: [
        ValueListenableBuilder(
          valueListenable: _vm.onSettingsUpdate,
          builder: (_, value, __) {
            return Column(
              children: [
                AITypeSelectorOption(
                  settings: value,
                  onTypeSelect: _vm.setAIType,
                ),
                if (value.type == AIType.remote) ...[
                  ApiKeyOption(
                    controller: _vm.apiKeyController,
                    onSave: _vm.setApiKey,
                  ),
                ] else ...[
                  ModelPathOption(settings: value, onSave: _vm.setModelPath),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
