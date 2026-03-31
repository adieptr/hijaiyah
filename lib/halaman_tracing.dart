import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';

// Model untuk menyimpan satu coretan
class Stroke {
  final Path path;
  final Color color;
  final double width;

  Stroke({
    required this.path,
    required this.color,
    required this.width,
  });
}

class _DrawingPainter extends CustomPainter {
  final List<Stroke> strokes;
  _DrawingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (var stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke.width;
      canvas.drawPath(stroke.path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
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
  Color _currentColor = const Color(0xFF2E7D32); // Hijau Default
  double _strokeWidth = 20.0;
  bool _isDrawing = false;
  bool _isEraser = false;

  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _templateKey = GlobalKey();

  // Fitur Drawing
  void _onPanStart(DragStartDetails details) {
    HapticFeedback.lightImpact();
    _redoStack.clear();
    RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    Offset localPos = renderBox.globalToLocal(details.globalPosition);
    Path newPath = Path();
    newPath.moveTo(localPos.dx, localPos.dy);

    // Perbaikan penulisan titik: Tambahkan lineTo yang sangat pendek
    // agar titik (dot) bisa terlihat meskipun tidak digeser
    newPath.lineTo(localPos.dx + 0.1, localPos.dy + 0.1);

    setState(() {
      _isDrawing = true;
      _strokes.add(Stroke(
          path: newPath,
          color: _isEraser ? Colors.white : _currentColor,
          width: _strokeWidth));
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
        _strokes.last.path.lineTo(localPos.dx, localPos.dy);
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

  Future<void> _calculateScore() async {
    try {
      const double scanRatio = 0.1;
      RenderRepaintBoundary userBoundary = _canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image userImg = await userBoundary.toImage(pixelRatio: scanRatio);
      ByteData? userBytes =
          await userImg.toByteData(format: ui.ImageByteFormat.rawRgba);

      RenderRepaintBoundary tempBoundary = _templateKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image tempImg = await tempBoundary.toImage(pixelRatio: scanRatio);
      ByteData? tempBytes =
          await tempImg.toByteData(format: ui.ImageByteFormat.rawRgba);

      if (userBytes == null || tempBytes == null) return;

      final Uint32List userBuffer = userBytes.buffer.asUint32List();
      final Uint32List tempBuffer = tempBytes.buffer.asUint32List();

      int totalTargetPixels = 0;
      int matchedPixels = 0;
      int imgWidth = userImg.width;
      int imgHeight = userImg.height;

      for (int y = 0; y < imgHeight; y++) {
        for (int x = 0; x < imgWidth; x++) {
          int index = y * imgWidth + x;
          if (index >= tempBuffer.length) break;

          int alphaTemp = (tempBuffer[index] >> 24) & 0xFF;
          if (alphaTemp > 100) {
            totalTargetPixels++;
            bool hit = false;
            for (int dy = -2; dy <= 2; dy++) {
              for (int dx = -2; dx <= 2; dx++) {
                int nx = x + dx;
                int ny = y + dy;
                if (nx >= 0 && nx < imgWidth && ny >= 0 && ny < imgHeight) {
                  int nIndex = ny * imgWidth + nx;
                  int alphaUser = (userBuffer[nIndex] >> 24) & 0xFF;
                  if (alphaUser > 50) {
                    hit = true;
                    break;
                  }
                }
              }
              if (hit) break;
            }
            if (hit) matchedPixels++;
          }
        }
      }

      double rawAccuracy = totalTargetPixels == 0
          ? 0
          : (matchedPixels / totalTargetPixels) * 100;
      double finalScore = rawAccuracy * 1.5;
      if (finalScore > 100) finalScore = 100;
      if (rawAccuracy < 2) finalScore = 0;

      _showScoreDialog(finalScore);
    } catch (e) {
      debugPrint("Scoring Error: $e");
    }
  }

  void _showScoreDialog(double accuracy) {
    String message = accuracy > 70
        ? "Bagus Sekali!"
        : (accuracy > 35 ? "Sudah Mirip!" : "Ayo Coba Lagi!");
    Color themeColor = accuracy > 70
        ? const Color(0xFF4A8C40)
        : (accuracy > 35 ? Colors.blue.shade800 : Colors.orange.shade800);

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
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFC7EFA3).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.stars, size: 80, color: themeColor),
            ),
            const SizedBox(height: 20),
            Text(message,
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: themeColor)),
            const SizedBox(height: 30),
            _buildLargeButton(
              text: "Coba Lagi",
              onTap: () {
                Navigator.pop(context);
                _clearCanvas();
              },
              widthMultiplier: 0.6,
            ),
            const SizedBox(height: 12),
            _buildLargeButton(
              text: "Selesai",
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              widthMultiplier: 0.6,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // MENGAMBIL ASET DARI FOLDER hijaiyah_tracing
    String hijaiyahImagePath =
        'assets/images/hijaiyah_tracing/${widget.hijaiyahName.toLowerCase()}.png';

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
              child: Image.asset('assets/images/bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.green[100]))),
          // Overlay Darker
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

                          // Slider Ketebalan
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
                                    min: 5.0,
                                    max: 50.0,
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
                                border:
                                    Border.all(color: Colors.black, width: 2),
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
                                    // Layer Template (Folder hijaiyah_tracing)
                                    SizedBox.expand(
                                      child: RepaintBoundary(
                                        key: _templateKey,
                                        child: Opacity(
                                          opacity: 0.25,
                                          child: Image.asset(hijaiyahImagePath,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) =>
                                                  Center(
                                                      child: Text(
                                                          widget.hijaiyahLetter,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 150,
                                                                  color: Colors
                                                                      .grey)))),
                                        ),
                                      ),
                                    ),
                                    // Layer Drawing
                                    SizedBox.expand(
                                      child: RepaintBoundary(
                                        key: _canvasKey,
                                        child: GestureDetector(
                                          onPanStart: _onPanStart,
                                          onPanUpdate: _onPanUpdate,
                                          onPanEnd: _onPanEnd,
                                          child: CustomPaint(
                                              painter:
                                                  _DrawingPainter(_strokes),
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

                          // Action Buttons
                          _buildLargeButton(
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

  Widget _buildRoundButton(
      {required IconData icon,
      required VoidCallback onTap,
      bool isActive = false,
      Color activeColor = Colors.black}) {
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
                offset: const Offset(0, 4)),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF4A8C40)),
          ),
        ),
      ),
    );
  }
}
