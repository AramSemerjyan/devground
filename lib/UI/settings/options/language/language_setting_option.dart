import 'package:dartpad_lite/UI/settings/options/language/language_setting_option_vm.dart';
import 'package:dartpad_lite/UI/settings/options/setting_option.dart';
import 'package:dartpad_lite/core/storage/language_repo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/storage/supported_language.dart';
import '../../../command_palette/command_palette.dart';

class LanguageSettingOption extends StatefulWidget {
  final LanguageRepoInterface languageRepo;
  const LanguageSettingOption({super.key, required this.languageRepo});

  @override
  State<LanguageSettingOption> createState() => _LanguageSettingOptionState();
}

class _LanguageSettingOptionState extends State<LanguageSettingOption> {
  late final _vm = LanguageSettingOptionVM(widget.languageRepo);

  final TextEditingController _pathController = TextEditingController();

  void _selectDirectory(SupportedLanguage? language) async {
    if (language == null) return;

    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      await _vm.setSDKPath(language: language, sdkPath: selectedDirectory);
      _pathController.text = selectedDirectory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingOption(
      title: 'Language',
      height: 200,
      child: FutureBuilder(
        future: _vm.getSupportedLanguages(),
        builder: (c, f) {
          final data = f.data;
          if (data == null) return const SizedBox();

          return ValueListenableBuilder(
            valueListenable: _vm.selectedLanguage,
            builder: (_, selected, __) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Language Picker
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {
                      CommandPalette.showOption<SupportedLanguage>(
                        context: context,
                        items: data.values.toList(),
                        itemBuilder: (context, item) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item.name,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        onSelected: (item) {
                          _vm.selectedLanguage.value = item;
                        },
                        hintText: 'Choose language…',
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          selected?.name ?? 'Select language…',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.expand_more, color: Colors.white54),
                      ],
                    ),
                  ),

                  // Browse button
                  if (selected?.needSDKPath ?? false) ...[
                    const SizedBox(height: 16),

                    // Path hint
                    Text(
                      selected?.sdkPath ?? selected?.path.hint ?? '',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _selectDirectory(_vm.selectedLanguage.value),
                      icon: const Icon(Icons.folder_open),
                      label: const Text("Select SDK Folder"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E639C),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}
