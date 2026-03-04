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
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            fullname TEXT
          )
        ''');

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

  Future<void> saveProgress(int userId, String huruf, double accuracy) async {
    final db = await database;

    final existing = await db.query(
      'progress',
      where: 'user_id = ? AND huruf = ?',
      whereArgs: [userId, huruf],
    );

    if (existing.isEmpty) {
      await db.insert('progress', {
        'user_id': userId,
        'huruf': huruf,
        'accuracy': accuracy,
      });
    } else {
      await db.update(
        'progress',
        {'accuracy': accuracy},
        where: 'user_id = ? AND huruf = ?',
        whereArgs: [userId, huruf],
      );
    }
  }

  Future<List<Map<String, dynamic>>> getProgress(int userId) async {
    final db = await database;

    return await db.query(
      'progress',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'huruf ASC',
    );
  }
}
