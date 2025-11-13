import 'package:dartpad_lite/UI/settings/settings_page_vm.dart';
import 'package:dartpad_lite/storage/supported_language.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../storage/language_repo.dart';
import '../command_palette/command_palette.dart';

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
                  return InkWell(
                    onTap: () {
                      CommandPalette.showOption<SupportedLanguage>(
                        context: context,
                        items: data.values.toList(),
                        itemBuilder: (context, item) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        onSelected: (item) {
                          _vm.selectedLanguage.value = item;
                        },
                        hintText: 'Select a language…',
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          value?.name ?? '',
                          style: TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                      ],
                    ),
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
      backgroundColor: AppColor.mainGreyDark,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(children: [_buildSDKPathRow()]),
        ),
      ),
    );
  }
}
