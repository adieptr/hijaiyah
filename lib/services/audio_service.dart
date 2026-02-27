import 'package:audioplayers/audioplayers.dart';

class AudioService {
  // Singleton pattern agar instance yang sama digunakan di seluruh app
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playBackgroundMusic() async {
    // Mengatur agar audio berputar terus menerus (looping)
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    // Memutar file audio dari folder assets
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
