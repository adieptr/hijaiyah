import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'halaman_hasil_klasifikasi.dart';
import 'profil.dart';
import '../db/db_helper.dart';
import '../utils/session.dart';
import 'classifier.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

enum DrawingMode { pencil, eraser }

// Model diperbarui: Menambahkan isCalligraphy untuk menentukan gaya lukisan per stroke
class Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
  final DrawingMode mode;
  final bool isCalligraphy;

  Stroke({
    required this.points,
    required this.color,
    required this.width,
    required this.mode,
    this.isCalligraphy = true,
  });
}

class _DrawingPainter extends CustomPainter {
  final List<Stroke> strokes;

  _DrawingPainter(this.strokes);

  @override
  void paint(ui.Canvas canvas, Size size) {
    for (var stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      // Jika mode penghapus
      if (stroke.mode == DrawingMode.eraser) {
        final eraserPaint = Paint()
          ..color = stroke.color
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke.width;

        if (stroke.points.length == 1) {
          // Mengizinkan hapusan titik tunggal
          canvas.drawCircle(stroke.points.first, stroke.width / 2,
              eraserPaint..style = PaintingStyle.fill);
        } else {
          Path path = Path();
          path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
          for (var i = 1; i < stroke.points.length; i++) {
            path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
          }
          canvas.drawPath(path, eraserPaint);
        }
        continue;
      }

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
          canvas.drawCircle(stroke.points.first, stroke.width / 2,
              normalPaint..style = PaintingStyle.fill);
        } else {
          Path path = Path();
          path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
          for (var i = 1; i < stroke.points.length; i++) {
            path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
          }
          canvas.drawPath(path, normalPaint);
        }
      } else {
        // GAYA PENA KALIGRAFI (Ribbon Effect)
        final calligraphyPaint = Paint()
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

          canvas.drawPath(path, calligraphyPaint);
        }

        // Titik pada kaligrafi tetap menggunakan bentuk kotak miring (nib)
        if (stroke.points.length == 1) {
          final p = stroke.points.first;
          final path = Path()
            ..moveTo(p.dx - nibOffset.dx, p.dy - nibOffset.dy)
            ..lineTo(p.dx + nibOffset.dx, p.dy + nibOffset.dy)
            ..lineTo(p.dx + 0.1 + nibOffset.dx, p.dy + 0.1 + nibOffset.dy)
            ..lineTo(p.dx + 0.1 - nibOffset.dx, p.dy + 0.1 - nibOffset.dy)
            ..close();
          canvas.drawPath(path, calligraphyPaint);
        }
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
  String? fullname;

  DrawingMode _currentMode = DrawingMode.pencil;
  bool _isCalligraphyStyle = true; // Toggle untuk gaya brush
  double _strokeWidth = 20; // Default awal kaligrafi
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
    final renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(details.globalPosition);
    _redoStack.clear();

    setState(() {
      _isDrawing = true;
      _strokes.add(
        Stroke(
          points: [localPosition],
          color: (_currentMode == DrawingMode.pencil)
              ? _pencilColor
              : _eraserColor,
          width: _strokeWidth,
          mode: _currentMode,
          isCalligraphy: _isCalligraphyStyle,
        ),
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
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
          'Bantuan Latihan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4A8C40),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
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
                          'Cara Menggambar',
                          '• Gunakan jari untuk menggambar pada area putih.\n'
                              '• Geser jari untuk membuat garis.\n'
                              '• Ketuk sekali untuk membuat titik.\n'
                              '• Pastikan gambar tetap di dalam kotak.',
                        ),
                        const SizedBox(height: 12),
                        _buildHelpItem(
                          'Mode Pensil & Penghapus',
                          '• Ikon pensil: untuk menulis.\n'
                              '• Ikon penghapus: untuk menghapus.\n'
                              '• Tekan tombol untuk mengganti mode.',
                        ),
                        const SizedBox(height: 12),
                        _buildHelpItem(
                          'Gaya Pena',
                          '• Mode Normal: garis biasa.\n'
                              '• Mode Kaligrafi: garis tebal miring seperti pena Arab.\n'
                              '• Tombol akan mengubah gaya tulisan.\n'
                              '• Saat ganti gaya, otomatis kembali ke mode pensil.',
                        ),
                        const SizedBox(height: 12),
                        _buildHelpItem(
                          'Ketebalan Garis',
                          '• Gunakan slider untuk mengatur tebal tipis garis.\n'
                              '• Cocokkan ketebalan dengan bentuk huruf.',
                        ),
                        const SizedBox(height: 12),
                        _buildHelpItem(
                          'Undo & Redo',
                          '• Undo: membatalkan goresan terakhir.\n'
                              '• Redo: mengembalikan goresan yang dibatalkan.',
                        ),
                        const SizedBox(height: 12),
                        _buildHelpItem(
                          'Bersihkan',
                          '• Menghapus semua gambar di canvas.\n'
                              '• Gunakan jika ingin mengulang dari awal.',
                        ),
                        const SizedBox(height: 12),
                        _buildHelpItem(
                          'Cek Tulisan',
                          '• Tekan tombol "Cek Tulisan" untuk mengecek hasil.\n'
                              '• Sistem akan mengenali huruf hijaiyah.\n'
                              '• Hasil menampilkan huruf dan tingkat akurasi.',
                        ),
                        const SizedBox(height: 12),
                        _buildHelpItem(
                          'Menu',
                          '• Kembali ke halaman utama aplikasi.',
                        ),
                        const SizedBox(height: 12),
                        _buildHelpItem(
                          'Tips',
                          '• Tulis huruf dengan jelas.\n'
                              '• Gunakan gaya kaligrafi untuk hasil lebih bagus.\n'
                              '• Latihan berulang agar semakin akurat.',
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
    },
  );
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

  Future<Uint8List> _capturePngBytes() async {
    final boundary =
        _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
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
      final sorted = preds.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
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
          // Background Image
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
                          const SizedBox(height: 70),
                          // Toolbar
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildRoundButton(
                                    icon: Icons.undo,
                                    onTap: _undo,
                                    tooltip: "Undo"),
                                const SizedBox(width: 8),
                                _buildRoundButton(
                                    icon: Icons.redo,
                                    onTap: _redo,
                                    tooltip: "Redo"),
                                const SizedBox(width: 16),
                                _buildRoundButton(
                                    icon: Icons.delete,
                                    onTap: _clearCanvas,
                                    tooltip: "Bersihkan"),
                                const SizedBox(width: 8),

                                // TOMBOL TOGGLE PENSIL / PENGHAPUS (DIGABUNG)
                                _buildRoundButton(
                                  icon: _currentMode == DrawingMode.pencil
                                      ? Icons.edit
                                      : Icons.cleaning_services,
                                  onTap: () {
                                    setState(() {
                                      _currentMode =
                                          _currentMode == DrawingMode.pencil
                                              ? DrawingMode.eraser
                                              : DrawingMode.pencil;
                                    });
                                  },
                                  isActive: true,
                                  activeColor:
                                      _currentMode == DrawingMode.pencil
                                          ? Colors.blueAccent
                                          : Colors.orangeAccent,
                                  tooltip: _currentMode == DrawingMode.pencil
                                      ? "Mode Tulis"
                                      : "Mode Hapus",
                                ),

                                const SizedBox(width: 8),

                                // TOMBOL SWITCH GAYA PENA (NORMAL / KALIGRAFI)
                                _buildRoundButton(
                                  icon: _isCalligraphyStyle
                                      ? Icons.history_edu
                                      : Icons.brush,
                                  onTap: () {
                                    setState(() {
                                      _isCalligraphyStyle =
                                          !_isCalligraphyStyle;
                                      _currentMode = DrawingMode
                                          .pencil; // Kembali ke pensil saat ganti gaya
                                      _strokeWidth =
                                          _isCalligraphyStyle ? 20.0 : 12.0;
                                    });
                                  },
                                  isActive: true,
                                  activeColor: Colors.purpleAccent,
                                  tooltip: "Gaya Pena",
                                ),
                              ],
                            ),
                          ),
                          // Slider Tebal Brush
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
                                    min: 1.0,
                                    max: 40.0,
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
                                      fontSize: 12),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          // Area Menggambar
                          Center(
                            child: RepaintBoundary(
                              key: _canvasKey,
                              child: Container(
                                width: screenWidth * 0.90,
                                height: screenHeight * 0.48,
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
                          SizedBox(height: screenHeight * 0.03),
                          // Tombol Aksi
                          _buildActionButton(
                            text: 'Cek Tulisan',
                            onTap: _loadingModel ? null : _classifyAndShow,
                            isLoading: _loadingModel,
                          ),
                          const SizedBox(height: 10),
                          _buildActionButton(
                            text: 'Menu',
                            onTap: () => Navigator.popUntil(
                                context, (route) => route.isFirst),
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
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFFC7EFA3),
                      child: Text(
                        '?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A8C40),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bantuan',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      shadows: const [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
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
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilPage()),
                );
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
                          offset: const Offset(0, 2),
                        ),
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
                          color: const Color(0xFF4A8C40),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (fullname != null)
                    Text(
                      fullname!.split(' ').first,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        shadows: const [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      {required String text, VoidCallback? onTap, bool isLoading = false}) {
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
              BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.green))
                : Text(text,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4A8C40))),
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
        child:
            Icon(icon, color: isActive ? Colors.white : Colors.black, size: 20),
      ),
    );
  }
}
