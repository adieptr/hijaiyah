import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static const String _keyUserId = 'user_id';

  /// SIMPAN USER ID SAAT LOGIN
  static Future<void> saveUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
  }

  /// AMBIL USER ID (CEK SUDAH LOGIN ATAU BELUM)
  static Future<int?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// HAPUS SESSION SAAT LOGOUT
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }
}
