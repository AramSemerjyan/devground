import 'package:dartpad_lite/UI/settings/settings_page_vm.dart';
import 'package:dartpad_lite/storage/supported_language.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../storage/language_repo.dart';

class SettingsPage extends StatefulWidget {
  final LanguageRepoInterface languageRepo;

  const SettingsPage({super.key, required this.languageRepo});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _pathController = TextEditingController();
  late final SettingsPageVMInterface _vm = SettingsPageVM(widget.languageRepo);

  void _selectDirectory(SupportedLanguage? language) async {
    if (language == null) return;

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      await _vm.setSDKPath(language: language, sdkPath: selectedDirectory);
      _pathController.text = selectedDirectory;
    }
  }

  Widget _buildSDKPathRow() {
    return SizedBox(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
            future: _vm.getSupportedLanguages(),
            builder: (c, f) {
              final data = f.data;

              if (data == null) return Container();

              return ValueListenableBuilder(
                valueListenable: _vm.selectedLanguage,
                builder: (_, value, __) {
                  return DropdownButton<SupportedLanguage>(
                    value: value,
                    hint: Text(value?.name ?? ''),
                    focusColor: Colors.transparent,
                    style: TextStyle(color: AppColor.mainGreyLighter),
                    items: data.values.map((lang) {
                      return DropdownMenuItem(
                        value: lang,
                        child: Row(
                          children: [
                            if (lang.icon.isNotEmpty)
                              Image.asset(lang.icon, width: 20, height: 20),
                            const SizedBox(width: 8),
                            Text(lang.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _vm.selectedLanguage.value = value;
                      }
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder(
            valueListenable: _vm.selectedLanguage,
            builder: (_, value, __) {
              return Text(
                value?.sdkPath ?? value?.path.hint ?? '',
                style: TextStyle(
                  color: AppColor.mainGreyLighter.withValues(alpha: 0.3),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder(
            valueListenable: _vm.selectedLanguage,
            builder: (_, value, __) {
              if (!(value?.needSDKPath ?? false)) {
                return Container();
              }

              return ElevatedButton(
                onPressed: () => _selectDirectory(_vm.selectedLanguage.value),
                child: const Text('Browse...'),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColor.mainGrey),
      backgroundColor: AppColor.mainGreyDarker,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(children: [_buildSDKPathRow()]),
        ),
      ),
    );
  }
}
