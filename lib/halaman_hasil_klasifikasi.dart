import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../db/db_helper.dart';
import '../utils/session.dart';

class HalamanHasilKlasifikasi extends StatefulWidget {
  final String hijaiyahLetter;
  final String hijaiyahName;
  final double? confidence;

  const HalamanHasilKlasifikasi({
    super.key,
    required this.hijaiyahLetter,
    required this.hijaiyahName,
    this.confidence,
  });

  @override
  State<HalamanHasilKlasifikasi> createState() =>
      _HalamanHasilKlasifikasiState();
}

class _HalamanHasilKlasifikasiState extends State<HalamanHasilKlasifikasi> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Simpan progress setelah halaman tampil
    WidgetsBinding.instance.addPostFrameCallback((_) {
      saveProgressToDB();
    });
  }

  Future<void> saveProgressToDB() async {
    if (widget.confidence == null) return;

    final int? userId = await Session.getUser();
    if (userId == null) return;

    final double accuracyPercent = widget.confidence! * 100;

    await DBHelper.instance.saveProgress(
      userId,
      widget.hijaiyahName.toLowerCase(),
      accuracyPercent,
    );
  }

  String getAudioPath() {
    final Map<String, String> audioMap = {
      'alif': 'alif.mp3',
      'ba': 'ba.mp3',
      'ta': 'ta.mp3',
      'tsa': 'tsa.mp3',
      'jim': 'jim.mp3',
      'kha': 'ha.mp3',
      'kho': 'kho.mp3',
      'dal': 'dal.mp3',
      'dzal': 'dzal.mp3',
      'ro': 'ro.mp3',
      'za': 'za.mp3',
      'sin': 'sin.mp3',
      'syin': 'syin.mp3',
      'shod': 'shod.mp3',
      'dhod': 'dhod.mp3',
      'tho': 'tho.mp3',
      'dzo': 'dzo.mp3',
      'ain': 'ain.mp3',
      'ghain': 'ghain.mp3',
      'fa': 'fa.mp3',
      'qof': 'qof.mp3',
      'kaf': 'kaf.mp3',
      'lam': 'lam.mp3',
      'mim': 'mim.mp3',
      'nun': 'nun.mp3',
      'wawu': 'wawu.mp3',
      'ha': 'ha.mp3',
      'ya': 'ya.mp3',
    };

    String key = widget.hijaiyahName.toLowerCase();
    return 'assets/hijaiyah_sound/${audioMap[key] ?? 'alif.mp3'}';
  }

  Future<void> playSound() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(
      AssetSource(getAudioPath().replaceFirst('assets/', '')),
    );
  }

  bool get isLowAccuracy {
    if (widget.confidence == null) return false;
    return widget.confidence! < 0.7;
  }

  String getResponseText() {
    if (widget.confidence == null) return "";
    if (isLowAccuracy) {
      return "Huruf yang kamu tulis masih belum mirip dengan aslinya.\n"
          "Apakah kamu bermaksud menulis huruf seperti dibawah ini?";
    } else {
      return "MasyaAllah! Huruf yang kamu tulis sudah mirip dengan aslinya.\n"
          "Terus pertahankan ya!";
    }
  }

  String getGifPath() {
    return 'assets/images/hijaiyah_gif/${widget.hijaiyahName.toLowerCase()}.gif';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    String hijaiyahImagePath =
        'assets/images/hijaiyah/${widget.hijaiyahName.toLowerCase()}.png';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // CARD HASIL KLASIFIKASI (Hanya tampil jika akurasi cukup/tinggi)
                  if (!isLowAccuracy)
                    Container(
                      width: screenWidth * 0.8,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Ini Huruf :',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          Image.asset(
                            hijaiyahImagePath,
                            width: screenWidth * 0.4,
                            height: screenWidth * 0.4,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.hijaiyahLetter,
                            style: const TextStyle(
                                fontSize: 60, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.hijaiyahName,
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          if (widget.confidence != null)
                            Text(
                              'Confidence: ${(widget.confidence! * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ),

                  // CARD RESPON (Selalu tampil jika ada confidence)
                  if (widget.confidence != null) ...[
                    if (!isLowAccuracy) const SizedBox(height: 20),
                    Container(
                      width: screenWidth * 0.8,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isLowAccuracy
                            ? const Color(0xFFFFF3CD)
                            : const Color(0xFFD4EDDA),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isLowAccuracy ? Colors.orange : Colors.green,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            getResponseText(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isLowAccuracy
                                  ? Colors.brown
                                  : Colors.green[800],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Image.asset(
                            getGifPath(),
                            width: screenWidth * 0.4,
                            height: screenWidth * 0.4,
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: screenHeight * 0.05),
                  ElevatedButton(
                    onPressed: playSound,
                    child: const Text('Dengarkan'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}