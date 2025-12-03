import 'package:audioplayers/audioplayers.dart';
import 'package:dartpad_lite/core/services/audio_player/audio_files.dart';

abstract class AudioPlayerServiceInterface {
  Future<void> playAudio(Audio audio);

  void dispose();
}

class AudioPlayerService implements AudioPlayerServiceInterface {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Future<void> playAudio(Audio audio) async {
    await _audioPlayer.play(AssetSource(audio.assetPath), volume: 0.5);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
  }
}
