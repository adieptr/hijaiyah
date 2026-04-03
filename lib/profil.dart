import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../utils/session.dart';
import '../login.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  Map<String, dynamic>? user;
  List<Map<String, dynamic>> progressList = [];
  bool isLoading = true;

  final List<String> allLetters = [
    'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر', 'ز', 'س', 'ش', 'ص',
    'ض', 'ط', 'ظ', 'ع', 'غ', 'ف', 'ق', 'ك', 'ل', 'م', 'ن', 'و', 'ه', 'ي'
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final userId = await Session.getUser();
    if (userId != null) {
      final userData = await DBHelper.instance.getUserById(userId);
      final progressData = await DBHelper.instance.getProgress(userId);

      final Map<String, Map<String, dynamic>> uniqueProgress = {};
      for (var item in progressData) {
        String huruf = _normalize(item['huruf'].toString());
        uniqueProgress[huruf] = item;
      }

      setState(() {
        user = userData;
        progressList = uniqueProgress.values.toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  String _normalize(String text) {
    return text.toLowerCase().replaceAll("'", "").trim();
  }

  // Dialog Bantuan untuk Halaman Profil
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
            'Informasi Profil',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4A8C40),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem(
                'Progress Belajar:',
                'Menampilkan huruf-huruf yang sudah pernah kamu tulis dan deteksi.',
              ),
              const SizedBox(height: 12),
              _buildHelpItem(
                'Akurasi:',
                'Persentase rata-rata seberapa akurat tulisanmu dibandingkan dengan pola asli.',
              ),
            ],
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

  Future<void> _handleLogout() async {
    await Session.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleLogout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  double calculateAverageAccuracy() {
    if (progressList.isEmpty) return 0.0;
    double total = 0;
    for (var item in progressList) {
      total += (item['accuracy'] as num).toDouble();
    }
    return total / progressList.length;
  }

  bool isLetterLearned(String letter) {
    String currentName = _normalize(_getLetterName(letter));
    return progressList.any((element) => 
      _normalize(element['huruf'].toString()) == currentName
    );
  }

  String _getLetterName(String char) {
    final Map<String, String> nameMap = {
      'ا': 'Alif',
      'ب': "Ba'",
      'ت': "Ta'",
      'ث': "Tsa'",
      'ج': 'Jim',
      'ح': "Ha'", // Underline in UI
      'خ': "Kho'",
      'د': 'Dal',
      'ذ': 'Dzal',
      'ر': "Ro'",
      'ز': 'Zaa',
      'س': 'Sin',
      'ش': 'Syin',
      'ص': 'Shod',
      'ض': 'Dhod',
      'ط': "Tho'",
      'ظ': "Zho'",
      'ع': "'Ain",
      'غ': 'Ghain',
      'ف': "Fa'",
      'ق': 'Qof',
      'ك': 'Kaf',
      'ل': 'Lam',
      'م': 'Mim',
      'ن': 'Nun',
      'و': 'Wawu',
      'ه': "Ha'",
      'ي': "Ya'",
    };
    return nameMap[char] ?? char;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    double avgAccuracy = calculateAverageAccuracy();
    int learnedCount = progressList.length;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.blue),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tombol Bantuan (Ganti teks judul lama)
                      GestureDetector(
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
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFFC7EFA3),
                                child: Text(
                                  '?',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF4A8C40),
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
                      
                      // Tombol Profil & Logout
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'logout') {
                            _showLogoutConfirmation();
                          }
                        },
                        offset: const Offset(0, 70),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout, color: Colors.red, size: 20),
                                SizedBox(width: 10),
                                Text("Logout",
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
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
                                  user?['fullname'] != null
                                      ? user!['fullname'][0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4A8C40),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user?['fullname'] != null
                                  ? user!['fullname'].split(' ').first
                                  : 'User',
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
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(15, 10, 15, 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      border:
                          Border.all(color: Colors.green.shade200, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Progress Belajar\nHuruf Hijaiyah Siswa",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A8C40)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Huruf Dipelajari ($learnedCount/28 Total)",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        Expanded(
                          flex: 4,
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: allLetters.length,
                            itemBuilder: (context, index) {
                              String char = allLetters[index];
                              String name = _getLetterName(char);
                              bool learned = isLetterLearned(char);
                              bool isSpecialHa = (char == 'ح');

                              return Container(
                                decoration: BoxDecoration(
                                  color: learned
                                      ? const Color(0xFFC7EFA3)
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: learned
                                          ? const Color(0xFF6EDC68)
                                          : Colors.grey.shade400,
                                      width: 1.5),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      char,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: learned
                                            ? const Color(0xFF4A8C40)
                                            : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        decoration: isSpecialHa ? TextDecoration.underline : TextDecoration.none,
                                        color: learned
                                            ? const Color(0xFF4A8C40).withOpacity(0.8)
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(thickness: 1.5),
                        const Text(
                          "Persentase Penulisan Benar",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      height: 90,
                                      child: CircularProgressIndicator(
                                        value: avgAccuracy / 100,
                                        strokeWidth: 10,
                                        backgroundColor:
                                            Colors.lightGreen.shade100,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "${avgAccuracy.toStringAsFixed(0)}%",
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Text("Benar",
                                            style: TextStyle(fontSize: 11)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: progressList.isEmpty
                                    ? const Center(
                                        child: Text("Belum ada data",
                                            style: TextStyle(fontSize: 12)))
                                    : Scrollbar(
                                        child: ListView.builder(
                                          padding: const EdgeInsets.only(right: 8),
                                          itemCount: progressList.length,
                                          itemBuilder: (context, idx) {
                                            final item = progressList[idx];
                                            String dbHuruf = item['huruf'].toString();
                                            
                                            // Mencari nama tampilan berdasarkan huruf di DB
                                            String displayName = dbHuruf;
                                            bool isSpecialHaFromDb = false;

                                            // Logika pencocokan nama
                                            for(var char in allLetters) {
                                              if(_normalize(_getLetterName(char)) == _normalize(dbHuruf)) {
                                                displayName = _getLetterName(char);
                                                if(char == 'ح') isSpecialHaFromDb = true;
                                                break;
                                              }
                                            }

                                            return Container(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 4,
                                                  horizontal: 8),
                                              margin: const EdgeInsets.only(
                                                  bottom: 4),
                                              decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withOpacity(0.05),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      "$displayName:",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          decoration: isSpecialHaFromDb ? TextDecoration.underline : TextDecoration.none,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      "${(item['accuracy'] as num).toStringAsFixed(0)}%",
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC7EFA3),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 70, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(
                            color: Color(0xFF6EDC68), width: 3),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      "Menu",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF4A8C40),
                        fontWeight: FontWeight.bold,
                        fontSize: 22.0,
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
}