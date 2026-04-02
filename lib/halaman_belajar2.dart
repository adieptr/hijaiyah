import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'halaman_latihan.dart';
import 'profil.dart';
import '../db/db_helper.dart';
import '../utils/session.dart';

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
  String? fullname;

  // Nama file tetap dipertahankan agar tidak merusak sistem aset dan TFLite
  final Map<String, String> _hijaiyahFileNameMap = {
    'ا': 'alif', 'ب': 'ba', 'ت': 'ta', 'ث': 'tsa', 'ج': 'jim',
    'ح': 'kha', 'خ': 'kho', 'د': 'dal', 'ذ': 'dzal', 'ر': 'ro',
    'ز': 'za', 'س': 'sin', 'ش': 'syin', 'ص': 'shod', 'ض': 'dhod',
    'ط': 'tho', 'ظ': 'dzo', 'ع': 'ain', 'غ': 'ghain', 'ف': 'fa',
    'ق': 'qof', 'ك': 'kaf', 'ل': 'lam', 'م': 'mim', 'ن': 'nun',
    'و': 'wawu', 'ه': 'ha', 'ي': 'ya',
  };

  // Nama tampilan baru sesuai permintaan user
  final Map<String, String> _hijaiyahDisplayNameMap = {
    'ا': 'Alif', 'ب': "Ba'", 'ت': "Ta'", 'ث': "Tsa'", 'ج': 'Jim',
    'ح': "Ha'", 'خ': "Kho'", 'د': 'Dal', 'ذ': 'Dzal', 'ر': "Ro'",
    'ز': 'Zaa', 'س': 'Sin', 'ش': 'Syin', 'ص': 'Shod', 'ض': 'Dhod',
    'ط': "Tho'", 'ظ': "Zho'", 'ع': "'Ain", 'غ': 'Ghain', 'ف': "Fa'",
    'ق': 'Qof', 'ك': 'Kaf', 'ل': 'Lam', 'م': 'Mim', 'ن': 'Nun',
    'و': 'Wawu', 'ه': "Ha'", 'ي': 'Ya',
  };

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final userId = await Session.getUser();
    if (userId != null) {
      final user = await DBHelper.instance.getUserById(userId);
      if (mounted) {
        setState(() {
          fullname = user?['fullname'];
        });
      }
    }
  }

  String getGifPath() {
    String name = _hijaiyahFileNameMap[widget.hijaiyahLetter] ?? 'alif';
    return 'assets/images/hijaiyah_gif/$name.gif';
  }

  String getAudioPath() {
    String name = _hijaiyahFileNameMap[widget.hijaiyahLetter] ?? 'alif';
    return 'assets/hijaiyah_sound/$name.mp3';
  }

  Future<void> _playSound() async {
    try {
      await _audioPlayer.stop();
      String path = getAudioPath().replaceFirst('assets/', '');
      await _audioPlayer.play(AssetSource(path));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF6EDC68), width: 2),
          ),
          backgroundColor: const Color(0xFFC7EFA3),
          title: Text(
            'Bantuan Belajar',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4A8C40),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem(
                'Animasi Penulisan:',
                'Gambar di tengah menunjukkan urutan cara menulis huruf hijaiyah yang benar.',
              ),
              const SizedBox(height: 12),
              _buildHelpItem(
                'Suara Huruf:',
                'Tekan ikon speaker di pojok gambar untuk mendengarkan pelafalan huruf tersebut.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Mengerti',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A8C40),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: const Color(0xFF4A8C40),
          ),
        ),
        Text(
          description,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
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

    // Ambil nama tampilan baru berdasarkan huruf hijaiyah
    String displayName = _hijaiyahDisplayNameMap[widget.hijaiyahLetter] ?? widget.description;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),

          // Konten Utama
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60), 
                  Container(
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
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
                                border: Border.all(
                                    color: const Color(0xFF6EDC68), width: 2),
                              ),
                              child: const Icon(
                                Icons.volume_up_rounded,
                                color: Color(0xFF4A8C40),
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Tampilan Deskripsi Nama Huruf
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.08, // Diperbesar sedikit agar lebih jelas
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      // Memberikan underline khusus untuk huruf Ha' (ح) sesuai permintaan
                      decoration: widget.hijaiyahLetter == 'ح' 
                          ? TextDecoration.underline 
                          : TextDecoration.none,
                      decorationColor: Colors.white,
                      decorationThickness: 2,
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
                        vertical: 12,
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
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4A8C40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
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
                      style: GoogleFonts.poppins(
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

          // TOMBOL BANTUAN
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: _showHelpDialog,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6EDC68),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFFC7EFA3),
                      child: Text(
                        '?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A8C40),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bantuan',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      shadows: const [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TOMBOL PROFIL
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilPage()),
                );
                loadUser(); 
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6EDC68),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFC7EFA3),
                      child: Text(
                        fullname != null ? fullname![0].toUpperCase() : '?',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4A8C40),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (fullname != null)
                    Text(
                      fullname!.split(' ').first,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        shadows: const [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(1, 1),
                          ),
                        ],
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