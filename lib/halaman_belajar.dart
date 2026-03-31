import 'package:flutter/material.dart';
import 'halaman_belajar2.dart';

class HijaiyahButton extends StatelessWidget {
  final String hijaiyahLetter;
  final String text;

  const HijaiyahButton({
    super.key,
    required this.hijaiyahLetter,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HalamanBelajar2(
                hijaiyahLetter: hijaiyahLetter,
                description: text,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC5E99B),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: const BorderSide(color: Color(0xFF8BC34A), width: 2.5),
          ),
          elevation: 6,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6EDC68),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                hijaiyahLetter,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A7C44),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BelajarScreen extends StatefulWidget {
  const BelajarScreen({super.key});

  @override
  State<BelajarScreen> createState() => _BelajarScreenState();
}

class _BelajarScreenState extends State<BelajarScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<List<Map<String, String>>> pages = [
    [
      {'letter': 'ا', 'text': 'Belajar Huruf Alif'},
      {'letter': 'ب', 'text': 'Belajar Huruf Ba'},
      {'letter': 'ت', 'text': 'Belajar Huruf Ta'},
      {'letter': 'ث', 'text': 'Belajar Huruf Tsa'},
      {'letter': 'ج', 'text': 'Belajar Huruf Jim'},
    ],
    [
      {'letter': 'ح', 'text': 'Belajar Huruf Kha'},
      {'letter': 'خ', 'text': 'Belajar Huruf Kho'},
      {'letter': 'د', 'text': 'Belajar Huruf Dal'},
      {'letter': 'ذ', 'text': 'Belajar Huruf Dzal'},
      {'letter': 'ر', 'text': 'Belajar Huruf Ro'},
    ],
    [
      {'letter': 'ز', 'text': 'Belajar Huruf Za'},
      {'letter': 'س', 'text': 'Belajar Huruf Sin'},
      {'letter': 'ش', 'text': 'Belajar Huruf Syin'},
      {'letter': 'ص', 'text': 'Belajar Huruf Shod'},
      {'letter': 'ض', 'text': 'Belajar Huruf Dhod'},
    ],
    [
      {'letter': 'ط', 'text': 'Belajar Huruf Tho'},
      {'letter': 'ظ', 'text': 'Belajar Huruf Dzo'},
      {'letter': 'ع', 'text': 'Belajar Huruf Ain'},
      {'letter': 'غ', 'text': 'Belajar Huruf Ghain'},
      {'letter': 'ف', 'text': 'Belajar Huruf Fa'},
    ],
    [
      {'letter': 'ق', 'text': 'Belajar Huruf Qof'},
      {'letter': 'ك', 'text': 'Belajar Huruf Kaf'},
      {'letter': 'ل', 'text': 'Belajar Huruf Lam'},
      {'letter': 'م', 'text': 'Belajar Huruf Mim'},
      {'letter': 'ن', 'text': 'Belajar Huruf Nun'},
    ],
    [
      {'letter': 'و', 'text': 'Belajar Huruf Wawu'},
      {'letter': 'ه', 'text': 'Belajar Huruf Ha'},
      {'letter': 'ي', 'text': 'Belajar Huruf Ya'},
    ],
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),
          Column(
            children: [
              const SizedBox(height: 60),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      itemCount: pages[index].length,
                      itemBuilder: (context, i) {
                        return HijaiyahButton(
                          hijaiyahLetter: pages[index][i]['letter']!,
                          text: pages[index][i]['text']!,
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 60),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildArrowButton(
                          icon: Icons.arrow_back_ios_new,
                          onPressed: () {
                            if (currentPage > 0) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 25),
                        Text(
                          'Hal ${currentPage + 1} / ${pages.length}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 25),
                        _buildArrowButton(
                          icon: Icons.arrow_forward_ios,
                          onPressed: () {
                            if (currentPage < pages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: screenWidth * 0.55,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC5E99B),
                          foregroundColor: const Color(0xFF4A7C44),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35),
                            side: const BorderSide(
                              color: Color(0xFF8BC34A),
                              width: 3,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Menu',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFC5E99B),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF8BC34A), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Icon(icon, color: const Color(0xFF4A7C44), size: 22),
      ),
    );
  }
}
