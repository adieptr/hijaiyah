import 'package:flutter/material.dart';

class HalamanBelajar2 extends StatelessWidget {
  final String hijaiyahLetter;
  final String description;

  const HalamanBelajar2({
    super.key,
    required this.hijaiyahLetter,
    required this.description,
  });

  String getGifPath() {
    final Map<String, String> gifMap = {
      'ا': 'alif.gif',
      'ب': 'ba.gif',
      'ت': 'ta.gif',
      'ث': 'tsa.gif',
      'ج': 'jim.gif',
      'ح': 'kha.gif',
      'خ': 'kho.gif',
      'د': 'dal.gif',
      'ذ': 'dzal.gif',
      'ر': 'ro.gif',
      'ز': 'za.gif',
      'س': 'sin.gif',
      'ش': 'syin.gif',
      'ص': 'shod.gif',
      'ض': 'dhod.gif',
      'ط': 'tho.gif',
      'ظ': 'dzo.gif',
      'ع': 'ain.gif',
      'غ': 'ghain.gif',
      'ف': 'fa.gif',
      'ق': 'qof.gif',
      'ك': 'kaf.gif',
      'ل': 'lam.gif',
      'م': 'mim.gif',
      'ن': 'nun.gif',
      'و': 'wawu.gif',
      'ه': 'ha.gif',
      'ي': 'ya.gif',
    };

    return 'assets/images/hijaiyah_gif/${gifMap[hijaiyahLetter] ?? 'alif.gif'}';
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
                  Container(
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.45,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        getGifPath(),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC7EFA3),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.15,
                        vertical: screenHeight * 0.025,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: const BorderSide(
                            color: Color(0xFF6EDC68), width: 3),
                      ),
                      shadowColor: Colors.black.withOpacity(0.5),
                      elevation: 10,
                    ),
                    child: Text(
                      'Menu',
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
          ),
        ],
      ),
    );
  }
}
