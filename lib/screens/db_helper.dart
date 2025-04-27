import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBHelper {
  static Database? _db;

  // Initialize the database
  static Future<void> init() async {
    if (_db != null) return;

    String dbPath = path.join(await getDatabasesPath(), 'baby_nourish.db');
    _db = await openDatabase(
      dbPath,
      version: 2,  // Increment the version number
      onCreate: (db, version) async {
        await db.execute(''' 
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            email TEXT UNIQUE,
            password TEXT,
            user_type TEXT,
            last_active TEXT  -- Add the last_active column
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(''' 
            ALTER TABLE users ADD COLUMN last_active TEXT;
          ''');
        }
      },
    );
  }

  // User Authentication
  static Future<Map<String, dynamic>?> checkCredentials(
      String email, String password, String username) async {
    await init();
    final List<Map<String, dynamic>> result = await _db!.query(
      'users',
      where: 'email = ? AND password = ? AND username = ?',
      whereArgs: [email, password, username],
    );
    return result.isNotEmpty ? result.first : null;
  }


  // Insert an admin (shortcut method)
  static Future<void> insertAdmin({
    required String username,
    required String email,
    required String password,
    required String admin,
  }) async {
    await insertAdmin(
      username: username,
      email: email,
      password: password,
      admin: admin,
    );
  }

  // Insert a user (can be 'user' or 'admin')
  static Future<void> insertUser({
    required String username,
    required String email,
    required String password,
    required String parent,
  }) async {
    await init();
    await _db!.insert(
      'users',
      {
        'username': username,
        'email': email,
        'password': password,
        'user_type': parent,
        'last_active': DateTime.now().toString(), // Set last active time when user is created
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ---------------- Baby Profile CRUD ----------------

  static Future<void> insertBabyProfile(
      String name, int age, double weight, double height) async {
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

  static Future<void> updateBabyProfile(
      int id, String name, int age, double weight, double height) async {
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
    final result = await _db!.query(
      'baby_profile',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ---------------- Parent (User) Management ----------------

  static Future<List<Map<String, dynamic>>> getParents() async {
    await init();
    return await _db!.query(
      'users',
      where: 'user_type = ?',
      whereArgs: ['parent'],
    );
  }

  static Future<void> updateParent(int id, String username, String email) async {
    await init();
    await _db!.update(
      'users',
      {
        'username': username,
        'email': email,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Method to update the last active time of the parent
  static Future<void> updateLastActive(int parentId) async {
    await init();
    await _db!.update(
      'users',
      {'last_active': DateTime.now().toString()},
      where: 'id = ?',
      whereArgs: [parentId],
    );
  }

  static Future<void> deleteParent(int id) async {
    await init();
    await _db!.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Add this method to get the total number of parents
  static Future<int> getTotalParents() async {
    await init();
    final result = await _db!.rawQuery(
      'SELECT COUNT(*) as total FROM users WHERE user_type = ?',
      ['parent'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
