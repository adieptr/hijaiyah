import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _showLetterPicker = false;
  String? _nextRecommendedLetter;

  final Map<String, String> _hijaiyahDisplayMap = {
    'alif': 'Alif',
    'ba': "Ba'",
    'ta': "Ta'",
    'tsa': "Tsa'",
    'jim': 'Jim',
    'kha': "Ha'",
    'kho': "Kho'",
    'dal': 'Dal',
    'dzal': 'Dzal',
    'ro': "Ro'",
    'za': 'Zaa',
    'sin': 'Sin',
    'syin': 'Syin',
    'shod': 'Shod',
    'dhod': 'Dhod',
    'tho': "Tho'",
    'dzo': "Zho'",
    'ain': "'Ain",
    'ghain': 'Ghain',
    'fa': "Ba'",
    'qof': 'Qof',
    'kaf': 'Kaf',
    'lam': 'Lam',
    'mim': 'Mim',
    'nun': 'Nun',
    'wawu': 'Wawu',
    'ha': "Ha'",
    'ya': 'Ya',
  };

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
    String key = widget.hijaiyahName.toLowerCase();
    return 'assets/hijaiyah_sound/$key.mp3';
  }

  Future<void> playSound() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(
      AssetSource(getAudioPath().replaceFirst('assets/', '')),
    );
  }

  bool get isLowAccuracy => (widget.confidence ?? 0) < 0.7;

  String get accuracyText {
    if (widget.confidence == null) return "0%";
    return "${(widget.confidence! * 100).toStringAsFixed(0)}%";
  }

  String getResponseText() {
    if (isLowAccuracy) {
      return "Tulisanmu masih kurang bagus, apakah kamu berniat menulis huruf ini?";
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

  Widget _buildLetterSelectionGrid() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            "PILIH HURUF YANG KAMU MAKSUD:",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
          ),
        ),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _nameToLetterMap.entries.map((entry) {
              String name = _hijaiyahDisplayMap[entry.key] ?? entry.key;
              bool isUnderlineHa = (entry.key == 'kha');

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HalamanTracing(
                        hijaiyahLetter: entry.value,
                        hijaiyahName: entry.key,
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF6EDC68), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        decoration: isUnderlineHa
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        color: Colors.grey.shade700,
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    String displayName =
        _hijaiyahDisplayMap[widget.hijaiyahName.toLowerCase()] ??
            widget.hijaiyahName;
    bool isSpecialHa = (widget.hijaiyahName.toLowerCase() == 'kha');

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
                        const SizedBox(height: 10),
                        Text(
                          getResponseText(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isLowAccuracy
                                ? Colors.red.shade700
                                : const Color(0xFF4A8C40),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isLowAccuracy
                                ? Colors.red.shade100
                                : const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Akurasi: $accuracyText",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isLowAccuracy
                                  ? Colors.red.shade900
                                  : const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (isLowAccuracy && _showLetterPicker)
                          _buildLetterSelectionGrid(),
                        if (!_showLetterPicker) ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: isLowAccuracy
                                    ? Colors.red.shade50
                                    : const Color(0xFFF1F8E9),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                    color: isLowAccuracy
                                        ? Colors.red.shade200
                                        : const Color(0xFFC7EFA3),
                                    width: 3)),
                            child: isLowAccuracy
                                ? Image.asset(
                                    'assets/images/hijaiyah/${widget.hijaiyahName.toLowerCase()}.png',
                                    height: 120,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error,
                                            stackTrace) =>
                                        const Icon(Icons.image_not_supported,
                                            size: 60),
                                  )
                                : (widget.userDrawing != null
                                    ? Image.memory(
                                        widget.userDrawing!,
                                        height: 120,
                                        fit: BoxFit.contain,
                                      )
                                    : const Icon(Icons.edit,
                                        size: 60, color: Colors.grey)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            displayName,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              decoration: isSpecialHa
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                              color: isLowAccuracy
                                  ? Colors.red.shade700
                                  : const Color(0xFF4A8C40),
                            ),
                          ),
                          if (isLowAccuracy)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 24, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildDecisionButton(
                                    label: "YA",
                                    color:
                                        const Color.fromARGB(255, 37, 174, 30),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HalamanTracing(
                                            hijaiyahLetter:
                                                widget.hijaiyahLetter,
                                            hijaiyahName: widget.hijaiyahName,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 15),
                                  _buildDecisionButton(
                                    label: "TIDAK",
                                    color:
                                        const Color.fromARGB(255, 206, 77, 77),
                                    onTap: () {
                                      setState(() {
                                        _showLetterPicker = true;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
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
                  if (_isMastered && _nextRecommendedLetter != null)
                    _buildCustomButton(
                      text:
                          "LANJUT HURUF ${(_hijaiyahDisplayMap[_nextRecommendedLetter!] ?? _nextRecommendedLetter!).toUpperCase()}",
                      icon: Icons.skip_next,
                      onPressed: () {
                        String nextName = _nextRecommendedLetter!;
                        String nextLetter = _nameToLetterMap[nextName] ?? '';
                        String nextDisplay =
                            _hijaiyahDisplayMap[nextName] ?? nextName;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HalamanBelajar2(
                              hijaiyahLetter: nextLetter,
                              description: "Belajar Huruf $nextDisplay",
                            ),
                          ),
                        );
                      },
                      isUnderlined: _nextRecommendedLetter == 'kha',
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

  Widget _buildDecisionButton(
      {required String label,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isUnderlined = false,
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
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF4A8C40),
                    decoration: isUnderlined
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationThickness: 2,
                  ),
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
