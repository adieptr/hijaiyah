import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'halaman_hasil_klasifikasi.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'classifier.dart';
import 'package:flutter/rendering.dart';


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
  Color _currentColor = Colors.black;
  double _strokeWidth = 5.0;

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
              ..color = _currentColor
              ..strokeWidth = _strokeWidth
              ..strokeCap = StrokeCap.round,
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

    // capture
    final pngBytes = await _capturePngBytes();

    // optionally, you can do further cropping / centering here.
    Map<String, double> preds;
    try {
      preds = await _classifier!.predictFromPngBytes(pngBytes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saat klasifikasi: $e')));
      return;
    }

    // find top-1
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
          hijaiyahName: label, // you can map label -> nicer name if labels.txt already friendly
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
                // Top Buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: const Icon(Icons.home,
                              color: Colors.black, size: 30),
                        ),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: _clearCanvas,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.black, width: 2),
                              ),
                              child: const Icon(Icons.delete,
                                  color: Colors.black, size: 30),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _currentColor = Colors.black;
                                _strokeWidth = 5.0;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.black, width: 2),
                              ),
                              child: const Icon(Icons.draw,
                                  color: Colors.black, size: 30),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),

                // Canvas Area
                Center(
                  child: RepaintBoundary(
                    key: _canvasKey,
                    child: Container(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
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

                SizedBox(height: screenHeight * 0.03),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Text(
                          'ini huruf apa?',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/images/anak.png',
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),

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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
