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
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
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
          backgroundColor: const Color(0xFFC7EFA3),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
            side: const BorderSide(color: Color(0xFF6EDC68), width: 3),
          ),
          shadowColor: Colors.black.withOpacity(0.5),
          elevation: 10,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6EDC68),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                hijaiyahLetter,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A8C40),
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
  _BelajarScreenState createState() => _BelajarScreenState();
}

class _BelajarScreenState extends State<BelajarScreen> {
  final PageController _pageController = PageController();

  final List<List<Map<String, String>>> pages = [
    [
      {'letter': 'ا', 'text': 'Belajar Menulis Huruf Alif'},
      {'letter': 'ب', 'text': 'Belajar Menulis Huruf Ba'},
      {'letter': 'ت', 'text': 'Belajar Menulis Huruf Ta'},
      {'letter': 'ث', 'text': 'Belajar Menulis Huruf Tsa'},
      {'letter': 'ج', 'text': 'Belajar Menulis Huruf Jim'},
    ],
    [
      {'letter': 'ح', 'text': 'Belajar Menulis Huruf Kha'},
      {'letter': 'خ', 'text': 'Belajar Menulis Huruf Kho'},
      {'letter': 'د', 'text': 'Belajar Menulis Huruf Dal'},
      {'letter': 'ذ', 'text': 'Belajar Menulis Huruf Dzal'},
      {'letter': 'ر', 'text': 'Belajar Menulis Huruf Ro'},
    ],
    [
      {'letter': 'ز', 'text': 'Belajar Menulis Huruf Za'},
      {'letter': 'س', 'text': 'Belajar Menulis Huruf Sin'},
      {'letter': 'ش', 'text': 'Belajar Menulis Huruf Syin'},
      {'letter': 'ص', 'text': 'Belajar Menulis Huruf Shod'},
      {'letter': 'ض', 'text': 'Belajar Menulis Huruf Dhod'},
    ],
    [
      {'letter': 'ط', 'text': 'Belajar Menulis Huruf Tho'},
      {'letter': 'ظ', 'text': 'Belajar Menulis Huruf Dzo'},
      {'letter': 'ع', 'text': 'Belajar Menulis Huruf Ain'},
      {'letter': 'غ', 'text': 'Belajar Menulis Huruf Ghain'},
      {'letter': 'ف', 'text': 'Belajar Menulis Huruf Fa'},
    ],
    [
      {'letter': 'ق', 'text': 'Belajar Menulis Huruf Qof'},
      {'letter': 'ك', 'text': 'Belajar Menulis Huruf Kaf'},
      {'letter': 'ل', 'text': 'Belajar Menulis Huruf Lam'},
      {'letter': 'م', 'text': 'Belajar Menulis Huruf Mim'},
      {'letter': 'ن', 'text': 'Belajar Menulis Huruf Nun'},
    ],
    [
      {'letter': 'و', 'text': 'Belajar Menulis Huruf Wawu'},
      {'letter': 'ه', 'text': 'Belajar Menulis Huruf Ha'},
      {'letter': 'ي', 'text': 'Belajar Menulis Huruf Ya'},
    ],
  ];

  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: pages.length,
                      itemBuilder: (context, index) {
                        return ListView(
                          children: pages[index].map((item) {
                            return HijaiyahButton(
                              hijaiyahLetter: item['letter']!,
                              text: item['text']!,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    'Hal ${currentPage + 1} - ${pages.length}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
