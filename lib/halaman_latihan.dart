import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'halaman_hasil_klasifikasi.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'classifier.dart';
import 'package:flutter/rendering.dart';

enum DrawingMode { pencil, eraser }

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
        ..strokeWidth = stroke.width
        ..isAntiAlias = true;
      
      canvas.drawPath(stroke.path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class HalamanLatihan extends StatefulWidget {
  const HalamanLatihan({super.key});

  @override
  _HalamanLatihanState createState() => _HalamanLatihanState();
}

class _HalamanLatihanState extends State<HalamanLatihan> {
  List<Stroke> _strokes = [];
  List<Stroke> _redoStack = [];

  DrawingMode _currentMode = DrawingMode.pencil;
  double _strokeWidth = 10.0;
  final Color _pencilColor = Colors.black;
  final Color _eraserColor = Colors.white;

  final GlobalKey _canvasKey = GlobalKey();
  Classifier? _classifier;
  bool _loadingModel = false;

  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    setState(() => _loadingModel = true);
    try {
      _classifier = await Classifier.create();
    } catch (e) {
      debugPrint('Gagal load model: $e');
    } finally {
      setState(() => _loadingModel = false);
    }
  }

  void _onPanStart(DragStartDetails details) {
    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(details.globalPosition);

    _redoStack.clear(); // Hapus redo stack saat mulai coretan baru
    
    Path newPath = Path();
    newPath.moveTo(localPosition.dx, localPosition.dy);
    // Tambahkan lineTo yang sangat pendek agar titik (dot) bisa terlihat meskipun tidak digeser
    newPath.lineTo(localPosition.dx + 0.1, localPosition.dy + 0.1);

    setState(() {
      _isDrawing = true;
      _strokes.add(
        Stroke(
          path: newPath,
          color: (_currentMode == DrawingMode.pencil) ? _pencilColor : _eraserColor,
          width: _strokeWidth,
        ),
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null || _strokes.isEmpty) return;

    final localPosition = renderBox.globalToLocal(details.globalPosition);

    if (localPosition.dx >= 0 &&
        localPosition.dy >= 0 &&
        localPosition.dx <= renderBox.size.width &&
        localPosition.dy <= renderBox.size.height) {
      setState(() {
        _strokes.last.path.lineTo(localPosition.dx, localPosition.dy);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDrawing = false;
    });
  }

  void _undo() {
    setState(() {
      if (_strokes.isNotEmpty) {
        _redoStack.add(_strokes.removeLast());
      }
    });
  }

  void _redo() {
    setState(() {
      if (_redoStack.isNotEmpty) {
        _strokes.add(_redoStack.removeLast());
      }
    });
  }

  void _clearCanvas() {
    setState(() {
      _strokes = [];
      _redoStack = [];
    });
  }

  Future<Uint8List> _capturePngBytes() async {
    final boundary =
        _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _classifyAndShow() async {
    if (_classifier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model belum siap. Tunggu sebentar.')),
      );
      return;
    }

    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silahkan gambar terlebih dahulu.')),
      );
      return;
    }

    final pngBytes = await _capturePngBytes();

    Map<String, double> preds;
    try {
      preds = await _classifier!.predictFromPngBytes(pngBytes);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saat klasifikasi: $e')));
      return;
    }

    final sorted = preds.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;
    final label = top.key;
    final confidence = top.value;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HalamanHasilKlasifikasi(
          hijaiyahLetter: label,
          hijaiyahName: label,
          confidence: confidence,
          userDrawing: pngBytes,
        ),
      ),
    );

    if (result == true) {
      _clearCanvas();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.green[100]),
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
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    _buildRoundButton(
                                      icon: Icons.undo,
                                      onTap: _undo,
                                      tooltip: "Undo",
                                    ),
                                    const SizedBox(width: 8),
                                    _buildRoundButton(
                                      icon: Icons.redo,
                                      onTap: _redo,
                                      tooltip: "Redo",
                                    ),
                                    const SizedBox(width: 24),
                                    _buildRoundButton(
                                      icon: Icons.delete,
                                      onTap: _clearCanvas,
                                      tooltip: "Bersihkan",
                                    ),
                                    const SizedBox(width: 8),
                                    _buildRoundButton(
                                      icon: Icons.cleaning_services,
                                      onTap: () => setState(() =>
                                          _currentMode = DrawingMode.eraser),
                                      isActive:
                                          _currentMode == DrawingMode.eraser,
                                      activeColor: Colors.orangeAccent,
                                      tooltip: "Penghapus",
                                    ),
                                    const SizedBox(width: 8),
                                    _buildRoundButton(
                                      icon: Icons.edit,
                                      onTap: () => setState(() =>
                                          _currentMode = DrawingMode.pencil),
                                      isActive:
                                          _currentMode == DrawingMode.pencil,
                                      activeColor: Colors.blueAccent,
                                      tooltip: "Pensil",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Row(
                              children: [
                                Icon(
                                  _currentMode == DrawingMode.pencil
                                      ? Icons.line_weight
                                      : Icons.circle,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                Expanded(
                                  child: Slider(
                                    value: _strokeWidth,
                                    min: 1.0,
                                    max: 30.0,
                                    activeColor: Colors.white,
                                    inactiveColor: Colors.white24,
                                    onChanged: (val) =>
                                        setState(() => _strokeWidth = val),
                                  ),
                                ),
                                Text(
                                  _strokeWidth.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Center(
                            child: RepaintBoundary(
                              key: _canvasKey,
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
                                child: GestureDetector(
                                  onPanStart: _onPanStart,
                                  onPanUpdate: _onPanUpdate,
                                  onPanEnd: _onPanEnd,
                                  child: CustomPaint(
                                    painter: _DrawingPainter(_strokes),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: GestureDetector(
                              onTap: _loadingModel ? null : _classifyAndShow,
                              child: Container(
                                width: screenWidth * 0.55,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC7EFA3),
                                  borderRadius: BorderRadius.circular(30.0),
                                  border: Border.all(
                                      color: const Color(0xFF6EDC68),
                                      width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _loadingModel
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.green),
                                        )
                                      : const Text(
                                          'Cari Tahu',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF4A8C40),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: screenWidth * 0.55,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC7EFA3),
                                  borderRadius: BorderRadius.circular(30.0),
                                  border: Border.all(
                                      color: Color(0xFF6EDC68), width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'Kembali',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF4A8C40),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.05),
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
    String? tooltip,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: activeColor.withOpacity(0.3),
                blurRadius: 6,
                spreadRadius: 1,
              )
          ],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.black,
          size: 20,
        ),
      ),
    );
  }
}