import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../db/db_helper.dart';
import '../utils/session.dart';
import 'halaman_tracing.dart'; // Pastikan path import ini sesuai dengan struktur project Anda

class HalamanHasilKlasifikasi extends StatefulWidget {
  final String hijaiyahLetter;
  final String hijaiyahName;
  final double? confidence;
  final Uint8List? userDrawing;

  const HalamanHasilKlasifikasi({
    super.key,
    required this.hijaiyahLetter,
    required this.hijaiyahName,
    this.confidence,
    this.userDrawing,
  });

  @override
  State<HalamanHasilKlasifikasi> createState() =>
      _HalamanHasilKlasifikasiState();
}

class _HalamanHasilKlasifikasiState extends State<HalamanHasilKlasifikasi> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMastered = false;
  String? _nextRecommendedLetter;

  final Map<String, String> _visualSimilarityMap = {
    'alif': 'ba', 'ba': 'ta', 'ta': 'tsa', 'tsa': 'jim',
    'jim': 'kha', 'kha': 'kho', 'kho': 'dal', 'dal': 'dzal',
    'dzal': 'ro', 'ro': 'za', 'za': 'sin', 'sin': 'syin',
    'syin': 'shod', 'shod': 'dhod', 'dhod': 'tho', 'tho': 'dzo',
    'dzo': 'ain', 'ain': 'ghain', 'ghain': 'fa', 'fa': 'qof',
    'qof': 'kaf', 'kaf': 'lam', 'lam': 'mim', 'mim': 'nun',
    'nun': 'wawu', 'wawu': 'ha', 'ha': 'ya',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processProgress();
    });
  }

  Future<void> _processProgress() async {
    if (widget.confidence == null) return;

    final int? userId = await Session.getUser();
    if (userId == null) return;

    final double accuracyPercent = widget.confidence! * 100;

    // 1. Simpan ke DB
    await DBHelper.instance.saveProgress(
      userId,
      widget.hijaiyahName.toLowerCase(),
      accuracyPercent,
    );

    // 2. Cek Mastery (3x berturut-turut > 90%)
    final history = await DBHelper.instance.getRecentProgress(
      userId, 
      widget.hijaiyahName.toLowerCase(), 
      limit: 3
    );

    if (history.length >= 3) {
      bool allHigh = history.every((item) => (item['accuracy'] as num) >= 90);
      if (allHigh) {
        setState(() {
          _isMastered = true;
          _nextRecommendedLetter = _visualSimilarityMap[widget.hijaiyahName.toLowerCase()];
        });
      }
    }
  }

  // Fungsi Audio Helper
  String getAudioPath() {
    final Map<String, String> audioMap = {
      'alif': 'alif.mp3', 'ba': 'ba.mp3', 'ta': 'ta.mp3', 'tsa': 'tsa.mp3',
      'jim': 'jim.mp3', 'kha': 'ha.mp3', 'kho': 'kho.mp3', 'dal': 'dal.mp3',
      'dzal': 'dzal.mp3', 'ro': 'ro.mp3', 'za': 'za.mp3', 'sin': 'sin.mp3',
      'syin': 'syin.mp3', 'shod': 'shod.mp3', 'dhod': 'dhod.mp3', 'tho': 'tho.mp3',
      'dzo': 'dzo.mp3', 'ain': 'ain.mp3', 'ghain': 'ghain.mp3', 'fa': 'fa.mp3',
      'qof': 'qof.mp3', 'kaf': 'kaf.mp3', 'lam': 'lam.mp3', 'mim': 'mim.mp3',
      'nun': 'nun.mp3', 'wawu': 'wawu.mp3', 'ha': 'ha.mp3', 'ya': 'ya.mp3',
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

  bool get isLowAccuracy => (widget.confidence ?? 0) < 0.7;

  String getResponseText() {
    if (isLowAccuracy) {
      return "Tulisannya hampir mirip, tapi perlu sedikit perbaikan.\nCoba bandingkan dengan contoh di bawah ini.";
    } else if (_isMastered) {
      return "Luar Biasa! Kamu sudah menguasai huruf ini.\nSiap lanjut ke tantangan berikutnya?";
    } else {
      return "MasyaAllah! Tulisanmu sudah bagus.\nSedikit lagi untuk jadi Master!";
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildComparisonView(double screenWidth) {
    return Column(
      children: [
        const Text("Perbandingan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildComparisonCard(
              title: "Tulisanmu",
              child: widget.userDrawing != null 
                ? Image.memory(widget.userDrawing!, fit: BoxFit.contain)
                : const Icon(Icons.edit, size: 40, color: Colors.grey),
              color: Colors.blue.shade50,
            ),
            const Icon(Icons.compare_arrows, color: Colors.grey),
            _buildComparisonCard(
              title: "Referensi",
              child: Image.asset(
                'assets/images/hijaiyah/${widget.hijaiyahName.toLowerCase()}.png',
                fit: BoxFit.contain,
              ),
              color: Colors.green.shade50,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonCard({required String title, required Widget child, required Color color}) {
    return Column(
      children: [
        Container(
          width: 100, height: 100, padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: child,
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/bg.png', fit: BoxFit.cover)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                children: [
                  Container(
                    width: screenWidth * 0.85,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        if (_isMastered) const BadgeMastered(),
                        Text(widget.hijaiyahLetter, style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold)),
                        Text(widget.hijaiyahName.toUpperCase(), style: const TextStyle(fontSize: 24, letterSpacing: 2)),
                        const Divider(height: 30),
                        Text(
                          getResponseText(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.w500,
                            color: isLowAccuracy ? Colors.red.shade700 : Colors.green.shade700
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (isLowAccuracy)
                          _buildComparisonView(screenWidth)
                        else
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/images/hijaiyah_gif/${widget.hijaiyahName.toLowerCase()}.gif',
                              width: 120,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Tombol Aksi: Suara
                  if (!isLowAccuracy)
                    _buildActionButton(
                      text: "Dengarkan Suara",
                      icon: Icons.volume_up,
                      color: Colors.blueAccent,
                      onPressed: playSound,
                    ),

                  // Tombol Aksi: Navigasi ke Tracing (Diperbaiki)
                  if (isLowAccuracy)
                    _buildActionButton(
                      text: "Coba Mode Tracing",
                      icon: Icons.auto_fix_high,
                      color: const Color(0xFFFFCC00),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HalamanTracing(
                              hijaiyahLetter: widget.hijaiyahLetter,
                              hijaiyahName: widget.hijaiyahName,
                            ),
                          ),
                        );
                      },
                    ),

                  // Tombol Aksi: Rekomendasi Huruf Berikutnya
                  if (_isMastered && _nextRecommendedLetter != null)
                    _buildActionButton(
                      text: "Lanjut Huruf ${_nextRecommendedLetter!.toUpperCase()}",
                      icon: Icons.next_plan,
                      color: const Color(0xFF4CAF50),
                      onPressed: () {
                        // Implementasi navigasi ke huruf berikutnya bisa diletakkan di sini
                        // Misalnya memicu ulang halaman klasifikasi dengan data huruf baru
                      },
                    ),

                  const SizedBox(height: 10),

                  // Tombol Kembali/Ulangi
                  _buildActionButton(
                    text: "Ulangi Lagi",
                    icon: Icons.refresh,
                    color: Colors.white,
                    textColor: Colors.black87,
                    onPressed: () => Navigator.pop(context),
                  ),

                  TextButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Text("Kembali ke Menu Utama", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text, 
    required IconData icon, 
    required VoidCallback onPressed,
    required Color color,
    Color textColor = Colors.white,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 5),
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
        ),
      ),
    );
  }
}

class BadgeMastered extends StatelessWidget {
  const BadgeMastered({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text("MASTERED", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}