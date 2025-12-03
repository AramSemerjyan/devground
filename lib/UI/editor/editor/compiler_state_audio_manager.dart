import 'package:dartpad_lite/core/storage/compiler_repo.dart';

import '../../../core/services/audio_player/audio_player_service.dart';
import '../../../core/services/compiler/compiler_result.dart';

abstract class CompilerStateAudioManagerInterface {
  void play(CompilerResultStatus status);
  void dispose();
}

class CompilerStateAudioManager implements CompilerStateAudioManagerInterface {
  final AudioPlayerServiceInterface _audioPlayer = AudioPlayerService();
  final CompilerRepoInterface _compilerRepo;

  CompilerStateAudioManager(this._compilerRepo);

    @override
  void play(CompilerResultStatus status) async {

      final shouldPlaySound = await _compilerRepo.getEnableSound();

      if (!shouldPlaySound) return;

      switch (status) {
        case .done:
          _audioPlayer.playAudio(.compileSucceed, volume: 0.3);
          break;
        case .error:
          _audioPlayer.playAudio(.compileError, volume: 0.3);
          break;
        default:
          break;
      }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
  }
}