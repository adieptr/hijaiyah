import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'halaman_latihan.dart';
import 'dart:typed_data';
import 'dart:math' as math;

class Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
  final bool isEraser;

  Stroke({
    required this.points,
    required this.color,
    required this.width,
    required this.isEraser,
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

        final path = Path();
        path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, paint);
      } else {
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
  double _strokeWidth = 25.0;
  bool _isDrawing = false;
  bool _isEraser = false;
  bool _isCalculating = false;

  final GlobalKey _canvasKey = GlobalKey();

  // PERBAIKAN: Key template diletakkan di LUAR Opacity
  // agar toImage() menangkap pixel dengan alpha penuh (tidak direduksi 0.25)
  final GlobalKey _templateKey = GlobalKey();

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
  Future<void> _navigateTo(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
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

      // Ambil gambar canvas user (coretan)
      final RenderRepaintBoundary userBoundary = _canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image userImg =
          await userBoundary.toImage(pixelRatio: scanRatio);
      final ByteData? userBytes =
          await userImg.toByteData(format: ui.ImageByteFormat.rawRgba);

      // Ambil gambar template — RepaintBoundary ada di LUAR Opacity
      // sehingga pixel alpha mencerminkan nilai asli gambar PNG
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

      // rawRgba = urutan byte: R G B A per pixel
      // Dalam Uint8List: index 3, 7, 11, ... adalah alpha
      // Kita pakai Uint8List (bukan Uint32List) agar byte order tidak ambigu
      final Uint8List userPixels = userBytes.buffer.asUint8List();
      final Uint8List tempPixels = tempBytes.buffer.asUint8List();

      final int tempWidth = tempImg.width;
      final int tempHeight = tempImg.height;
      final int userWidth = userImg.width;
      final int userHeight = userImg.height;

      // Toleransi posisi untuk recall (seberapa dekat coretan ke huruf)
      const int recallTolerance = 0;
      // Toleransi untuk precision (seberapa jauh coretan boleh dari huruf)
      const int precisionTolerance = 0;

      // ── PASS 1: RECALL ───────────────────────────────────────────────────
      // Dari semua pixel huruf, berapa yang tertutup coretan user?
      int totalTemplatePixels = 0;
      int coveredByUser = 0;

      for (int y = 0; y < tempHeight; y++) {
        for (int x = 0; x < tempWidth; x++) {
          // Alpha ada di byte ke-4 setiap pixel (index: pixelIndex * 4 + 3)
          final int tByteIdx = (y * tempWidth + x) * 4;
          if (tByteIdx + 3 >= tempPixels.length) continue;

          final int alphaTemp = tempPixels[tByteIdx + 3];

          // Threshold rendah (>30) karena gambar PNG huruf mungkin punya
          // anti-alias di tepinya. Pixel inti huruf biasanya alpha > 200.
          if (alphaTemp < 30) continue;

          totalTemplatePixels++;

          bool hit = false;
          outerRecall:
          for (int dy = -recallTolerance; dy <= recallTolerance; dy++) {
            for (int dx = -recallTolerance; dx <= recallTolerance; dx++) {
              final int nx = x + dx;
              final int ny = y + dy;
              if (nx < 0 || nx >= userWidth || ny < 0 || ny >= userHeight) {
                continue;
              }
              final int uByteIdx = (ny * userWidth + nx) * 4;
              if (uByteIdx + 3 >= userPixels.length) continue;
              if (userPixels[uByteIdx + 3] > 30) {
                hit = true;
                break outerRecall;
              }
            }
          }
          if (hit) coveredByUser++;
        }
      }

      // ── PASS 2: PRECISION ────────────────────────────────────────────────
      // Dari semua pixel yang user gambar, berapa yang berada di atas huruf?
      int totalUserPixels = 0;
      int userOnLetter = 0;

      for (int y = 0; y < userHeight; y++) {
        for (int x = 0; x < userWidth; x++) {
          final int uByteIdx = (y * userWidth + x) * 4;
          if (uByteIdx + 3 >= userPixels.length) continue;

          final int alphaUser = userPixels[uByteIdx + 3];
          if (alphaUser < 30) continue;

          totalUserPixels++;

          bool nearLetter = false;
          outerPrec:
          for (int dy = -precisionTolerance; dy <= precisionTolerance; dy++) {
            for (int dx = -precisionTolerance; dx <= precisionTolerance; dx++) {
              final int nx = x + dx;
              final int ny = y + dy;
              if (nx < 0 || nx >= tempWidth || ny < 0 || ny >= tempHeight) {
                continue;
              }
              final int tByteIdx = (ny * tempWidth + nx) * 4;
              if (tByteIdx + 3 >= tempPixels.length) continue;
              if (tempPixels[tByteIdx + 3] > 30) {
                nearLetter = true;
                break outerPrec;
              }
            }
          }
          if (nearLetter) userOnLetter++;
        }
      }

      // ── Hitung Recall & Precision ─────────────────────────────────────────
      final double recall =
          totalTemplatePixels == 0 ? 0.0 : coveredByUser / totalTemplatePixels;

      final double precision =
          totalUserPixels == 0 ? 0.0 : userOnLetter / totalUserPixels;

      // ── F-beta Score (beta=1.2: recall sedikit lebih penting) ────────────
      // Ini mencegah asal coret: jika user coret seluruh kanvas,
      // precision sangat rendah (~5-10%) sehingga skor tetap buruk
      // meskipun recall = 100%
      const double beta = 1.2;
      const double betaSq = beta * beta;

      double fScore = 0.0;
      if (precision + recall > 0) {
        fScore = (1 + betaSq) *
            (precision * recall) /
            ((betaSq * precision) + recall);
      }

      // Konversi ke 0-100
      // fScore tracing bagus biasanya 0.55-0.75, dikalikan 140 → 77-100
      // fScore asal coret biasanya < 0.15 → skor < 21
      double finalScore = fScore * 140.0;
      if (finalScore > 100) finalScore = 100;

      // Hard cutoff: jika recall < 5% atau fScore terlalu rendah → skor 0
      if (recall < 0.05 || fScore < 0.05) finalScore = 0;

      debugPrint(
        'Score Debug:\n'
        '  Template pixels : $totalTemplatePixels\n'
        '  Covered by user : $coveredByUser\n'
        '  User pixels     : $totalUserPixels\n'
        '  User on letter  : $userOnLetter\n'
        '  Recall          : ${(recall * 100).toStringAsFixed(1)}%\n'
        '  Precision       : ${(precision * 100).toStringAsFixed(1)}%\n'
        '  F-score         : ${fScore.toStringAsFixed(3)}\n'
        '  Final score     : ${finalScore.toStringAsFixed(1)}',
      );

      setState(() => _isCalculating = false);
      _showScoreDialog(finalScore);
    } catch (e, stack) {
      setState(() => _isCalculating = false);
      debugPrint('Scoring Error: $e\n$stack');
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

    final Color barBg = isGreat
        ? const Color(0xFFE8F5E9)
        : (isOkay ? Colors.blue.shade50 : Colors.orange.shade50);

    // final int starCount = isGreat ? 3 : (isOkay ? 2 : 1);

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
            const SizedBox(height: 8),

            // Bintang
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: List.generate(3, (i) {
            //     final bool filled = i < starCount;
            //     return Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 4),
            //       child: Icon(
            //         filled ? Icons.star_rounded : Icons.star_outline_rounded,
            //         size: 40,
            //         color: filled
            //             ? Colors.amber.shade400
            //             : Colors.grey.shade300,
            //       ),
            //     );
            //   }),
            // ),

            const SizedBox(height: 12),

            Text(
              message,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: themeColor,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Akurasi Tracing',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 8),

            // Progress bar
            Container(
              width: double.infinity,
              height: 22,
              decoration: BoxDecoration(
                color: barBg,
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
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '${score.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: score > 50 ? Colors.white : barColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0%',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                Text(
                  score > 70
                      ? 'Hampir sempurna!'
                      : (score > 35 ? 'Terus berlatih!' : 'Jangan menyerah!'),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text('100%',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),

            const SizedBox(height: 24),

            _buildLargeButton(
              text: "Coba Lagi",
              onTap: () {
                Navigator.pop(context);
                _clearCanvas();
              },
              widthMultiplier: 0.65,
            ),
            const SizedBox(height: 10),
            _buildLargeButton(
              text: "Selesai",
              onTap: () {
                _navigateTo(const HalamanLatihan());
              },
              widthMultiplier: 0.65,
            ),
            const SizedBox(height: 4),
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
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => Container(color: Colors.green[100]),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),
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
                          // Toolbar
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildRoundButton(
                                    icon: Icons.undo, onTap: _undo),
                                const SizedBox(width: 8),
                                _buildRoundButton(
                                    icon: Icons.redo, onTap: _redo),
                                const SizedBox(width: 24),
                                _buildRoundButton(
                                    icon: Icons.delete, onTap: _clearCanvas),
                                const SizedBox(width: 8),
                                _buildRoundButton(
                                  icon: Icons.cleaning_services,
                                  onTap: () => setState(() => _isEraser = true),
                                  isActive: _isEraser,
                                  activeColor: Colors.orangeAccent,
                                ),
                                const SizedBox(width: 8),
                                _buildRoundButton(
                                  icon: Icons.edit,
                                  onTap: () =>
                                      setState(() => _isEraser = false),
                                  isActive: !_isEraser,
                                  activeColor: Colors.blueAccent,
                                ),
                              ],
                            ),
                          ),

                          // Slider ketebalan
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
                                Text(
                                  "${_strokeWidth.toInt()}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Canvas area
                          Center(
                            child: Container(
                              width: screenWidth * 0.90,
                              height: screenHeight * 0.50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.black, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Stack(
                                  children: [
                                    // ── Layer template ──────────────────
                                    // PERBAIKAN: RepaintBoundary di LUAR
                                    // Opacity agar toImage() membaca alpha
                                    // asli dari PNG, bukan alpha × 0.25
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
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // ── Layer canvas user ───────────────
                                    SizedBox.expand(
                                      child: RepaintBoundary(
                                        key: _canvasKey,
                                        child: GestureDetector(
                                          onPanStart: _onPanStart,
                                          onPanUpdate: _onPanUpdate,
                                          onPanEnd: _onPanEnd,
                                          child: CustomPaint(
                                            painter: _DrawingPainter(_strokes),
                                            size: Size.infinite,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Tombol CEK TULISAN
                          _isCalculating
                              ? Container(
                                  width: screenWidth * 0.55,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC7EFA3),
                                    borderRadius: BorderRadius.circular(30.0),
                                    border: Border.all(
                                        color: const Color(0xFF6EDC68),
                                        width: 2.5),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Color(0xFF4A8C40),
                                      ),
                                    ),
                                  ),
                                )
                              : _buildLargeButton(
                                  text: 'CEK TULISAN',
                                  onTap: _calculateScore,
                                ),

                          const SizedBox(height: 12),
                          _buildLargeButton(
                            text: 'Kembali',
                            onTap: () => Navigator.pop(context),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
    Color activeColor = Colors.black,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.black,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildLargeButton({
    required String text,
    required VoidCallback onTap,
    double widthMultiplier = 0.55,
  }) {
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
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4A8C40),
            ),
          ),
        ),
      ),
    );
  }
}
