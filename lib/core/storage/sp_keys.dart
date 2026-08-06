enum SPKeys {
  selectedSdkKey('selected_sdk'),
  sdkPathKey('sdk_path'),
  compilerSound('compiler_sound'),

  workTimer('work_timer'),
  breakTimer('break_timer');

  final String value;

  const SPKeys(this.value);
}

enum SPAIKeys {
  modelPath('model_path'),
  type('ai_type'),
  apiKey('ai_api_key'),
  localContextLimit('local_context_limit');

  final String value;

  const SPAIKeys(this.value);
}
