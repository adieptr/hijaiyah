import 'dart:typed_data';
import 'dart:ui' as ui;
<<<<<<< HEAD
=======
import 'dart:typed_data';
import 'dart:ui' as ui;
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
import 'package:flutter/material.dart';
import 'halaman_hasil_klasifikasi.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'classifier.dart';
import 'package:flutter/rendering.dart';
<<<<<<< HEAD
import 'halaman_utama.dart';
=======
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5

enum DrawingMode { pencil, eraser }

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
        // Menggambar garis antar titik
        canvas.drawLine(
          points[i]!.position,
          points[i + 1]!.position,
          points[i]!.paint,
        );
      } else if (points[i] != null && points[i + 1] == null) {
        // Menggambar titik tunggal jika titik berikutnya kosong (untuk tap/dot)
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
  double _strokeWidth = 10.0;
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
<<<<<<< HEAD

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

  void _processPointerEvent(Offset globalPosition) {
    final RenderBox renderBox =
        _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(globalPosition);

=======

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

  // Fungsi helper untuk menambahkan titik berdasarkan posisi global
  void _processPointerEvent(Offset globalPosition) {
    final RenderBox renderBox = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(globalPosition);

    // Memastikan titik berada di dalam area kanvas
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
    if (localPosition.dx >= 0 &&
        localPosition.dy >= 0 &&
        localPosition.dx <= renderBox.size.width &&
        localPosition.dy <= renderBox.size.height) {
      setState(() {
        _points.add(
          _DrawingPoint(
            localPosition,
            Paint()
<<<<<<< HEAD
              ..color = (_currentMode == DrawingMode.pencil)
                  ? _pencilColor
                  : _eraserColor
              ..strokeWidth = _strokeWidth
              ..strokeCap = StrokeCap.round
              ..isAntiAlias = true,
=======
              ..color = (_currentMode == DrawingMode.pencil) ? _pencilColor : _eraserColor
              ..strokeWidth = _strokeWidth
              ..strokeCap = StrokeCap.round
              ..isAntiAlias = true,
              ..strokeCap = StrokeCap.round
              ..isAntiAlias = true,
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
          ),
        );
      });
    }
  }

  void _endDrawing() {
    setState(() {
<<<<<<< HEAD
      _points.add(null);
=======
      _points.add(null); // Penanda akhir garis/titik
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
    });
  }

  void _clearCanvas() {
    setState(() {
      _points = [];
    });
  }

  Future<Uint8List> _capturePngBytes() async {
<<<<<<< HEAD
    final boundary =
        _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
=======
    final boundary = _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
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

    if (_points.isEmpty) {
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
<<<<<<< HEAD
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saat klasifikasi: $e')));
      return;
    }

    final sorted = preds.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
=======
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saat klasifikasi: $e')));
      return;
    }

    final sorted = preds.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
    final top = sorted.first;
    final label = top.key;
    final confidence = top.value;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HalamanHasilKlasifikasi(
          hijaiyahLetter: label,
          hijaiyahName: label,
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
<<<<<<< HEAD
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.green[100]),
=======
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.green[100]),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),
          SafeArea(
            child: Column(
              children: [
<<<<<<< HEAD
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
=======
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRoundButton(
                        icon: Icons.home,
<<<<<<< HEAD
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HomeScreen()),
                            (route) => false, // Bersihkan semua stack halaman
                          );
                        },
=======
                        onTap: () => Navigator.pop(context),
                      _buildRoundButton(
                        icon: Icons.home,
                        onTap: () => Navigator.pop(context),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                      ),
                      Row(
                        children: [
                          _buildRoundButton(
                            icon: Icons.delete,
<<<<<<< HEAD
=======
                          _buildRoundButton(
                            icon: Icons.delete,
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                            onTap: _clearCanvas,
                            tooltip: "Bersihkan",
                          ),
                          const SizedBox(width: 8),
                          _buildRoundButton(
                            icon: Icons.cleaning_services,
<<<<<<< HEAD
                            onTap: () => setState(
                                () => _currentMode = DrawingMode.eraser),
=======
                            onTap: () => setState(() => _currentMode = DrawingMode.eraser),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                            isActive: _currentMode == DrawingMode.eraser,
                            activeColor: Colors.orangeAccent,
                            tooltip: "Penghapus",
                          ),
                          const SizedBox(width: 8),
                          _buildRoundButton(
                            icon: Icons.edit,
<<<<<<< HEAD
                            onTap: () => setState(
                                () => _currentMode = DrawingMode.pencil),
=======
                            onTap: () => setState(() => _currentMode = DrawingMode.pencil),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                            isActive: _currentMode == DrawingMode.pencil,
                            activeColor: Colors.blueAccent,
                            tooltip: "Pensil",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
<<<<<<< HEAD

                // Slider Stroke
=======
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Icon(
<<<<<<< HEAD
                        _currentMode == DrawingMode.pencil
                            ? Icons.line_weight
                            : Icons.circle,
                        size: 16,
=======
                        _currentMode == DrawingMode.pencil ? Icons.line_weight : Icons.circle,
                        size: 20,
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                        color: Colors.white,
                      ),
                      Expanded(
                        child: Slider(
                          value: _strokeWidth,
                          min: 1.0,
                          max: 30.0,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white24,
<<<<<<< HEAD
                          onChanged: (val) =>
                              setState(() => _strokeWidth = val),
=======
                          onChanged: (val) => setState(() => _strokeWidth = val),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                        ),
                      ),
                      Text(
                        _strokeWidth.toInt().toString(),
<<<<<<< HEAD
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
=======
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                      )
                    ],
                  ),
                ),
<<<<<<< HEAD

                SizedBox(height: screenHeight * 0.01),

                // Area Kanvas - UKURAN DIPERBESAR
                Center(
                  child: RepaintBoundary(
                    key: _canvasKey,
                    child: Container(
                      width: screenWidth * 0.90, // Diperbesar dari 0.85
                      height: screenHeight * 0.50, // Diperbesar dari 0.38
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
=======
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: RepaintBoundary(
                  child: RepaintBoundary(
                    key: _canvasKey,
                    child: Container(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
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
<<<<<<< HEAD
                        onPanStart: (details) =>
                            _processPointerEvent(details.globalPosition),
                        onPanUpdate: (details) =>
                            _processPointerEvent(details.globalPosition),
=======
                        // PERBAIKAN: Tambahkan onPanStart untuk mendeteksi sentuhan awal (titik)
                        onPanStart: (details) => _processPointerEvent(details.globalPosition),
                        onPanUpdate: (details) => _processPointerEvent(details.globalPosition),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                        onPanEnd: (details) => _endDrawing(),
                        child: CustomPaint(
                          painter: _DrawingPainter(_points),
                        ),
                      ),
                    ),
                  ),
                ),
<<<<<<< HEAD

                SizedBox(height: screenHeight * 0.02),

                // Hint & Karakter
=======
                SizedBox(height: screenHeight * 0.02),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                Center(
                  child: Column(
                    children: [
                      Container(
<<<<<<< HEAD
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
=======
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 1.5),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: Text(
                          'ini huruf apa?',
                          style: TextStyle(
<<<<<<< HEAD
                            fontSize: 14,
=======
                            fontSize: screenWidth * 0.045,
                            fontSize: screenWidth * 0.045,
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
<<<<<<< HEAD
                        height: screenHeight *
                            0.10, // Sedikit dikurangi agar tombol muat
                        child: Image.asset(
                          'assets/images/anak.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, size: 50),
=======
                        height: screenHeight * 0.15,
                        child: Image.asset(
                          'assets/images/anak.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 80),
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                        ),
                      ),
                    ],
                  ),
                ),
<<<<<<< HEAD

                const Spacer(),

                // Tombol "Cari Tahu"
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 60),
                  child: GestureDetector(
                    onTap: _loadingModel ? null : _classifyAndShow,
                    child: Container(
                      width: screenWidth * 0.75,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC7EFA3),
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(
                            color: const Color(0xFF6EDC68), width: 2.5),
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
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.green),
                              )
                            : Text(
                                'Cari Tahu',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF4A8C40),
                                ),
                              ),
                      ),
=======
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 85),
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
                        side: const BorderSide(color: Color(0xFF6EDC68), width: 3),
                      ),
                      elevation: 8,
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
                    ),
                    child: _loadingModel
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
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
<<<<<<< HEAD
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
=======
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
                spreadRadius: 2,
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
              )
          ],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.black,
<<<<<<< HEAD
          size: 22,
=======
          size: 28,
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> ee6bfca77d025d9b10bde248525fb28997d5d1c5
