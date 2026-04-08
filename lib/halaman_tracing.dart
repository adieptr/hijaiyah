import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'halaman_latihan.dart';
import 'profil.dart';
import '../db/db_helper.dart';
import '../utils/session.dart';
import 'dart:typed_data';
import 'dart:math' as math;

// Model diperbarui: Menambahkan isCalligraphy untuk menentukan gaya lukisan per stroke
class Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
  final bool isEraser;
  final bool isCalligraphy;

  Stroke({
    required this.points,
    required this.color,
    required this.width,
    required this.isEraser,
    this.isCalligraphy = true,
  });
}

class _DrawingPainter extends CustomPainter {
  final List<Stroke> strokes;
  _DrawingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (var stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      if (stroke.isEraser) {
        final paint = Paint()
          ..color = stroke.color
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke.width;

        if (stroke.points.length == 1) {
          // LOGIKA TITIK UNTUK PENGHAPUS
          canvas.drawCircle(stroke.points.first, stroke.width / 2, paint..style = PaintingStyle.fill);
        } else {
          final path = Path();
          path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
          for (int i = 1; i < stroke.points.length; i++) {
            path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
          }
          canvas.drawPath(path, paint);
        }
      } else {
        // Mode Pensil: Cek apakah gaya kaligrafi atau normal
        if (!stroke.isCalligraphy) {
          // GAYA PENA NORMAL
          final normalPaint = Paint()
            ..color = stroke.color
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke.width
            ..isAntiAlias = true;

          if (stroke.points.length == 1) {
            // LOGIKA TITIK: Jika hanya satu titik, gambar lingkaran (dot)
            canvas.drawCircle(stroke.points.first, stroke.width / 2, normalPaint..style = PaintingStyle.fill);
          } else {
            final path = Path();
            path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
            for (var i = 1; i < stroke.points.length; i++) {
              path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
            }
            canvas.drawPath(path, normalPaint);
          }
        } else {
          // GAYA PENA KALIGRAFI (Ribbon Effect)
          final paint = Paint()
            ..color = stroke.color
            ..style = PaintingStyle.fill
            ..isAntiAlias = true;

          const double angle = -math.pi / 4;
          final double nibWidth = stroke.width;

          final Offset nibOffset = Offset(
            math.cos(angle) * (nibWidth / 2),
            math.sin(angle) * (nibWidth / 2),
          );

          for (int i = 0; i < stroke.points.length - 1; i++) {
            final p1 = stroke.points[i];
            final p2 = stroke.points[i + 1];

            final path = Path()
              ..moveTo(p1.dx - nibOffset.dx, p1.dy - nibOffset.dy)
              ..lineTo(p1.dx + nibOffset.dx, p1.dy + nibOffset.dy)
              ..lineTo(p2.dx + nibOffset.dx, p2.dy + nibOffset.dy)
              ..lineTo(p2.dx - nibOffset.dx, p2.dy - nibOffset.dy)
              ..close();

            canvas.drawPath(path, paint);
          }

          if (stroke.points.length == 1) {
            final p = stroke.points.first;
            final path = Path()
              ..moveTo(p.dx - nibOffset.dx, p.dy - nibOffset.dy)
              ..lineTo(p.dx + nibOffset.dx, p.dy + nibOffset.dy)
              ..lineTo(p.dx + 0.1 + nibOffset.dx, p.dy + 0.1 + nibOffset.dy)
              ..lineTo(p.dx + 0.1 - nibOffset.dx, p.dy + 0.1 - nibOffset.dy)
              ..close();
            canvas.drawPath(path, paint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HalamanTracing extends StatefulWidget {
  final String hijaiyahLetter;
  final String hijaiyahName;

  const HalamanTracing({
    super.key,
    required this.hijaiyahLetter,
    required this.hijaiyahName,
  });

  @override
  State<HalamanTracing> createState() => _HalamanTracingState();
}

class _HalamanTracingState extends State<HalamanTracing> {
  List<Stroke> _strokes = [];
  List<Stroke> _redoStack = [];
  Color _currentColor = const Color(0xFF2E7D32);
  double _strokeWidth = 25.0; // Default awal kaligrafi
  bool _isDrawing = false;
  bool _isEraser = false;
  bool _isCalligraphyStyle = true; // Toggle untuk gaya brush
  bool _isCalculating = false;
  String? fullname;

  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _templateKey = GlobalKey();

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

  void _onPanStart(DragStartDetails details) {
    HapticFeedback.lightImpact();
    _redoStack.clear();
    RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    Offset localPos = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      _isDrawing = true;
      _strokes.add(Stroke(
        points: [localPos],
        color: _isEraser ? Colors.white : _currentColor,
        width: _strokeWidth,
        isEraser: _isEraser,
        isCalligraphy: _isCalligraphyStyle,
      ));
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || _strokes.isEmpty) return;

    Offset localPos = renderBox.globalToLocal(details.globalPosition);
    if (localPos.dx >= 0 &&
        localPos.dy >= 0 &&
        localPos.dx <= renderBox.size.width &&
        localPos.dy <= renderBox.size.height) {
      setState(() {
        _strokes.last.points.add(localPos);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) => setState(() => _isDrawing = false);

  void _undo() => setState(() {
        if (_strokes.isNotEmpty) _redoStack.add(_strokes.removeLast());
      });

  void _redo() => setState(() {
        if (_redoStack.isNotEmpty) _strokes.add(_redoStack.removeLast());
      });

  void _clearCanvas() => setState(() {
        _strokes.clear();
        _redoStack.clear();
      });

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
              'Bantuan Tracing',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A8C40),
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: Colors.black45,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHelpItem(
                              'Tujuan Utama',
                              'Tebalkan huruf hijaiyah yang muncul samar di layar sesuai dengan urutan dan bentuknya.',
                            ),
                            const SizedBox(height: 12),
                            _buildHelpItem(
                              'Cara Menebalkan',
                              '• Gunakan jari untuk mengikuti pola huruf.\n'
                                  '• Usahakan coretan tetap berada di dalam area huruf.\n'
                                  '• Ketuk sekali untuk membuat titik (pada mode Pena Normal).',
                            ),
                            const SizedBox(height: 12),
                            _buildHelpItem(
                              'Gaya Pena',
                              '• Mode Normal: ukuran default 15.\n'
                                  '• Mode Kaligrafi: ukuran default 25 (pena miring).\n'
                                  '• Tekan tombol "Gaya Pena" untuk berganti bentuk.',
                            ),
                            const SizedBox(height: 12),
                            _buildHelpItem(
                              'Mode Tulis & Hapus',
                              'Gunakan satu tombol toggle untuk berganti antara menulis (biru) dan menghapus (oranye).',
                            ),
                            const SizedBox(height: 12),
                            _buildHelpItem(
                              'Penilaian',
                              'Skor dihitung otomatis berdasarkan seberapa akurat coretan Anda menutupi pola huruf yang disediakan.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_up,
                      size: 20,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
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
        });
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


  Future<void> _calculateScore() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tulis hurufnya dulu ya!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isCalculating = true);

    try {
      const double scanRatio = 0.5;

      final RenderRepaintBoundary userBoundary = _canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image userImg =
          await userBoundary.toImage(pixelRatio: scanRatio);
      final ByteData? userBytes =
          await userImg.toByteData(format: ui.ImageByteFormat.rawRgba);

      final RenderRepaintBoundary tempBoundary = _templateKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image tempImg =
          await tempBoundary.toImage(pixelRatio: scanRatio);
      final ByteData? tempBytes =
          await tempImg.toByteData(format: ui.ImageByteFormat.rawRgba);

      if (userBytes == null || tempBytes == null) {
        setState(() => _isCalculating = false);
        return;
      }

      final Uint8List userPixels = userBytes.buffer.asUint8List();
      final Uint8List tempPixels = tempBytes.buffer.asUint8List();

      final int tempWidth = tempImg.width;
      final int tempHeight = tempImg.height;
      final int userWidth = userImg.width;
      final int userHeight = userImg.height;

      int totalTemplatePixels = 0;
      int coveredByUser = 0;

      for (int y = 0; y < tempHeight; y++) {
        for (int x = 0; x < tempWidth; x++) {
          final int tByteIdx = (y * tempWidth + x) * 4;
          if (tByteIdx + 3 >= tempPixels.length) continue;
          if (tempPixels[tByteIdx + 3] < 30) continue;

          totalTemplatePixels++;

          final int uByteIdx = (y * userWidth + x) * 4;
          if (uByteIdx + 3 < userPixels.length &&
              userPixels[uByteIdx + 3] > 30) {
            coveredByUser++;
          }
        }
      }

      int totalUserPixels = 0;
      int userOnLetter = 0;

      for (int y = 0; y < userHeight; y++) {
        for (int x = 0; x < userWidth; x++) {
          final int uByteIdx = (y * userWidth + x) * 4;
          if (uByteIdx + 3 >= userPixels.length) continue;
          if (userPixels[uByteIdx + 3] < 30) continue;

          totalUserPixels++;

          final int tByteIdx = (y * tempWidth + x) * 4;
          if (tByteIdx + 3 < tempPixels.length &&
              tempPixels[tByteIdx + 3] > 30) {
            userOnLetter++;
          }
        }
      }

      final double recall =
          totalTemplatePixels == 0 ? 0.0 : coveredByUser / totalTemplatePixels;
      final double precision =
          totalUserPixels == 0 ? 0.0 : userOnLetter / totalUserPixels;

      const double beta = 1.2;
      const double betaSq = beta * beta;
      double fScore = 0.0;
      if (precision + recall > 0) {
        fScore = (1 + betaSq) *
            (precision * recall) /
            ((betaSq * precision) + recall);
      }

      double finalScore = fScore * 140.0;
      if (finalScore > 100) finalScore = 100;
      if (recall < 0.05 || fScore < 0.05) finalScore = 0;

      setState(() => _isCalculating = false);
      _showScoreDialog(finalScore);
    } catch (e) {
      setState(() => _isCalculating = false);
      debugPrint('Scoring Error: $e');
    }
  }

  void _showScoreDialog(double score) {
    final bool isGreat = score > 95;
    final bool isOkay = score > 55;
    final String message = isGreat
        ? "Kamu hebat!"
        : (isOkay ? "Bagus, lanjutkan!" : "Ayo Coba Lagi!");
    final Color themeColor = isGreat
        ? const Color(0xFF4A8C40)
        : (isOkay ? Colors.blue.shade800 : Colors.orange.shade800);
    final Color barColor = isGreat
        ? const Color(0xFF4CAF50)
        : (isOkay ? Colors.blue.shade600 : Colors.orange.shade600);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF6EDC68), width: 3),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(message,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: themeColor)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 22,
              decoration: BoxDecoration(
                color: barColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: barColor.withOpacity(0.3), width: 1),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: score / 100,
                    child: Container(
                        decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(11))),
                  ),
                  Center(
                    child: Text('${score.toStringAsFixed(1)}%',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: score > 50 ? Colors.white : barColor)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildLargeButton(
                text: "Coba Lagi",
                onTap: () {
                  Navigator.pop(context);
                  _clearCanvas();
                },
                widthMultiplier: 0.65),
            const SizedBox(height: 10),
            _buildLargeButton(
                text: "Selesai",
                onTap: () {
                  Navigator.pop(context); // Tutup dialog
                  // Pindah ke Halaman Latihan dan hapus tumpukan navigasi sebelumnya 
                  // agar kembali ke menu pilihan huruf/latihan
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HalamanLatihan()),
                  );
                },
                widthMultiplier: 0.65),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    String hijaiyahImagePath =
        'assets/images/hijaiyah_tracing/${widget.hijaiyahName.toLowerCase()}.png';

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => Container(color: Colors.green[100]),
            ),
          ),
          Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.15))),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: _isDrawing
                      ? const NeverScrollableScrollPhysics()
                      : const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 90),
                          // Toolbar
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildRoundButton(
                                    icon: Icons.undo, onTap: _undo, tooltip: "Undo"),
                                const SizedBox(width: 8),
                                _buildRoundButton(
                                    icon: Icons.redo, onTap: _redo, tooltip: "Redo"),
                                const SizedBox(width: 24),
                                _buildRoundButton(
                                    icon: Icons.delete, onTap: _clearCanvas, tooltip: "Bersihkan"),
                                const SizedBox(width: 8),
                                
                                // TOMBOL TOGGLE PENSIL / PENGHAPUS
                                _buildRoundButton(
                                  icon: _isEraser ? Icons.cleaning_services : Icons.edit,
                                  onTap: () => setState(() => _isEraser = !_isEraser),
                                  isActive: true,
                                  activeColor: _isEraser ? Colors.orangeAccent : Colors.blueAccent,
                                  tooltip: _isEraser ? "Mode Hapus" : "Mode Tulis",
                                ),
                                const SizedBox(width: 8),

                                // TOMBOL SWITCH GAYA PENA (NORMAL / KALIGRAFI)
                                _buildRoundButton(
                                  icon: _isCalligraphyStyle ? Icons.history_edu : Icons.brush,
                                  onTap: () {
                                    setState(() {
                                      _isCalligraphyStyle = !_isCalligraphyStyle;
                                      _isEraser = false; // Kembali ke pensil saat ganti gaya
                                      _strokeWidth = _isCalligraphyStyle ? 25.0 : 19.0;
                                    });
                                  },
                                  isActive: true,
                                  activeColor: Colors.purpleAccent,
                                  tooltip: "Gaya Pena",
                                ),
                              ],
                            ),
                          ),
                          // Slider
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Row(
                              children: [
                                const Icon(Icons.line_weight,
                                    size: 16, color: Colors.white),
                                Expanded(
                                  child: Slider(
                                    value: _strokeWidth,
                                    min: 10.0,
                                    max: 60.0,
                                    activeColor: Colors.white,
                                    inactiveColor: Colors.white24,
                                    onChanged: (val) =>
                                        setState(() => _strokeWidth = val),
                                  ),
                                ),
                                Text("${_strokeWidth.toInt()}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Canvas
                          Center(
                            child: Container(
                              width: screenWidth * 0.90,
                              height: screenHeight * 0.50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5))
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Stack(
                                  children: [
                                    SizedBox.expand(
                                      child: RepaintBoundary(
                                        key: _templateKey,
                                        child: Opacity(
                                          opacity: 0.25,
                                          child: Image.asset(
                                            hijaiyahImagePath,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) =>
                                                Center(
                                                    child: Text(
                                                        widget.hijaiyahLetter,
                                                        style: const TextStyle(
                                                            fontSize: 150,
                                                            color:
                                                                Colors.grey))),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox.expand(
                                      child: RepaintBoundary(
                                        key: _canvasKey,
                                        child: GestureDetector(
                                          onPanStart: _onPanStart,
                                          onPanUpdate: _onPanUpdate,
                                          onPanEnd: _onPanEnd,
                                          child: CustomPaint(
                                              painter: _DrawingPainter(_strokes),
                                              size: Size.infinite),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _isCalculating
                              ? const CircularProgressIndicator(
                                  color: Color(0xFF4A8C40))
                              : _buildLargeButton(
                                  text: 'CEK TULISAN', onTap: _calculateScore),
                          const SizedBox(height: 12),
                          _buildLargeButton(
                              text: 'Kembali',
                              onTap: () => Navigator.pop(context)),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // TOMBOL BANTUAN (Pojok Kiri Atas)
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
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFFC7EFA3),
                      child: Text('?',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A8C40))),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Bantuan',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ],
              ),
            ),
          ),

          // TOMBOL PROFIL (Pojok Kanan Atas)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfilPage()));
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
                            offset: const Offset(0, 2))
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
                            color: const Color(0xFF4A8C40)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (fullname != null)
                    Text(fullname!.split(' ').first,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton(
      {required IconData icon,
      required VoidCallback onTap,
      bool isActive = false,
      Color activeColor = Colors.black,
      String? tooltip}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child:
            Icon(icon, color: isActive ? Colors.white : Colors.black, size: 20),
      ),
    );
  }

  Widget _buildLargeButton(
      {required String text,
      required VoidCallback onTap,
      double widthMultiplier = 0.55}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * widthMultiplier,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFC7EFA3),
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(color: const Color(0xFF6EDC68), width: 2.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 4))
          ],
        ),
        child: Center(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4A8C40)))),
      ),
    );
  }
}