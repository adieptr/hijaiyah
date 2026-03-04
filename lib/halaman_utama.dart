import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../utils/session.dart';
import 'halaman_belajar.dart';
import 'halaman_latihan.dart';
import 'profil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String? fullname;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadUser();

    _audioService.playBackgroundMusic();
  }

  @override
  void dispose() {
    _audioService.stopBackgroundMusic();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _audioService.stopBackgroundMusic();
    } else if (state == AppLifecycleState.resumed) {
      _audioService.playBackgroundMusic();
    }
  }

  Future<void> loadUser() async {
    final userId = await Session.getUser();
    if (userId != null) {
      final user = await DBHelper.instance.getUserById(userId);
      setState(() {
        fullname = user?['fullname'];
      });
    }
  }

  Future<void> _navigateTo(Widget page) async {
    _audioService.stopBackgroundMusic();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    _audioService.playBackgroundMusic();
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
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () => _navigateTo(const ProfilPage()),
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
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          colors: [Color(0xFF6EDC68), Color(0xFFC7EFA3)],
                        ).createShader(bounds);
                      },
                      child: Stack(
                        children: [
                          Text(
                            'Betulyah',
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.15,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 6
                                ..color =
                                    const Color.fromARGB(255, 57, 133, 60),
                            ),
                          ),
                          Text(
                            'Betulyah',
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )),
                  Text(
                    'Belajar Tulis Huruf Hijaiyah',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.04,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  ElevatedButton(
                    onPressed: () => _navigateTo(const BelajarScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC7EFA3),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.15,
                        vertical: screenHeight * 0.025,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(
                            color: Color(0xFF6EDC68), width: 3),
                      ),
                      elevation: 10,
                    ),
                    child: Text(
                      'Belajar',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4A8C40),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  ElevatedButton(
                    onPressed: () => _navigateTo(const HalamanLatihan()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC7EFA3),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.15,
                        vertical: screenHeight * 0.025,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(
                            color: Color(0xFF6EDC68), width: 3),
                      ),
                      elevation: 10,
                    ),
                    child: Text(
                      'Latihan',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4A8C40),
                      ),
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
}
