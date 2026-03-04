import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playBackgroundMusic() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);

    await _audioPlayer.play(AssetSource('audio/betulsih.mp3'));
  }

  Future<void> pauseBackgroundMusic() async {
    await _audioPlayer.pause();
  }

  Future<void> resumeBackgroundMusic() async {
    await _audioPlayer.resume();
  }

  Future<void> stopBackgroundMusic() async {
    await _audioPlayer.stop();
  }
}
