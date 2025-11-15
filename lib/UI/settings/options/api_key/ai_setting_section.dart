import 'package:dartpad_lite/UI/settings/options/api_key/ai_setting_vm.dart';
import 'package:dartpad_lite/UI/settings/options/setting_option.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../setting_section.dart';

class AISettingSection extends StatefulWidget {
  const AISettingSection({super.key});

  @override
  State<AISettingSection> createState() => _AISettingSectionState();
}

class _AISettingSectionState extends State<AISettingSection> {
  late final _vm = AISettingVM();

  bool _showApiKey = false;

  @override
  void initState() {
    super.initState();

    _vm.getApiKey();
  }

  Widget _buildAPIOption() {
    return SettingOption(
      title: 'Gemini API key',
      height: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextField(
            controller: _vm.apiKeyController,
            obscureText: !_showApiKey,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF2A2D2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFF454545)),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _showApiKey ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white54,
                    ),
                    onPressed: () => setState(() => _showApiKey = !_showApiKey),
                  ),
                  IconButton(
                    icon: const Icon(Icons.paste, color: Colors.white54),
                    onPressed: () async {
                      final paste = await Clipboard.getData(
                        Clipboard.kTextPlain,
                      );
                      if (paste?.text != null) {
                        _vm.apiKeyController.text = paste!.text!;
                      }
                    },
                  ),
                  if (_vm.apiKeyController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      onPressed: () => _vm.apiKeyController.clear(),
                    ),
                ],
              ),
            ),
            onChanged: (v) {
              _vm.saveButtonEnabled.value = v.isNotEmpty;
            },
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder(
            valueListenable: _vm.saveButtonEnabled,
            builder: (_, enabled, __) {
              return Opacity(
                opacity: enabled ? 1 : 0.5,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (!enabled) return;
                    _vm.setApiKey(_vm.apiKeyController.text);
                  },
                  label: const Text("Save"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingSection(title: 'AI', children: [_buildAPIOption()]);
  }
}
