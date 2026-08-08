import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';

import '../models/transaction.dart';

/// Helper class untuk mengelola database SQLite.
/// Menggunakan Singleton Pattern untuk satu koneksi database.
class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  static const String _databaseName = 'money_notes.db';
  static const int _databaseVersion = 1;
  static const String tableTransactions = 'transactions';

  /// Mendapatkan referensi database.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  /// Membuat dan membuka file database.
  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();

    String path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// Membuat tabel transactions.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTransactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT NOT NULL,
        nominal REAL NOT NULL,
        keterangan TEXT,
        jenis TEXT NOT NULL
      )
    ''');
  }

  // =========================================================
  // CREATE
  // =========================================================

  Future<int> insertTransaction(Transaction transaction) async {
    Database db = await database;

    Map<String, dynamic> row = transaction.toMap();

    row.remove('id');

    return await db.insert(tableTransactions, row);
  }

  // =========================================================
  // READ + FILTER
  // =========================================================

  Future<List<Transaction>> getAllTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? jenis,
  }) async {
    Database db = await database;

    List<String> whereConditions = [];
    List<dynamic> whereArgs = [];

    // Filter tanggal awal
    if (startDate != null) {
      final DateTime start = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );

      whereConditions.add('tanggal >= ?');

      whereArgs.add(start.toIso8601String());
    }

    // Filter tanggal akhir
    if (endDate != null) {
      final DateTime endExclusive = DateTime(
        endDate.year,
        endDate.month,
        endDate.day + 1,
      );

      whereConditions.add('tanggal < ?');

      whereArgs.add(endExclusive.toIso8601String());
    }

    // Filter kategori transaksi
    if (jenis != null && jenis.isNotEmpty && jenis.toLowerCase() != 'semua') {
      whereConditions.add('LOWER(jenis) = ?');

      whereArgs.add(jenis.toLowerCase());
    }

    List<Map<String, dynamic>> maps = await db.query(
      tableTransactions,
      where: whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'tanggal DESC, id DESC',
    );

    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  // =========================================================
  // UPDATE
  // =========================================================

  Future<int> updateTransaction(Transaction transaction) async {
    Database db = await database;

    return await db.update(
      tableTransactions,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<int> deleteTransaction(int id) async {
    Database db = await database;

    return await db.delete(tableTransactions, where: 'id = ?', whereArgs: [id]);
  }

  // =========================================================
  // 5 TRANSAKSI TERBARU
  // =========================================================

  Future<List<Transaction>> getRecentTransactions({int limit = 5}) async {
    Database db = await database;

    List<Map<String, dynamic>> maps = await db.query(
      tableTransactions,
      orderBy: 'tanggal DESC, id DESC',
      limit: limit,
    );

    return maps.map((map) => Transaction.fromMap(map)).toList();
  }
}
