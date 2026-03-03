import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../db/db_helper.dart';
import '../utils/session.dart';

class HalamanHasilKlasifikasi extends StatefulWidget {
<<<<<<< HEAD
  final String hijaiyahLetter;
  final String hijaiyahName;
  final double? confidence;
=======
class HalamanHasilKlasifikasi extends StatefulWidget {
  final String hijaiyahLetter;
  final String hijaiyahName;
  final double? confidence;
  final double? confidence;
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5

  const HalamanHasilKlasifikasi({
    super.key,
    required this.hijaiyahLetter,
    required this.hijaiyahName,
    this.confidence,
<<<<<<< HEAD
=======
    this.confidence,
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
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
<<<<<<< HEAD
      return "Huruf yang kamu tulis masih belum mirip.\n"
          "Maksud kamu huruf di bawah ini?";
    } else {
      return "MasyaAllah! Tulisanmu sudah bagus.\n"
=======
      return "Huruf yang kamu tulis masih belum mirip dengan aslinya.\n"
          "Apakah kamu bermaksud menulis huruf seperti dibawah ini?";
    } else {
      return "MasyaAllah! Huruf yang kamu tulis sudah mirip dengan aslinya.\n"
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
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

<<<<<<< HEAD
  // Helper Button - Ukuran Diperkecil
=======
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
  Widget _buildMenuButton({
    required String text,
    IconData? icon,
    required VoidCallback onPressed,
    required double width,
  }) {
    return Container(
<<<<<<< HEAD
      width: width * 0.45, // Diperkecil dari 0.5
      height: 45, // Diperkecil dari 50
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
=======
      width: width * 0.5,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
<<<<<<< HEAD
            offset: const Offset(0, 3),
=======
            offset: const Offset(0, 4),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC5E99B),
          foregroundColor: const Color(0xFF4A7C44),
          shape: RoundedRectangleBorder(
<<<<<<< HEAD
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Color(0xFFB4D98B), width: 1.5),
=======
            borderRadius: BorderRadius.circular(40),
            side: const BorderSide(color: Color(0xFFB4D98B), width: 2),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
<<<<<<< HEAD
              Icon(icon,
                  size: 18, color: const Color(0xFF4A7C44)), // Icon diperkecil
              const SizedBox(width: 8),
=======
              Icon(icon, size: 22, color: const Color(0xFF4A7C44)),
              const SizedBox(width: 10),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
            ],
            Text(
              text,
              style: const TextStyle(
<<<<<<< HEAD
                fontSize: 16, // Diperkecil dari 24
                fontWeight: FontWeight.bold,
=======
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Fredoka',
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    String hijaiyahImagePath =
        'assets/images/hijaiyah/${widget.hijaiyahName.toLowerCase()}.png';

    String hijaiyahImagePath =
        'assets/images/hijaiyah/${widget.hijaiyahName.toLowerCase()}.png';

    String hijaiyahImagePath =
        'assets/images/hijaiyah/${widget.hijaiyahName.toLowerCase()}.png';

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),

          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),

          Center(
            child: SingleChildScrollView(
<<<<<<< HEAD
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Box Hasil Utama - Ukuran Diperkecil
                  if (!isLowAccuracy)
                    Container(
                      width: screenWidth * 0.7, // Diperkecil dari 0.8
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            spreadRadius: 1,
                            blurRadius: 8,
=======
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isLowAccuracy)
                    Container(
                      width: screenWidth * 0.8,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            spreadRadius: 2,
                            blurRadius: 10,
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Ini Huruf :',
                            style: TextStyle(
<<<<<<< HEAD
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Image.asset(
                            hijaiyahImagePath,
                            width: screenWidth * 0.25, // Diperkecil dari 0.35
                            height: screenWidth * 0.25,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.hijaiyahLetter,
                            style: const TextStyle(
                                fontSize: 45,
                                fontWeight:
                                    FontWeight.bold), // Diperkecil dari 65
=======
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          Image.asset(
                            hijaiyahImagePath,
                            width: screenWidth * 0.35,
                            height: screenWidth * 0.35,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.hijaiyahLetter,
                            style: const TextStyle(
                                fontSize: 65, fontWeight: FontWeight.bold),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                          ),
                          Text(
                            widget.hijaiyahName,
                            style: const TextStyle(
<<<<<<< HEAD
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold), // Diperkecil dari 30
                          ),
                          if (widget.confidence != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(
                                'Akurasi: ${(widget.confidence! * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                    fontSize: 12,
=======
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          if (widget.confidence != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Akurasi: ${(widget.confidence! * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                    fontSize: 16,
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                    ),
<<<<<<< HEAD

                  // Box Feedback (Low Accuracy / Success Message)
                  if (widget.confidence != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: screenWidth * 0.75,
                      padding: const EdgeInsets.all(12),
=======
                  if (widget.confidence != null) ...[
                    const SizedBox(height: 25),
                    Container(
                      width: screenWidth * 0.75,
                      padding: const EdgeInsets.all(15),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                      decoration: BoxDecoration(
                        color: isLowAccuracy
                            ? const Color(0xFFFFF3CD)
                            : const Color(0xFFD4EDDA),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isLowAccuracy ? Colors.orange : Colors.green,
<<<<<<< HEAD
                          width: 1.5,
=======
                          width: 2,
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            getResponseText(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
<<<<<<< HEAD
                              fontSize: 13, // Diperkecil dari 16
=======
                              fontSize: 16,
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                              fontWeight: FontWeight.bold,
                              color: isLowAccuracy
                                  ? Colors.brown[700]
                                  : Colors.green[900],
                            ),
                          ),
<<<<<<< HEAD
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              getGifPath(),
                              width: screenWidth * 0.28, // Diperkecil dari 0.35
                              height: screenWidth * 0.28,
=======
                          const SizedBox(height: 15),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              getGifPath(),
                              width: screenWidth * 0.35,
                              height: screenWidth * 0.35,
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
<<<<<<< HEAD

                  const SizedBox(height: 30),

                  // Tombol Navigasi
=======
                  const SizedBox(height: 40),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                  if (!isLowAccuracy) ...[
                    _buildMenuButton(
                      text: "Dengarkan",
                      icon: Icons.volume_up_rounded,
                      onPressed: playSound,
                      width: screenWidth,
                    ),
<<<<<<< HEAD
                    const SizedBox(height: 12),
=======
                    const SizedBox(height: 20),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                  ],
                  _buildMenuButton(
                    text: "Kembali",
                    onPressed: () => Navigator.pop(context),
                    width: screenWidth,
                  ),
                ],
              ),
<<<<<<< HEAD
=======
                ],
              ),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
            ),
          ),
        ],
      ),
    );
  }
}