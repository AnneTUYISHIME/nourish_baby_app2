import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBHelper {
  static Database? _db;

  // Initialize the database
  static Future<void> init() async {
    if (_db != null) return;
    String dbPath = path.join(await getDatabasesPath(), 'baby_nourish.db');
    _db = await openDatabase(dbPath, version: 1, onCreate: (db, version) async {
      await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        email TEXT UNIQUE,
        password TEXT,
        user_type TEXT
      )
      ''');

      await db.execute('''
      CREATE TABLE baby_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        age INTEGER,
        lastFeeding TEXT,
        weight REAL,
        height REAL
      )
      ''');
    });
  }

  // Check if credentials match (email, username, and password)
  static Future<bool> checkCredentials(String email, String password, String username) async {
    await init();
    final List<Map<String, dynamic>> maps = await _db!.query(
      'users',
      where: 'email = ? AND password = ? AND username = ?',
      whereArgs: [email, password, username],
    );
    return maps.isNotEmpty;
  }

  // Insert a normal user (user_type = "user")
  static Future<void> insertUser({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    await init();
    await _db!.insert(
      'users',
      {
        'username': username,
        'email': email,
        'password': password,
        'user_type': 'user', // Role set to 'user'
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert an admin (user_type = "admin")
  static Future<void> insertAdmin({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    await init();
    await _db!.insert(
      'users',
      {
        'username': username,
        'email': email,
        'password': password,
        'user_type': 'admin', // Role set to 'admin'
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Baby Profile CRUD
  static Future<void> insertBabyProfile(String name, int age, double weight, double height) async {
    await init();
    await _db!.insert(
      'baby_profile',
      {
        'name': name,
        'age': age,
        'weight': weight,
        'height': height,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<List<Map<String, dynamic>>> getBabyProfiles() async {
    await init();
    return await _db!.query('baby_profile');
  }

  static Future<void> updateBabyProfile(int id, String name, int age, double weight, double height) async {
    await init();
    await _db!.update(
      'baby_profile',
      {
        'name': name,
        'age': age,
        'weight': weight,
        'height': height,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteBabyProfile(int id) async {
    await init();
    await _db!.delete(
      'baby_profile',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<Map<String, dynamic>?> getBabyProfileById(int id) async {
    await init();
    final List<Map<String, dynamic>> result = await _db!.query(
      'baby_profile',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // 👇 This method deletes the whole database file (for dev use only)
  static Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, 'baby_nourish.db'); // match the name used above
    await deleteDatabase(fullPath);
    print("🔄 Database deleted successfully.");
  }
}
