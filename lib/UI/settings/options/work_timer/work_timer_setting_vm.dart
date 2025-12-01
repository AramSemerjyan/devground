import 'package:flutter/material.dart';

abstract class WorkTimerSettingVMInterface {
  ValueNotifier<void> get onSettingsUpdate;
}

class WorkTimerSettingVM implements WorkTimerSettingVMInterface {
  @override
  ValueNotifier<void> onSettingsUpdate = ValueNotifier(null);
}