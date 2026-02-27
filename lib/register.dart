import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../db/db_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _fullname = TextEditingController();
  bool _obscure = true;

  Future<void> _register() async {
    final username = _username.text.trim();
    final password = _password.text.trim();
    final fullname = _fullname.text.trim();

    if (username.isEmpty || password.isEmpty || fullname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    try {
      await DBHelper.instance.registerUser({
        'username': username,
        'password': password,
        'fullname': fullname,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil, silakan login')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username sudah digunakan')),
      );
    }
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: const Color(0xFF8E8E8E),
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40),
        borderSide: const BorderSide(color: Color(0xFF6EDC68), width: 3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40),
        borderSide:
            const BorderSide(color: Color.fromARGB(255, 19, 182, 19), width: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/bg.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          const SizedBox(height: 200),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                "Betulyah",
                                style: GoogleFonts.fredoka(
                                  fontSize: 70,
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 8
                                    ..color = const Color(0xFF386641),
                                ),
                              ),
                              Text(
                                "Betulyah",
                                style: GoogleFonts.fredoka(
                                  fontSize: 70,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFC7EFA3),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Belajar Tulis Huruf Hijaiyah",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF386641),
                            ),
                          ),
                          const SizedBox(height: 50),
                          TextField(
                            controller: _fullname,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            decoration: _inputStyle("Nama Kamu..."),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            decoration: _inputStyle("Username..."),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _password,
                                  obscureText: _obscure,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  decoration: _inputStyle("Kata Sandi..."),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _obscure = !_obscure),
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC7EFA3),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFF6EDC68),
                                        width: 3),
                                  ),
                                  child: Icon(
                                    _obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: const Color(0xFF386641),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 90),
                          GestureDetector(
                            onTap: _register,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC7EFA3),
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                    color: const Color(0xFF6EDC68), width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "Daftar",
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF4A8C40),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
