import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBHelper {
  static Database? _db;

  // Initialize the database
  static Future<void> init() async {
    if (_db != null) return;
    String dbPath = path.join(await getDatabasesPath(), 'baby_nourish.db');
    _db = await openDatabase(dbPath, version: 2, onCreate: (db, version) async {
      await db.execute(''' 
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        email TEXT UNIQUE,
        password TEXT
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

      // Create the growth_data table to store weight and height history
      await db.execute(''' 
      CREATE TABLE growth_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        baby_id INTEGER,
        month INTEGER,
        weight REAL,
        height REAL,
        FOREIGN KEY(baby_id) REFERENCES baby_profile(id)
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

  // Insert a new user
  static Future<void> insertUser(String username, String email, String password) async {
    await init();
    await _db!.insert(
      'users',
      {'username': username, 'email': email, 'password': password},
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

  // New method to get a single baby profile by ID
  static Future<Map<String, dynamic>?> getBabyProfileById(int id) async {
    await init();
    final List<Map<String, dynamic>> result = await _db!.query(
      'baby_profile',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ✅ New method to get the latest baby profile (or first if only one)
  static Future<Map<String, dynamic>?> getBabyProfile() async {
    await init();
    final List<Map<String, dynamic>> result = await _db!.query(
      'baby_profile',
      orderBy: 'id DESC',
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ✅ New method to get growth data for a specific baby
  static Future<List<Map<String, dynamic>>> getGrowthData(String babyId) async {
    await init();
    final List<Map<String, dynamic>> result = await _db!.query(
      'growth_data',
      where: 'baby_id = ?',
      whereArgs: [babyId],
      orderBy: 'month ASC',  // Or another ordering depending on how you store the growth data
    );
    return result;
  }

  // Insert growth data (e.g., weight and height over time)
  static Future<void> insertGrowthData(int babyId, int month, double weight, double height) async {
    await init();
    await _db!.insert(
      'growth_data',
      {
        'baby_id': babyId,
        'month': month,
        'weight': weight,
        'height': height,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
