import 'package:myapp/models/impression_model.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Handles SQLite mood diary CRUD with optional Firestore cloud backup.
/// SQLite is the primary (offline-first) source of truth.
class ImpressionRepository {
  static const _dbName = 'mood_log.db';
  static const _tableName = 'mood_entries';
  Database? _database;

  Future<Database> get _db async {
    _database ??= await _openDb();
    return _database!;
  }

  Future<Database> _openDb() async {
    final dbPath = p.join(await getDatabasesPath(), _dbName);
    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, _) => db.execute(
        'CREATE TABLE $_tableName('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'emoticon INTEGER, text TEXT, date TEXT)',
      ),
    );
  }

  /// Returns all mood diary entries, newest first.
  Future<List<ImpressionModel>> getAllEntries() async {
    final db = await _db;
    final rows = await db.query(
      _tableName,
      orderBy: 'id DESC',
    );
    return rows.map((r) => ImpressionModel.fromMap(r)).toList();
  }

  /// Inserts a new diary entry (SQLite + Firestore backup).
  Future<void> addEntry({
    required int emoticon,
    required String text,
    required String date,
  }) async {
    final db = await _db;
    await db.insert(
      _tableName,
      {'emoticon': emoticon, 'text': text, 'date': date},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Non-blocking Firestore cloud backup
    FirestoreService.addImpression(
      emoticon: emoticon,
      text: text,
      date: date,
    );
  }

  /// Deletes an entry by its SQLite [id] and removes from Firestore backup.
  Future<void> deleteEntry(int id) async {
    final db = await _db;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    FirestoreService.deleteImpression(id.toString());
  }

  /// Closes the database connection.
  Future<void> close() async {
    final db = await _db;
    await db.close();
    _database = null;
  }
}
