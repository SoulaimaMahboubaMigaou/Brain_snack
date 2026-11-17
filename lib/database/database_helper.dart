import 'package:brainsnack/models/app_user.dart';
import 'package:brainsnack/models/leaderboard_entry.dart';
import 'package:brainsnack/models/quiz_result.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'brainsnack.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS quiz_results');
          await db.execute('DROP TABLE IF EXISTS scores');
          await db.execute('DROP TABLE IF EXISTS users');
          await _createSchema(db);
        }
      },
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE scores(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        score INTEGER NOT NULL,
        theme TEXT NOT NULL,
        date TEXT NOT NULL,
        total_questions INTEGER NOT NULL,
        correct_answers INTEGER NOT NULL,
        badge TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertUser(AppUser user) async {
    final db = await database;
    return db.insert('users', user.toMap());
  }

  Future<AppUser?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'LOWER(username) = ?',
      whereArgs: [username.toLowerCase()],
      limit: 1,
    );
    if (result.isEmpty) {
      return null;
    }
    return AppUser.fromMap(result.first);
  }

  Future<AppUser?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) {
      return null;
    }
    return AppUser.fromMap(result.first);
  }

  Future<int> insertScore(QuizResult result) async {
    final db = await database;
    return db.insert('scores', result.toMap());
  }

  Future<List<QuizResult>> getScoresForUser(int userId) async {
    final db = await database;
    final result = await db.query(
      'scores',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return result.map(QuizResult.fromMap).toList();
  }

  Future<List<QuizResult>> getLeaderboard({int limit = 5}) async {
    final db = await database;
    final result = await db.query(
      'scores',
      orderBy: 'score DESC, date DESC',
      limit: limit,
    );
    return result.map(QuizResult.fromMap).toList();
  }

  Future<List<LeaderboardEntry>> getAggregatedLeaderboard() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT
        u.id AS user_id,
        u.username AS username,
        SUM(s.score) AS total_score,
        MAX(s.score) AS best_score,
        COUNT(s.id) AS games_played,
        AVG(s.score) AS average_score
      FROM users u
      INNER JOIN scores s ON s.user_id = u.id
      GROUP BY u.id, u.username
      ORDER BY total_score DESC, best_score DESC, games_played DESC, username ASC
    ''');

    return result.asMap().entries.map((entry) {
      return LeaderboardEntry.fromMap({...entry.value, 'rank': entry.key + 1});
    }).toList();
  }

  Future<int> updateScore(QuizResult result) async {
    final db = await database;
    return db.update(
      'scores',
      result.toMap(),
      where: 'id = ?',
      whereArgs: [result.id],
    );
  }

  Future<int> deleteScore(int id) async {
    final db = await database;
    return db.delete('scores', where: 'id = ?', whereArgs: [id]);
  }
}
