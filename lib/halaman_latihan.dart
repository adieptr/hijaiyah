import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'halaman_hasil_klasifikasi.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'classifier.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math; // Ditambahkan untuk perhitungan trigonometri

enum DrawingMode { pencil, eraser }

// Model diperbarui: Menggunakan List<Offset> agar bisa memproses setiap titik untuk efek kaligrafi
class Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
  final DrawingMode mode;

  Stroke({
    required this.points,
    required this.color,
    required this.width,
    required this.mode,
  });
}

class _DrawingPainter extends CustomPainter {
  final List<Stroke> strokes;

  _DrawingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (var stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final paint = Paint()
        ..color = stroke.color
        ..style = PaintingStyle.fill // Menggunakan fill untuk menggambar "nib" kaligrafi
        ..isAntiAlias = true;

      // Jika mode penghapus, kita tetap menggunakan style stroke standar agar lebih bersih
      if (stroke.mode == DrawingMode.eraser) {
        final eraserPaint = Paint()
          ..color = stroke.color
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke.width;
        
        Path path = Path();
        path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (var i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, eraserPaint);
        continue;
      }

      // Logika Brush Kaligrafi (Ribbon Effect)
      // Sudut nib kaligrafi (biasanya 45 derajat atau -pi/4)
      const double angle = -math.pi / 4; 
      final double nibWidth = stroke.width;

      // Vektor offset untuk bentuk mata pena
      final Offset nibOffset = Offset(
        math.cos(angle) * (nibWidth / 2),
        math.sin(angle) * (nibWidth / 2),
      );

      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];

        // Hitung 4 titik poligon yang menghubungkan dua posisi nib
        final path = Path()
          ..moveTo(p1.dx - nibOffset.dx, p1.dy - nibOffset.dy)
          ..lineTo(p1.dx + nibOffset.dx, p1.dy + nibOffset.dy)
          ..lineTo(p2.dx + nibOffset.dx, p2.dy + nibOffset.dy)
          ..lineTo(p2.dx - nibOffset.dx, p2.dy - nibOffset.dy)
          ..close();

        canvas.drawPath(path, paint);
      }
      
      // Gambar "titik" di awal dan akhir jika hanya satu titik
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
  double _strokeWidth = 20; // Sedikit lebih tebal agar efek kaligrafi terasa
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
    final renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(details.globalPosition);
    _redoStack.clear();

    setState(() {
      _isDrawing = true;
      _strokes.add(
        Stroke(
          points: [localPosition],
          color: (_currentMode == DrawingMode.pencil) ? _pencilColor : _eraserColor,
          width: _strokeWidth,
          mode: _currentMode,
        ),
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || _strokes.isEmpty) return;

    final localPosition = renderBox.globalToLocal(details.globalPosition);

    if (localPosition.dx >= 0 &&
        localPosition.dy >= 0 &&
        localPosition.dx <= renderBox.size.width &&
        localPosition.dy <= renderBox.size.height) {
      setState(() {
        _strokes.last.points.add(localPosition);
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
    final boundary = _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _classifyAndShow() async {
    if (_classifier == null) {
      _showMessage('Model belum siap. Tunggu sebentar.');
      return;
    }
    if (_strokes.isEmpty) {
      _showMessage('Silahkan gambar terlebih dahulu.');
      return;
    }

    final pngBytes = await _capturePngBytes();
    try {
      final preds = await _classifier!.predictFromPngBytes(pngBytes);
      final sorted = preds.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final top = sorted.first;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HalamanHasilKlasifikasi(
            hijaiyahLetter: top.key,
            hijaiyahName: top.key,
            confidence: top.value,
            userDrawing: pngBytes,
          ),
        ),
      );

      if (result == true) _clearCanvas();
    } catch (e) {
      _showMessage('Error saat klasifikasi: $e');
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
              errorBuilder: (_, __, ___) => Container(color: Colors.green[100]),
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.15))),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: _isDrawing ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Toolbar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildRoundButton(icon: Icons.undo, onTap: _undo, tooltip: "Undo"),
                                const SizedBox(width: 8),
                                _buildRoundButton(icon: Icons.redo, onTap: _redo, tooltip: "Redo"),
                                const SizedBox(width: 24),
                                _buildRoundButton(icon: Icons.delete, onTap: _clearCanvas, tooltip: "Bersihkan"),
                                const SizedBox(width: 8),
                                _buildRoundButton(
                                  icon: Icons.cleaning_services,
                                  onTap: () => setState(() => _currentMode = DrawingMode.eraser),
                                  isActive: _currentMode == DrawingMode.eraser,
                                  activeColor: Colors.orangeAccent,
                                  tooltip: "Penghapus",
                                ),
                                const SizedBox(width: 8),
                                _buildRoundButton(
                                  icon: Icons.edit,
                                  onTap: () => setState(() => _currentMode = DrawingMode.pencil),
                                  isActive: _currentMode == DrawingMode.pencil,
                                  activeColor: Colors.blueAccent,
                                  tooltip: "Brush Kaligrafi",
                                ),
                              ],
                            ),
                          ),
                          // Slider Tebal Brush
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Row(
                              children: [
                                const Icon(Icons.line_weight, size: 16, color: Colors.white),
                                Expanded(
                                  child: Slider(
                                    value: _strokeWidth,
                                    min: 1.0,
                                    max: 40.0,
                                    activeColor: Colors.white,
                                    inactiveColor: Colors.white24,
                                    onChanged: (val) => setState(() => _strokeWidth = val),
                                  ),
                                ),
                                Text(
                                  _strokeWidth.toInt().toString(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          // Area Menggambar
                          Center(
                            child: RepaintBoundary(
                              key: _canvasKey,
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
                          // Tombol Aksi
                          _buildActionButton(
                            text: 'Cari Tahu',
                            onTap: _loadingModel ? null : _classifyAndShow,
                            isLoading: _loadingModel,
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            text: 'Menu',
                            onTap: () =>  Navigator.popUntil(context, (route) => route.isFirst),
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

  Widget _buildActionButton({required String text, VoidCallback? onTap, bool isLoading = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.55,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFC7EFA3),
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(color: const Color(0xFF6EDC68), width: 2.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 4)),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green))
                : Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF4A8C40))),
          ),
        ),
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
        ),
        child: Icon(icon, color: isActive ? Colors.white : Colors.black, size: 20),
      ),
    );
  }
}