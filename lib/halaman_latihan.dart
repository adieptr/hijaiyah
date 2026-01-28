import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'halaman_hasil_klasifikasi.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import 'classifier.dart';
import 'package:flutter/rendering.dart';

enum DrawingMode { pencil, eraser }
=======
import 'package:image/image.dart' as img;
import 'classifier.dart';
import 'package:flutter/rendering.dart';

>>>>>>> 902d497b1050f32ce8ed227cd40beec5fe5d96f7

class _DrawingPoint {
  final Offset position;
  final Paint paint;

  _DrawingPoint(this.position, this.paint);
}

class _DrawingPainter extends CustomPainter {
  final List<_DrawingPoint?> points;

  _DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
          points[i]!.position,
          points[i + 1]!.position,
          points[i]!.paint,
        );
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(
          PointMode.points,
          [points[i]!.position],
          points[i]!.paint,
        );
      }
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
  List<_DrawingPoint?> _points = [];

  DrawingMode _currentMode = DrawingMode.pencil;
  double _strokeWidth = 5.0;
  final Color _pencilColor = Colors.black;
  final Color _eraserColor = Colors.white;

  final GlobalKey _canvasKey = GlobalKey();
  Classifier? _classifier;
  bool _loadingModel = false;

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

  void _addPoint(DragUpdateDetails details) {
    final renderBox = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    if (localPosition.dx >= 0 &&
        localPosition.dy >= 0 &&
        localPosition.dx <= renderBox.size.width &&
        localPosition.dy <= renderBox.size.height) {
      setState(() {
        _points.add(
          _DrawingPoint(
            localPosition,
            Paint()
              ..color = (_currentMode == DrawingMode.pencil)
                  ? _pencilColor
                  : _eraserColor
              ..strokeWidth = _strokeWidth
              ..strokeCap = StrokeCap.round
              ..isAntiAlias = true,
          ),
        );
      });
    }
  }

  void _endDrawing() {
    setState(() {
      _points.add(null);
    });
  }

  void _clearCanvas() {
    setState(() {
      _points = [];
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

<<<<<<< HEAD
    final pngBytes = await _capturePngBytes();

=======
    // capture
    final pngBytes = await _capturePngBytes();

    // optionally, you can do further cropping / centering here.
>>>>>>> 902d497b1050f32ce8ed227cd40beec5fe5d96f7
    Map<String, double> preds;
    try {
      preds = await _classifier!.predictFromPngBytes(pngBytes);
    } catch (e) {
<<<<<<< HEAD
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saat klasifikasi: $e')));
      return;
    }

=======
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saat klasifikasi: $e')));
      return;
    }

    // find top-1
>>>>>>> 902d497b1050f32ce8ed227cd40beec5fe5d96f7
    final sorted = preds.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;
    final label = top.key;
    final confidence = top.value;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HalamanHasilKlasifikasi(
          hijaiyahLetter: label,
<<<<<<< HEAD
          hijaiyahName: label,
=======
          hijaiyahName: label, // you can map label -> nicer name if labels.txt already friendly
>>>>>>> 902d497b1050f32ce8ed227cd40beec5fe5d96f7
          confidence: confidence,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.15),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRoundButton(
                        icon: Icons.home,
                        onTap: () => Navigator.pop(context),
                      ),
                      Row(
                        children: [
                          _buildRoundButton(
                            icon: Icons.delete,
                            onTap: _clearCanvas,
                            tooltip: "Bersihkan",
                          ),
                          const SizedBox(width: 8),
                          _buildRoundButton(
                            icon: Icons.cleaning_services,
                            onTap: () => setState(
                                () => _currentMode = DrawingMode.eraser),
                            isActive: _currentMode == DrawingMode.eraser,
                            activeColor: Colors.orangeAccent,
                            tooltip: "Penghapus",
                          ),
                          const SizedBox(width: 8),
                          _buildRoundButton(
                            icon: Icons.edit,
                            onTap: () => setState(
                                () => _currentMode = DrawingMode.pencil),
                            isActive: _currentMode == DrawingMode.pencil,
                            activeColor: Colors.blueAccent,
                            tooltip: "Pensil",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Icon(
                          _currentMode == DrawingMode.pencil
                              ? Icons.line_weight
                              : Icons.circle,
                          size: 20,
                          color: Colors.white),
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
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: RepaintBoundary(
                    key: _canvasKey,
                    child: Container(
                      width: screenWidth * 0.9,
<<<<<<< HEAD
                      height: screenHeight * 0.45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
=======
                      height: screenHeight * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
>>>>>>> 902d497b1050f32ce8ed227cd40beec5fe5d96f7
                      ),
                      child: GestureDetector(
                        onPanUpdate: _addPoint,
                        onPanEnd: (details) => _endDrawing(),
                        child: CustomPaint(
                          painter: _DrawingPainter(_points),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: Text(
                          'ini huruf apa?',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        height: screenHeight * 0.15,
                        child: Image.asset(
                          'assets/images/anak.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
<<<<<<< HEAD
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: _loadingModel ? null : _classifyAndShow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC7EFA3),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.2,
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: const BorderSide(
                            color: Color(0xFF6EDC68), width: 3),
                      ),
                      elevation: 8,
                    ),
                    child: _loadingModel
                        ? const CircularProgressIndicator()
                        : Text(
                            'Cari Tahu',
                            style: TextStyle(
                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4A8C40),
                            ),
                          ),
                  ),
=======

                SizedBox(height: screenHeight * 0.03),

                ElevatedButton(
                  onPressed: _loadingModel ? null : _classifyAndShow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC7EFA3),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.15,
                      vertical: screenHeight * 0.025,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side:
                          const BorderSide(color: Color(0xFF6EDC68), width: 3),
                    ),
                    shadowColor: Colors.black.withOpacity(0.5),
                    elevation: 10,
                  ),
                  child: _loadingModel
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(),
                        )
                      : Text(
                          'Cari Tahu',
                          style: TextStyle(
                            fontSize: screenWidth * 0.07,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4A8C40),
                          ),
                        ),
>>>>>>> 902d497b1050f32ce8ed227cd40beec5fe5d96f7
                ),
              ],
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            if (isActive)
              BoxShadow(
                  color: activeColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2)
          ],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.black,
          size: 28,
        ),
      ),
    );
  }
}
