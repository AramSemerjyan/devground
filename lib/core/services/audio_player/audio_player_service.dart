import 'package:audioplayers/audioplayers.dart';
import 'package:dartpad_lite/core/services/audio_player/audio_files.dart';

abstract class AudioPlayerServiceInterface {
  Future<void> playAudio(Audio audio, {double? volume});

  void dispose();
}

class AudioPlayerService implements AudioPlayerServiceInterface {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Future<void> playAudio(Audio audio, {double? volume}) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(audio.assetPath), volume: volume ?? 0.5);
    } catch (e) {
      // Silently ignore errors (e.g., if audio file is missing)
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
  }
}
