// Stub for sqflite on Flutter Web.
// The real sqflite package uses dart:io which is unavailable on web.
// Files use a conditional import:
//   import 'package:sqflite/sqflite.dart' if (dart.library.html) 'package:myapp/utils/sqflite_stub.dart';
// This stub satisfies the type-checker while kIsWeb guards prevent any actual calls at runtime.

class Database {
  Future<int> insert(String table, Map<String, Object?> values,
      {ConflictAlgorithm? conflictAlgorithm}) async => 0;
  Future<void> execute(String sql) async {}
  Future<int> delete(String table,
      {String? where, List<Object?>? whereArgs}) async => 0;
  Future<int> update(String table, Map<String, Object?> values,
      {String? where,
      List<Object?>? whereArgs,
      ConflictAlgorithm? conflictAlgorithm}) async => 0;
  Future<List<Map<String, dynamic>>> query(String table,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) async => [];
}

class ConflictAlgorithm {
  static const ConflictAlgorithm replace = ConflictAlgorithm._();
  const ConflictAlgorithm._();
}

Future<String> getDatabasesPath() async => '';

Future<Database> openDatabase(String path,
    {int? version, dynamic onCreate}) async => Database();

