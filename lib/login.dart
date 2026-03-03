import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../db/db_helper.dart';
import '../utils/session.dart';
import 'halaman_utama.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscure = true;

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan password wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final user = await DBHelper.instance.loginUser(username, password);
    setState(() => _isLoading = false);

    if (user != null) {
      await Session.saveUser(user['id']);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau password salah')),
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
        borderSide: const BorderSide(color: Color(0xFF6EDC68), width: 2),
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
                              ..color = const Color(0xFF3A7537),
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
                    const SizedBox(height: 40),
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      decoration: _inputStyle("Username..."),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _passwordController,
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
                      onTap: _isLoading ? null : _login,
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
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF386641),
                                  ),
                                )
                              : Text(
                                  "Masuk",
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterPage()),
                        );
                      },
                      child: Text(
                        'Belum punya akun? Daftar',
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
