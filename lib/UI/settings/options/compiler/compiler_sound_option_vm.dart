import 'package:dartpad_lite/core/storage/compiler_repo.dart';
import 'package:flutter/foundation.dart';

abstract class CompilerSoundOptionVMInterface {
  ValueNotifier<bool> get isEnabled;
  Future<void> toggleSound(bool enabled);
}

class CompilerSoundOptionVM implements CompilerSoundOptionVMInterface {
  final CompilerRepoInterface _repo;

  @override
  final ValueNotifier<bool> isEnabled = ValueNotifier(true);

  CompilerSoundOptionVM(this._repo) {
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    isEnabled.value = await _repo.getEnableSound();
  }

  @override
  Future<void> toggleSound(bool enabled) async {
    await _repo.setEnableSound(enabled: enabled);
    isEnabled.value = enabled;
  }
}
