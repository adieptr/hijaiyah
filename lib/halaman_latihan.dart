import 'package:flutter/material.dart';
import 'dart:ui';

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

  void _addPoint(DragUpdateDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

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

  void _endDrawing() {
    _points.add(null);
  }

  void _clearCanvas() {
    setState(() {
      _points = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://placehold.co/600x1200/90c7f2/ffffff?text=Latar%20Belakang',
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
                          // Tombol hapus
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
                          // Tombol tulis
                          InkWell(
                            onTap: () {
                              setState(() {
                                // Ganti warna atau mode menggambar
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
                // Kanvas untuk menggambar
                Center(
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
                      Image.network(
                        'https://placehold.co/200x200/png?text=Gambar+Anak',
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                // Tombol Cari Tahu
                ElevatedButton(
                  onPressed: () {
                    // Aksi untuk tombol "Cari Tahu"
                  },
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
                  child: Text(
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
