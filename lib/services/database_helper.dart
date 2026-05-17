import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/record.dart';
import '../models/category.dart';

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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        iconName TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
    await _seedCategories(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          iconName TEXT NOT NULL,
          type TEXT NOT NULL
        )
      ''');
      await _seedCategories(db);
    }
  }

  Future<void> _seedCategories(Database db) async {
    final List<Map<String, dynamic>> expense = [
      {'name': 'Other', 'iconName': 'category', 'type': 'Expense'},
      {'name': 'GYM', 'iconName': 'fitness_center', 'type': 'Expense'},
      {'name': '手办', 'iconName': 'toys', 'type': 'Expense'},
      {'name': '书', 'iconName': 'book', 'type': 'Expense'},
      {'name': '交通', 'iconName': 'directions_bus', 'type': 'Expense'},
      {'name': '衣服', 'iconName': 'checkroom', 'type': 'Expense'},
      {'name': '食物', 'iconName': 'restaurant', 'type': 'Expense'},
      {'name': '涩图', 'iconName': 'photo', 'type': 'Expense'},
      {'name': '话费', 'iconName': 'phone_android', 'type': 'Expense'},
      {'name': '电影', 'iconName': 'movie', 'type': 'Expense'},
      {'name': '电子设备', 'iconName': 'devices', 'type': 'Expense'},
    ];

    final List<Map<String, dynamic>> income = [
      {'name': 'Other', 'iconName': 'category', 'type': 'Income'},
      {'name': '人工', 'iconName': 'payments', 'type': 'Income'},
    ];

    for (var cat in [...expense, ...income]) {
      await db.insert('categories', cat);
    }
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

  Future<int> insertCategory(Category category) async {
    Database db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getAllCategories() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }
}
