import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/medicine.dart';
import '../models/medicine_reminder.dart';

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
    return await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  // This runs only if the database does not exist
  Future _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  // This runs if the database exists but the version is higher
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE reminders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          medicineId TEXT NOT NULL,
          medicineName TEXT NOT NULL,
          time TEXT NOT NULL,
          days TEXT NOT NULL,
          FOREIGN KEY (medicineId) REFERENCES medicines (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future _createTables(Database db) async {
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
    await db.execute('''
        CREATE TABLE reminders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          medicineId TEXT NOT NULL,
          medicineName TEXT NOT NULL,
          time TEXT NOT NULL,
          days TEXT NOT NULL,
          FOREIGN KEY (medicineId) REFERENCES medicines (id) ON DELETE CASCADE
        )
      ''');
  }

  Future<List<Medicine>> getMedicines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('medicines');
    return List.generate(maps.length, (i) => Medicine.fromMap(maps[i]));
  }

  Future<Medicine?> getMedicineById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('medicines', where: 'id = ?', whereArgs: [id]);

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
    await db.insert('medicines', medicine.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateMedicine(Medicine medicine) async {
    final db = await database;
    await db.update('medicines', medicine.toMap(), where: 'id = ?', whereArgs: [medicine.id]);
  }

  Future<void> deleteMedicine(String id) async {
    final db = await database;
    await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
  }

  // --- Reminder Methods (new) ---
  Future<int> insertReminder(MedicineReminder reminder) async {
    final db = await database;
    // The database returns the id of the inserted row
    return await db.insert('reminders', reminder.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<MedicineReminder>> getReminders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reminders', orderBy: 'id DESC');
    return List.generate(maps.length, (i) {
      return MedicineReminder.fromMap(maps[i]);
    });
  }

  Future<void> updateReminder(MedicineReminder reminder) async {
    final db = await database;
    await db.update('reminders', reminder.toMap(), where: 'id = ?', whereArgs: [reminder.id]);
  }

  Future<void> deleteReminder(int id) async {
    final db = await database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }
}
