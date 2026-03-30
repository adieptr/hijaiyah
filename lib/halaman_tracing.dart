import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

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

// Painter yang efisien menggunakan Path
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
  // Logic State
  List<Stroke> _strokes = [];
  List<Stroke> _redoStack = [];
  
  Color _currentColor = const Color(0xFF2E7D32);
  double _strokeWidth = 12.0;
  bool _isDrawing = false;

  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _templateKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Kanvas langsung siap digunakan tanpa menunggu animasi
  }

  // --- Fitur Drawing Logic ---

  void _onPanStart(DragStartDetails details) {
    HapticFeedback.lightImpact();
    _redoStack.clear();

    RenderBox renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox;
    Offset localPos = renderBox.globalToLocal(details.globalPosition);

    Path newPath = Path();
    newPath.moveTo(localPos.dx, localPos.dy);

    setState(() {
      _isDrawing = true;
      _strokes.add(Stroke(
        path: newPath,
        color: _currentColor,
        width: _strokeWidth,
      ));
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    RenderBox renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox;
    Offset localPos = renderBox.globalToLocal(details.globalPosition);

    if (localPos.dx >= 0 && localPos.dy >= 0 && 
        localPos.dx <= renderBox.size.width && 
        localPos.dy <= renderBox.size.height) {
      
      setState(() {
        _strokes.last.path.lineTo(localPos.dx, localPos.dy);
      });

      if (_strokes.last.path.getBounds().width.toInt() % 5 == 0) {
        HapticFeedback.selectionClick();
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _isDrawing = false);
  }

  void _undo() => setState(() { if (_strokes.isNotEmpty) _redoStack.add(_strokes.removeLast()); });
  void _redo() => setState(() { if (_redoStack.isNotEmpty) _strokes.add(_redoStack.removeLast()); });
  void _clearCanvas() => setState(() { _strokes.clear(); _redoStack.clear(); });

  Future<void> _calculateScore() async {
    try {
      RenderRepaintBoundary userBoundary = _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image userImg = await userBoundary.toImage(pixelRatio: 0.4); 
      ByteData? userBytes = await userImg.toByteData(format: ui.ImageByteFormat.rawRgba);

      RenderRepaintBoundary tempBoundary = _templateKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image tempImg = await tempBoundary.toImage(pixelRatio: 0.4);
      ByteData? tempBytes = await tempImg.toByteData(format: ui.ImageByteFormat.rawRgba);

      if (userBytes == null || tempBytes == null) return;

      int matchCount = 0;
      int totalTemplatePixels = 0;
      final bufferUser = userBytes.buffer.asUint32List();
      final bufferTemp = tempBytes.buffer.asUint32List();

      for (int i = 0; i < bufferTemp.length; i++) {
        bool isTemplatePixel = (bufferTemp[i] & 0xFF000000) != 0;
        if (isTemplatePixel) {
          totalTemplatePixels++;
          if ((bufferUser[i] & 0xFF000000) != 0) matchCount++;
        }
      }

      double accuracy = (matchCount / totalTemplatePixels) * 100;
      _showScoreDialog(accuracy);
    } catch (e) {
      debugPrint("Scoring Error: $e");
    }
  }

  void _showScoreDialog(double accuracy) {
    String message = "";
    String subMessage = "";
    Color themeColor = Colors.green;
    IconData feedbackIcon = Icons.mood;

    if (accuracy > 70) {
      message = "Bagus Sekali!";
      subMessage = "Tulisanmu sudah sangat mirip dan rapi.";
      themeColor = Colors.green;
      feedbackIcon = Icons.sentiment_very_satisfied;
    } else if (accuracy > 40) {
      message = "Sudah Mirip!";
      subMessage = "Terus berlatih supaya lebih rapi lagi ya.";
      themeColor = Colors.blue;
      feedbackIcon = Icons.sentiment_satisfied_alt;
    } else if (accuracy > 10) {
      message = "Ayo Terus Berusaha!";
      subMessage = "Jangan menyerah, kamu pasti bisa!";
      themeColor = Colors.orange;
      feedbackIcon = Icons.sentiment_neutral;
    } else {
      message = "Ayo Coba Lagi!";
      subMessage = "Ikuti garisnya pelan-pelan saja ya.";
      themeColor = Colors.redAccent;
      feedbackIcon = Icons.refresh;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Icon(feedbackIcon, size: 80, color: themeColor),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: themeColor),
            ),
            const SizedBox(height: 10),
            Text(
              subMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            _buildWideButton(
              text: "Coba Lagi", 
              color: Colors.orange.shade400, 
              onTap: () { 
                Navigator.pop(context); 
                _clearCanvas(); 
              }
            ),
            const SizedBox(height: 10),
            _buildWideButton(
              text: "Selesai", 
              color: Colors.green, 
              onTap: () { 
                Navigator.pop(context); 
                Navigator.pop(context); 
              }
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
    String hijaiyahImagePath = 'assets/images/hijaiyah/${widget.hijaiyahName.toLowerCase()}.png';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png', 
              fit: BoxFit.cover, 
              errorBuilder: (_, __, ___) => Container(color: Colors.green[50])
            )
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      _buildRoundButton(icon: Icons.arrow_back_ios_new, onTap: () => Navigator.pop(context)),
                      const Spacer(),
                      Text(
                        "Ayo Menulis!", 
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.green.shade800)
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // Padding balance
                    ],
                  ),
                ),

                // Toolbar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRoundButton(icon: Icons.undo, onTap: _undo),
                      const SizedBox(width: 10),
                      _buildRoundButton(icon: Icons.redo, onTap: _redo),
                      const SizedBox(width: 10),
                      _buildRoundButton(
                        icon: Icons.edit, 
                        onTap: () => setState(() => _currentColor = const Color(0xFF2E7D32)), 
                        isActive: _currentColor != Colors.white, 
                        activeColor: Colors.green
                      ),
                      const SizedBox(width: 10),
                      _buildRoundButton(
                        icon: Icons.cleaning_services, 
                        onTap: () => setState(() => _currentColor = Colors.white), 
                        isActive: _currentColor == Colors.white, 
                        activeColor: Colors.orange
                      ),
                      const SizedBox(width: 10),
                      _buildRoundButton(icon: Icons.delete_forever, onTap: _clearCanvas, activeColor: Colors.red),
                    ],
                  ),
                ),

                const Spacer(),

                // Canvas Container
                Center(
                  child: Container(
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)],
                      border: Border.all(color: Colors.green.shade100, width: 8),
                    ),
                    child: Stack(
                      children: [
                        // Layer Huruf (Template)
                        Center(
                          child: RepaintBoundary(
                            key: _templateKey,
                            child: Opacity(
                              opacity: 0.15,
                              child: Image.asset(
                                hijaiyahImagePath, 
                                width: screenWidth * 0.70, 
                                height: screenHeight * 0.40, 
                                fit: BoxFit.contain, 
                                errorBuilder: (_, __, ___) => Text(
                                  widget.hijaiyahLetter, 
                                  style: const TextStyle(fontSize: 200, color: Colors.grey)
                                )
                              ),
                            ),
                          ),
                        ),

                        // Layer Drawing User
                        RepaintBoundary(
                          key: _canvasKey,
                          child: GestureDetector(
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            child: CustomPaint(
                              painter: _DrawingPainter(_strokes), 
                              size: Size.infinite
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Action Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      _buildWideButton(
                        text: 'CEK TULISAN', 
                        color: const Color(0xFF6EDC68), 
                        onTap: _calculateScore
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => Navigator.pop(context), 
                        child: Text(
                          "Keluar ke Menu Utama", 
                          style: TextStyle(color: Colors.grey.shade600, decoration: TextDecoration.underline)
                        )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton({required IconData icon, required VoidCallback onTap, bool isActive = false, Color activeColor = Colors.blue}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white, 
          shape: BoxShape.circle, 
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)], 
          border: Border.all(color: Colors.grey.shade200, width: 2)
        ),
        child: Icon(icon, color: isActive ? Colors.white : Colors.black87, size: 24),
      ),
    );
  }

  Widget _buildWideButton({required String text, required Color color, required VoidCallback onTap}) {
    return Container(
      width: 220, height: 60,
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color, 
          foregroundColor: Colors.white, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), 
          elevation: 0
        ),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      ),
    );
  }
}