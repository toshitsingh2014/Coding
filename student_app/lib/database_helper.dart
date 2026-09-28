import 'database.dart';

class DatabaseHelper {
  // ==========================================================
  // USER / REGISTER
  // ==========================================================

  static Future<bool> registerUser({
    required String username,
    required String password,
  }) async {
    final db = await DatabaseManager.database;

    try {
      await db.insert(
        'users',
        {
          'username': username,
          'password': password,
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  // ==========================================================
  // USER / LOGIN
  // ==========================================================

  static Future<bool> loginUser({
    required String username,
    required String password,
  }) async {
    final db = await DatabaseManager.database;

    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [
        username,
        password,
      ],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // ==========================================================
  // ADD STUDENT
  // ==========================================================

  static Future<int> addStudent({
    required String name,
    required String course,
  }) async {
    final db = await DatabaseManager.database;

    return db.insert(
      'students',
      {
        'name': name,
        'course': course,
      },
    );
  }

  // ==========================================================
  // GET STUDENTS
  // ==========================================================

  static Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await DatabaseManager.database;

    return db.query(
      'students',
      orderBy: 'id DESC',
    );
  }

  // ==========================================================
  // SEARCH STUDENTS
  // ==========================================================

  static Future<List<Map<String, dynamic>>> searchStudents(String text) async {
    final db = await DatabaseManager.database;

    if (text.trim().isEmpty) {
      return getStudents();
    }

    return db.query(
      'students',
      where: 'name LIKE ? OR course LIKE ?',
      whereArgs: [
        '%${text.trim()}%',
        '%${text.trim()}%',
      ],
      orderBy: 'name ASC',
    );
  }

  // ==========================================================
  // UPDATE STUDENT
  // ==========================================================

  static Future<int> updateStudent({
    required int id,
    required String name,
    required String course,
  }) async {
    final db = await DatabaseManager.database;

    return db.update(
      'students',
      {
        'name': name,
        'course': course,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================================
  // DELETE STUDENT
  // ==========================================================

  static Future<int> deleteStudent(int id) async {
    final db = await DatabaseManager.database;

    return db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
