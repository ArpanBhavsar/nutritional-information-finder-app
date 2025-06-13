import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medicine.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'medicine_inventory.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicines(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        strength TEXT NOT NULL,
        imagePath TEXT,
        quantity INTEGER NOT NULL,
        expiryDate INTEGER NOT NULL,
        dosage TEXT,
        usage TEXT,
        sideEffects TEXT
      )
    ''');
  }

  Future<List<Medicine>> getMedicines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('medicines');

    return List.generate(maps.length, (i) {
      return Medicine(
        id: maps[i]['id'],
        name: maps[i]['name'],
        strength: maps[i]['strength'],
        imagePath: maps[i]['imagePath'],
        quantity: maps[i]['quantity'],
        expiryDate: DateTime.fromMillisecondsSinceEpoch(maps[i]['expiryDate']),
        dosage: maps[i]['dosage'],
        usage: maps[i]['usage'],
        sideEffects: maps[i]['sideEffects'],
      );
    });
  }

  Future<Medicine?> getMedicineById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicines',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return Medicine(
        id: map['id'],
        name: map['name'],
        strength: map['strength'],
        imagePath: map['imagePath'],
        quantity: map['quantity'],
        expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate']),
        dosage: map['dosage'],
        usage: map['usage'],
        sideEffects: map['sideEffects'],
      );
    }
    return null;
  }

  Future<void> insertMedicine(Medicine medicine) async {
    final db = await database;
    await db.insert(
      'medicines',
      medicine.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateMedicine(Medicine medicine) async {
    final db = await database;
    await db.update(
      'medicines',
      medicine.toMap(),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
  }

  Future<void> deleteMedicine(String id) async {
    final db = await database;
    await db.delete(
      'medicines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 