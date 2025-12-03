import 'package:dartpad_lite/UI/settings/options/compiler/compiler_sound_option_vm.dart';
import 'package:dartpad_lite/UI/settings/options/setting_option.dart';
import 'package:dartpad_lite/core/storage/compiler_repo.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CompilerSoundOption extends StatefulWidget {
  final CompilerRepoInterface repo;

  const CompilerSoundOption({super.key, required this.repo});

  @override
  State<CompilerSoundOption> createState() => _CompilerSoundOptionState();
}

class _CompilerSoundOptionState extends State<CompilerSoundOption> {
  late final CompilerSoundOptionVMInterface _vm = CompilerSoundOptionVM(
    widget.repo,
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _vm.isEnabled,
      builder: (_, isEnabled, __) {
        return SettingOption(
          title: 'Compiler Sound',
          height: 100,
          child: Row(
            children: [
              const Text(
                'Enable sound notifications',
                style: TextStyle(fontSize: 15, color: Colors.white70),
              ),
              const Spacer(),
              Switch(
                value: isEnabled,
                onChanged: (value) {
                  _vm.toggleSound(value);
                },
                activeThumbColor: AppColor.aiBlue,
              ),
            ],
          ),
        );
      },
    );
  }
}
