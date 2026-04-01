import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../db/db_helper.dart';
import '../utils/session.dart';
import 'halaman_tracing.dart';
import 'halaman_belajar2.dart';

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
    'alif': 'ba',
    'ba': 'ta',
    'ta': 'tsa',
    'tsa': 'jim',
    'jim': 'kha',
    'kha': 'kho',
    'kho': 'dal',
    'dal': 'dzal',
    'dzal': 'ro',
    'ro': 'za',
    'za': 'sin',
    'sin': 'syin',
    'syin': 'shod',
    'shod': 'dhod',
    'dhod': 'tho',
    'tho': 'dzo',
    'dzo': 'ain',
    'ain': 'ghain',
    'ghain': 'fa',
    'fa': 'qof',
    'qof': 'kaf',
    'kaf': 'lam',
    'lam': 'mim',
    'mim': 'nun',
    'nun': 'wawu',
    'wawu': 'ha',
    'ha': 'ya',
  };

  final Map<String, String> _nameToLetterMap = {
    'alif': 'ا',
    'ba': 'ب',
    'ta': 'ت',
    'tsa': 'ث',
    'jim': 'ج',
    'kha': 'ح',
    'kho': 'خ',
    'dal': 'د',
    'dzal': 'ذ',
    'ro': 'ر',
    'za': 'ز',
    'sin': 'س',
    'syin': 'ش',
    'shod': 'ص',
    'dhod': 'ض',
    'tho': 'ط',
    'dzo': 'ظ',
    'ain': 'ع',
    'ghain': 'غ',
    'fa': 'ف',
    'qof': 'ق',
    'kaf': 'ك',
    'lam': 'ل',
    'mim': 'م',
    'nun': 'ن',
    'wawu': 'و',
    'ha': 'ه',
    'ya': 'ي',
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

    await DBHelper.instance.saveProgress(
      userId,
      widget.hijaiyahName.toLowerCase(),
      accuracyPercent,
    );

    final history = await DBHelper.instance
        .getRecentProgress(userId, widget.hijaiyahName.toLowerCase(), limit: 3);

    if (history.length >= 3) {
      bool allHigh = history.every((item) => (item['accuracy'] as num) >= 90);
      if (allHigh) {
        setState(() {
          _isMastered = true;
          _nextRecommendedLetter =
              _visualSimilarityMap[widget.hijaiyahName.toLowerCase()];
        });
      }
    }
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

  bool get isLowAccuracy => (widget.confidence ?? 0) < 0.7;

  String getResponseText() {
    if (isLowAccuracy) {
      return "Tulisannya hampir mirip, tapi perlu sedikit perbaikan.\nCoba bandingkan dengan contoh di bawah ini.";
    } else if (_isMastered) {
      return "Luar Biasa! Kamu sudah bisa menulis huruf ini.\nSiap lanjut ke tantangan berikutnya?";
    } else {
      return "MasyaAllah! Tulisanmu sudah bagus.\nAyo terus berlatih!";
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildComparisonView() {
    return Column(
      children: [
        const Text(
          "PERBANDINGAN",
          style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.grey,
              fontSize: 12,
              letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildComparisonCard(
              title: "TULISANMU",
              child: widget.userDrawing != null
                  ? Image.memory(
                      widget.userDrawing!,
                      fit: BoxFit.contain,
                    )
                  : const Icon(Icons.edit, size: 40, color: Colors.grey),
              color: Colors.blue.shade50,
            ),
            const Icon(Icons.compare_arrows,
                color: Color(0xFF6EDC68), size: 30),
            _buildComparisonCard(
              title: "REFERENSI",
              child: Image.asset(
                'assets/images/hijaiyah/${widget.hijaiyahName.toLowerCase()}.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
              color: const Color(0xFFC7EFA3).withOpacity(0.3),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonCard(
      {required String title, required Widget child, required Color color}) {
    double boxSize = MediaQuery.of(context).size.width * 0.31;
    return Column(
      children: [
        Container(
          width: boxSize,
          height: boxSize,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: child,
        ),
        const SizedBox(height: 6),
        Text(title,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.black54)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset(
            'assets/images/bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          )),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                children: [
                  Container(
                    width: screenWidth * 0.90,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8))
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isMastered) const BadgeMastered(),
                        Text(widget.hijaiyahLetter,
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.1,
                                fontWeight: FontWeight.bold,
                                height: 1.2)),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(color: Colors.black12, thickness: 1.5),
                        ),
                        Text(
                          getResponseText(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isLowAccuracy
                                ? Colors.red.shade700
                                : const Color(0xFF4A8C40),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (isLowAccuracy)
                          _buildComparisonView()
                        else
                          // PERBAIKAN: Menampilkan tulisan user di sini jika akurasi tinggi
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD), // Warna latar biru muda yang lembut
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color(0xFF2196F3), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "HASIL TULISANMU",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF1976D2),
                                      fontSize: 10,
                                      letterSpacing: 1.5),
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: widget.userDrawing != null
                                      ? Image.memory(
                                          widget.userDrawing!,
                                          width: 160,
                                          height: 160,
                                          fit: BoxFit.contain,
                                        )
                                      : const Icon(Icons.stars_rounded,
                                          size: 60, color: Colors.amber),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!isLowAccuracy)
                    _buildCustomButton(
                      text: "DENGARKAN SUARA",
                      onPressed: playSound,
                      icon: Icons.volume_up,
                    ),
                  if (isLowAccuracy)
                    _buildCustomButton(
                      text: "COBA MODE TRACING",
                      icon: Icons.auto_fix_high,
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
                  if (_isMastered && _nextRecommendedLetter != null)
                    _buildCustomButton(
                      text:
                          "LANJUT HURUF ${_nextRecommendedLetter!.toUpperCase()}",
                      icon: Icons.skip_next,
                      onPressed: () {
                        String nextName = _nextRecommendedLetter!;
                        String nextLetter = _nameToLetterMap[nextName] ?? '';

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HalamanBelajar2(
                              hijaiyahLetter: nextLetter,
                              description:
                                  "Belajar Huruf ${nextName[0].toUpperCase()}${nextName.substring(1)}",
                            ),
                          ),
                        );
                      },
                    ),
                  _buildCustomButton(
                    text: "LATIHAN LAGI",
                    icon: Icons.refresh,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                    child: const Text("Kembali ke Menu Utama",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        )),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFC7EFA3),
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(color: const Color(0xFF6EDC68), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: const Color(0xFF4A8C40), size: 20),
                const SizedBox(width: 10),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4A8C40),
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            "TERKUASAI!",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}