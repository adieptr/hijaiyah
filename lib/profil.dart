import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../utils/session.dart';
import '../login.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  Map<String, dynamic>? user;
  List<Map<String, dynamic>> progressList = [];
  bool isLoading = true;

  // Daftar lengkap 28 huruf hijaiyah untuk grid
  final List<String> allLetters = [
    'ا',
    'ب',
    'ت',
    'ث',
    'ج',
    'ح',
    'خ',
    'د',
    'ذ',
    'ر',
    'ز',
    'س',
    'ش',
    'ص',
    'ض',
    'ط',
    'ظ',
    'ع',
    'غ',
    'ف',
    'ق',
    'ك',
    'ل',
    'م',
    'ن',
    'و',
    'ه',
    'ي'
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
      setState(() {
        user = userData;
        progressList = progressData;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
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

  // Dialog konfirmasi logout
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
    return progressList.any((element) =>
        element['huruf'].toString().toLowerCase() ==
        _getLetterName(letter).toLowerCase());
  }

  String _getLetterName(String char) {
    final Map<String, String> nameMap = {
      'ا': 'alif',
      'ب': 'ba',
      'ت': 'ta',
      'ث': 'tsa',
      'ج': 'jim',
      'ح': 'kha',
      'خ': 'kho',
      'د': 'dal',
      'ذ': 'dzal',
      'ر': 'ro',
      'ز': 'za',
      'س': 'sin',
      'ش': 'syin',
      'ص': 'shod',
      'ض': 'dhod',
      'ط': 'tho',
      'ظ': 'dzo',
      'ع': 'ain',
      'غ': 'ghain',
      'ف': 'fa',
      'ق': 'qof',
      'ك': 'kaf',
      'ل': 'lam',
      'م': 'mim',
      'ن': 'nun',
      'و': 'wawu',
      'ه': 'ha',
      'ي': 'ya',
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Apa Yang Sudah Kamu\nPelajari?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Menu Profil dengan Popup Logout
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'logout') {
                            _showLogoutConfirmation();
                          }
                        },
                        offset: const Offset(0, 60),
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
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.lightGreenAccent,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            Text(
                              user?['username'] ?? 'User',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
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
                          flex: 3,
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            itemCount: allLetters.length,
                            itemBuilder: (context, index) {
                              bool learned = isLetterLearned(allLetters[index]);
                              return Container(
                                decoration: BoxDecoration(
                                  color: learned
                                      ? const Color(0xFFC7EFA3)
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: learned
                                          ? const Color(0xFF6EDC68)
                                          : Colors.grey.shade400,
                                      width: 1.5),
                                ),
                                child: Center(
                                  child: Text(
                                    allLetters[index],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: learned
                                          ? const Color(0xFF4A8C40)
                                          : Colors.grey,
                                    ),
                                  ),
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
                                      width: 100,
                                      height: 100,
                                      child: CircularProgressIndicator(
                                        value: avgAccuracy / 100,
                                        strokeWidth: 12,
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
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Text("Benar",
                                            style: TextStyle(fontSize: 12)),
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
                                    : ListView.builder(
                                        itemCount: progressList.length > 5
                                            ? 5
                                            : progressList.length,
                                        itemBuilder: (context, idx) {
                                          final item = progressList[idx];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    "${item['huruf'].toString().toUpperCase()}:",
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    "${(item['accuracy'] as num).toStringAsFixed(0)}%",
                                                    style: const TextStyle(
                                                        fontSize: 12)),
                                              ],
                                            ),
                                          );
                                        },
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
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC7EFA3),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(
                            color: Color(0xFF6EDC68), width: 3),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      "Kembali ke\nMenu Utama",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF4A8C40),
                          fontWeight: FontWeight.bold),
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
