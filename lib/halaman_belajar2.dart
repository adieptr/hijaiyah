import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
<<<<<<< HEAD
import 'halaman_latihan.dart'; // Import halaman latihan
=======
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5

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
<<<<<<< HEAD
=======
    // Menyesuaikan folder asset suara Anda
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
    return 'assets/hijaiyah_sound/$name.mp3';
  }

  Future<void> _playSound() async {
    try {
      await _audioPlayer.stop();
<<<<<<< HEAD
=======
      // AudioPlayers membutuhkan path tanpa prefix 'assets/' jika menggunakan AssetSource
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
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
<<<<<<< HEAD
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),

=======
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.15)),
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),
          
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Container GIF
                  Container(
                    width: screenWidth * 0.85,
<<<<<<< HEAD
                    height: screenHeight * 0.40, // Sedikit diperkecil dari 0.45
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
=======
                    height: screenHeight * 0.45,
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.45,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      color: Colors.white.withOpacity(0.9),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 8,
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
<<<<<<< HEAD
                        // Tombol Speaker
=======
                        // Tombol Speaker di pojok kanan bawah GIF
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
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
<<<<<<< HEAD
                                border: Border.all(
                                    color: const Color(0xFF6EDC68), width: 2),
=======
                                border: Border.all(color: const Color(0xFF6EDC68), width: 2),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                              ),
                              child: const Icon(
                                Icons.volume_up_rounded,
                                color: Color(0xFF4A8C40),
<<<<<<< HEAD
                                size: 30, // Diperkecil dari 35
=======
                                size: 35,
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                              ),
                            ),
                          ),
                        ),
                      ],
<<<<<<< HEAD
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Deskripsi Huruf
                  Text(
                    widget.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.05, // Diperkecil dari 0.06
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // Tombol Latihan (BARU)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HalamanLatihan()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC7EFA3),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.15,
                        vertical: 12, // Diperkecil ukurannya
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: const BorderSide(
                            color: Color(0xFF6EDC68), width: 2.5),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Latihan',
                      style: TextStyle(
                        fontSize: 20, // Diperkecil dari 0.07
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4A8C40),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

=======
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
                  
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                  // Tombol Kembali/Menu
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC7EFA3),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.15,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: const BorderSide(
                            color: Color(0xFF6EDC68), width: 1.5),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      'Kembali',
                      style: TextStyle(
                        fontSize: 18,
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