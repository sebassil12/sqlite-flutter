import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'computadora.dart';
 
class DBHelper {
  static Database? _database;
 
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }
 
  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'computadoras.db');
 
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE computadoras(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipo TEXT,
            marca TEXT,
            cpu TEXT,
            ram TEXT,
            hdd TEXT
          )
        ''');
      },
    );
  }
 
  static Future<int> insertComputadora(Computadora compu) async {
    final db = await database;
    return await db.insert('computadoras', compu.toMap());
  }
 
  static Future<List<Computadora>> getComputadoras() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('computadoras');
    return List.generate(maps.length, (i) => Computadora.fromMap(maps[i]));
  }
 
  static Future<int> updateComputadora(Computadora compu) async {
    final db = await database;
    return await db.update('computadoras', compu.toMap(), where: 'id = ?', whereArgs: [compu.id]);
  }
 
  static Future<int> deleteComputadora(int id) async {
    final db = await database;
    return await db.delete('computadoras', where: 'id = ?', whereArgs: [id]);
  }
}
