enum Audio {
  workEnd('audio/work_end.mp3'),
  workStart('audio/work_start.mp3'),
  compileSucceed('audio/compile_succeed.mp3'),
  compileError('audio/compile_error.mp3');

  final String assetPath;

  const Audio(this.assetPath);
}