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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil, silakan login')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
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
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide:
            const BorderSide(color: Color(0xFF6EDC68), width: 2), // Diperhalus
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFF13B613), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          "Betulyah",
                          style: GoogleFonts.fredoka(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 4
                              ..color = const Color(0xFF386641),
                          ),
                        ),
                        Text(
                          "Betulyah",
                          style: GoogleFonts.fredoka(
                            fontSize: 48,
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
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF386641),
                      ),
                    ),
                    const SizedBox(height: 35),
                    TextField(
                      controller: _fullname,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      decoration: _inputStyle("Nama Kamu..."),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _username,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      decoration: _inputStyle("Username..."),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _password,
                            obscureText: _obscure,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                            decoration: _inputStyle("Kata Sandi..."),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _obscure = !_obscure),
                          child: Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC7EFA3),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF6EDC68),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20,
                              color: const Color(0xFF386641),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: _register,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC7EFA3),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: const Color(0xFF6EDC68), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Daftar",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF4A8C40),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Sudah punya akun? Masuk',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF386641),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
