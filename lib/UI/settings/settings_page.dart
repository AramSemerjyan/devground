import 'package:dartpad_lite/UI/settings/options/compiler/compiler_section.dart';
import 'package:dartpad_lite/UI/settings/options/compiler/language_setting_option.dart';
import 'package:dartpad_lite/UI/settings/options/setting_section.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';

import '../../core/storage/compiler_repo.dart';
import 'options/ai_section/ai_setting_section.dart';
import 'options/work_timer/work_timer_serting_section.dart';

class SettingsPage extends StatefulWidget {
  final CompilerRepoInterface languageRepo;

  const SettingsPage({super.key, required this.languageRepo});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mainGreyDark,
      appBar: AppBar(
        backgroundColor: AppColor.mainGrey,
        leading: SizedBox(),
        title: const Text(
          "Settings",
          style: TextStyle(color: AppColor.mainGreyLighter),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 40,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CompilerSection(languageRepo: widget.languageRepo),
            AISettingSection(),
            WorkTimerSettingsSection(),
          ],
        ),
      ),
    );
  }
}
