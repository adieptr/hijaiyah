import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class HalamanBelajar2 extends StatefulWidget {
  final String hijaiyahLetter;
  final String description;

  const HalamanBelajar2({
    super.key,
    required this.hijaiyahLetter,
    required this.description,
  });

  @override
  State<HalamanBelajar2> createState() => _HalamanBelajar2State();
}

class _HalamanBelajar2State extends State<HalamanBelajar2> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Mapping dari karakter Arab ke nama file (digunakan untuk GIF dan Audio)
  final Map<String, String> _hijaiyahFileNameMap = {
    'ا': 'alif',
    'ب': 'ba',
    'ت': 'ta',
    'ث': 'tsa',
    'ج': 'jim',
    'ح': 'kha',
    'خ': 'kho',
    'د': 'dal',
    'ذ': 'dzal',
    'ر': 'ro',
    'ز': 'za',
    'س': 'sin',
    'ش': 'syin',
    'ص': 'shod',
    'ض': 'dhod',
    'ط': 'tho',
    'ظ': 'dzo',
    'ع': 'ain',
    'غ': 'ghain',
    'ف': 'fa',
    'ق': 'qof',
    'ك': 'kaf',
    'ل': 'lam',
    'م': 'mim',
    'ن': 'nun',
    'و': 'wawu',
    'ه': 'ha',
    'ي': 'ya',
  };

  String getGifPath() {
    String name = _hijaiyahFileNameMap[widget.hijaiyahLetter] ?? 'alif';
    return 'assets/images/hijaiyah_gif/$name.gif';
  }

  String getAudioPath() {
    String name = _hijaiyahFileNameMap[widget.hijaiyahLetter] ?? 'alif';
    // Menyesuaikan folder asset suara Anda
    return 'assets/hijaiyah_sound/$name.mp3';
  }

  Future<void> _playSound() async {
    try {
      await _audioPlayer.stop();
      // AudioPlayers membutuhkan path tanpa prefix 'assets/' jika menggunakan AssetSource
      String path = getAudioPath().replaceFirst('assets/', '');
      await _audioPlayer.play(AssetSource(path));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.15)),
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),
          
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Container GIF
                  Container(
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.45,
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.45,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Center(
                            child: Image.asset(
                              getGifPath(),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        // Tombol Speaker di pojok kanan bawah GIF
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: _playSound,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC7EFA3),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF6EDC68), width: 2),
                              ),
                              child: const Icon(
                                Icons.volume_up_rounded,
                                color: Color(0xFF4A8C40),
                                size: 35,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.03),
                  
                  // Deskripsi Huruf
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: screenHeight * 0.05),
                  
                  // Tombol Kembali/Menu
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
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