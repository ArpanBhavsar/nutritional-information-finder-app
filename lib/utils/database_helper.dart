import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medicine.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medicines.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE medicines (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  strength TEXT,
  imagePath TEXT,
  quantity INTEGER,
  expiryDate TEXT NOT NULL,
  dosageInformation TEXT,
  usageInformation TEXT,
  sideEffects TEXT
)
''');
  }

  Future<int> addMedicine(Medicine medicine) async {
    final db = await instance.database;
    return await db.insert('medicines', medicine.toMap());
  }

  Future<List<Medicine>> getMedicines() async {
    final db = await instance.database;
    final maps = await db.query('medicines', orderBy: 'expiryDate ASC');

    if (maps.isNotEmpty) {
      return maps.map((json) => Medicine.fromMap(json)).toList();
    } else {
      return [];
    }
  }

  Future<int> updateMedicine(Medicine medicine) async {
    final db = await instance.database;
    return await db.update(
      'medicines',
      medicine.toMap(),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
  }

  Future<int> deleteMedicine(String id) async {
    final db = await instance.database;
    return await db.delete(
      'medicines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
