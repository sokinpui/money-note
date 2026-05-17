import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'money_note.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        value REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertRecord(Record record) async {
    Database db = await database;
    return await db.insert('records', record.toMap());
  }

  Future<List<Record>> getAllRecords() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('records', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => Record.fromMap(maps[i]));
  }

  Future<List<Record>> getRecentRecords(int limit) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'records',
      orderBy: 'date DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Record.fromMap(maps[i]));
  }

  Future<List<Record>> getRecordsByName(String name) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'records',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Record.fromMap(maps[i]));
  }

  Future<void> deleteRecord(int id) async {
    Database db = await database;
    await db.delete('records', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateRecord(Record record) async {
    Database db = await database;
    await db.update(
      'records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }
}
