import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'student_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            age INTEGER NOT NULL,
            className TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<int> addStudent(
    String name,
    int age,
    String className,
  ) async {
    final db = await database;

    return await db.insert(
      'students',
      {
        'name': name,
        'age': age,
        'className': className,
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await database;

    return await db.query('students');
  }
}
