import 'package:flutter/material.dart';
import 'package:hijaiyah/login.dart';
import 'halaman_utama.dart';
import 'utils/session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Betulyah',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const AuthChecker(),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  Future<bool> _isLoggedIn() async {
    final userId = await Session.getUser();
    return userId != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const HomeScreen();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
