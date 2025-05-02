import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class GastosDB {
  static final GastosDB instance = GastosDB._init();
  static Database? _database;

  GastosDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gastos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE gastos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        costo REAL NOT NULL,
        categoria TEXT NOT NULL,
        fecha TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertarGasto(Map<String, dynamic> gasto) async {
    final db = await instance.database;
    // Asegurar que la fecha sea la actual si no se proporciona
    gasto['fecha'] =
        gasto['fecha'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    return await db.insert('gastos', gasto);
  }

  Future<List<Map<String, dynamic>>> obtenerTodosGastos() async {
    final db = await instance.database;
    return await db.query(
      'gastos',
      orderBy: 'fecha DESC, id DESC', // Ordenar por fecha descendente
    );
  }

  Future<List<Map<String, dynamic>>> obtenerUltimosGastos(int limit) async {
    final db = await instance.database;
    return await db.query(
      'gastos',
      orderBy: 'fecha DESC, id DESC',
      limit: limit,
    );
  }

  Future<double> obtenerTotalGastos() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(costo) as total FROM gastos');
    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> eliminarGasto(int id) async {
    final db = await instance.database;
    return await db.delete(
      'gastos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
