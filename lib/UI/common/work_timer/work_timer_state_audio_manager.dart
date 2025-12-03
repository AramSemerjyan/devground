import 'package:dartpad_lite/core/services/audio_player/audio_player_service.dart';
import 'package:flutter/material.dart';

import '../../../core/services/work_timer/work_timer_service.dart';

abstract class WorkTimerStateAudioManagerInterface {
  void start(ValueNotifier<WorkSessionStatus> onStateChange);
  void dispose();
}

class WorkTimerStateAudioManager
    implements WorkTimerStateAudioManagerInterface {
  final AudioPlayerServiceInterface _audioPlayer = AudioPlayerService();

  @override
  void start(ValueNotifier<WorkSessionStatus> onStateChange) {
    onStateChange.addListener(() {
      final state = onStateChange.value;

      switch (state) {
        case WorkSessionStatus.workCompleted:
          _audioPlayer.playAudio(.workEnd);
          break;
        case WorkSessionStatus.breakCompleted:
          _audioPlayer.playAudio(.workStart);
          break;
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
  }
}
