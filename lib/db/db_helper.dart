import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'hijaiyah.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabel User
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            fullname TEXT
          )
        ''');

        // Tabel Progress (Sekarang menyimpan histori, bukan ditimpa)
        await db.execute('''
          CREATE TABLE progress (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            huruf TEXT,
            accuracy REAL,
            FOREIGN KEY (user_id) REFERENCES users(id)
          )
        ''');
      },
    );
  }

  // --- Fungsi Autentikasi ---

  Future<int> registerUser(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('users', data);
  }

  Future<Map<String, dynamic>?> loginUser(
      String username, String password) async {
    final db = await database;

    final res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    return res.isNotEmpty ? res.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;

    final res = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    return res.isNotEmpty ? res.first : null;
  }

  // --- Fungsi Progres Belajar ---

  // Selalu INSERT data baru agar kita punya histori untuk cek '3 kali berturut-turut'
  Future<void> saveProgress(int userId, String huruf, double accuracy) async {
    final db = await database;
    await db.insert('progress', {
      'user_id': userId,
      'huruf': huruf,
      'accuracy': accuracy,
    });
  }

  // Mengambil N data terakhir untuk satu huruf tertentu (untuk cek mastery di Canvas)
  Future<List<Map<String, dynamic>>> getRecentProgress(int userId, String huruf, {int limit = 3}) async {
    final db = await database;
    return await db.query(
      'progress',
      where: 'user_id = ? AND huruf = ?',
      whereArgs: [userId, huruf],
      orderBy: 'id DESC', // Ambil ID terbesar (paling baru)
      limit: limit,
    );
  }

  // Mengambil progres terbaru saja untuk setiap huruf (untuk ditampilkan di halaman Dashboard/List)
  Future<List<Map<String, dynamic>>> getProgress(int userId) async {
    final db = await database;
    
    // Menggunakan rawQuery untuk mengambil baris terakhir (MAX id) untuk setiap huruf unik
    return await db.rawQuery('''
      SELECT p1.* FROM progress p1
      INNER JOIN (
        SELECT MAX(id) as max_id FROM progress 
        WHERE user_id = ? 
        GROUP BY huruf
      ) p2 ON p1.id = p2.max_id
      ORDER BY p1.huruf ASC
    ''', [userId]);
  }
}