import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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

  // Mapping nama huruf ke file audio
  String getAudioPath() {
    final Map<String, String> audioMap = {
      'alif': 'alif.mp3',
      'ba': 'ba.mp3',
      'ta': 'ta.mp3',
      'tsa': 'tsa.mp3',
      'jim': 'jim.mp3',
      'ha': 'ha.mp3',
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
      'ha2': 'ha2.mp3', // untuk ه jika dibedakan
      'ya': 'ya.mp3',
    };

    String key = widget.hijaiyahName.toLowerCase();
    return 'assets/hijaiyah_sound/${audioMap[key] ?? 'alif.mp3'}';
  }

  Future<void> playSound() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(
      AssetSource(
        getAudioPath().replaceFirst('assets/', ''),
      ),
    );
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
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Kartu hasil klasifikasi
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
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text(
                              'Gambar tidak ditemukan',
                              style: TextStyle(color: Colors.red),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        Text(
                          widget.hijaiyahLetter,
                          style: const TextStyle(
                              fontSize: 60, fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          widget.hijaiyahName,
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        ),

                        if (widget.confidence != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Confidence: ${(widget.confidence! * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.05),

                  // Tombol Dengarkan
                  ElevatedButton(
                    onPressed: playSound,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC7EFA3),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.15,
                        vertical: screenHeight * 0.025,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: const BorderSide(
                            color: Color(0xFF6EDC68), width: 3),
                      ),
                      shadowColor: Colors.black.withOpacity(0.5),
                      elevation: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.volume_up,
                            color: Color(0xFF4A8C40)),
                        const SizedBox(width: 10),
                        Text(
                          'Dengarkan',
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4A8C40),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC7EFA3),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.15,
                        vertical: screenHeight * 0.025,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: const BorderSide(
                            color: Color(0xFF6EDC68), width: 3),
                      ),
                    ),
                    child: Text(
                      'Kembali',
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4A8C40),
                      ),
                    ),
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
