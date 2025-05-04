import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class GastosDB {
  static final GastosDB instance = GastosDB._init();
  static Database? _database;
  static const int _currentVersion = 6; // Versión actual de la base de datos

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
      version: _currentVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await _verificarEstructura(db);
  }

  Future<void> _verificarEstructura(Database db) async {
    try {
      // Verificar existencia de tablas clave
      await db.execute('SELECT 1 FROM presupuestos_mensuales LIMIT 1');
      await db.execute('SELECT 1 FROM presupuestos_semanales LIMIT 1');
      await db.execute('SELECT 1 FROM presupuestos_anuales LIMIT 1');
    } catch (e) {
      print('Estructura de base de datos incompleta, recreando...');
      await _crearEstructuraCompleta(db);
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await _crearEstructuraCompleta(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 6) {
      await _crearEstructuraCompleta(db);
    }
  }

  Future<void> _crearEstructuraCompleta(Database db) async {
    await db.transaction((txn) async {
      // Tabla de gastos
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS gastos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titulo TEXT NOT NULL,
          costo REAL NOT NULL,
          categoria TEXT NOT NULL,
          fecha TEXT NOT NULL
        )
      ''');

      // Tabla de configuración
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS configuracion (
          clave TEXT PRIMARY KEY,
          valor TEXT NOT NULL
        )
      ''');

      // Tabla de presupuestos mensuales
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS presupuestos_mensuales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          mes INTEGER NOT NULL,
          anio INTEGER NOT NULL,
          monto REAL NOT NULL,
          UNIQUE(mes, anio)
        )
      ''');

      // Tabla de presupuestos semanales
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS presupuestos_semanales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          semana INTEGER NOT NULL,
          anio INTEGER NOT NULL,
          monto REAL NOT NULL,
          UNIQUE(semana, anio)
        )
      ''');

      // Tabla de presupuestos anuales
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS presupuestos_anuales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          anio INTEGER NOT NULL UNIQUE,
          monto REAL NOT NULL
        )
      ''');
    });
  }

  // ========== MÉTODOS PARA GASTOS ==========
  Future<int> insertarGasto(Map<String, dynamic> gasto) async {
    final db = await instance.database;
    gasto['fecha'] =
        gasto['fecha'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    return await db.insert('gastos', gasto);
  }

  Future<List<Map<String, dynamic>>> obtenerTodosGastos() async {
    final db = await instance.database;
    return await db.query('gastos', orderBy: 'fecha DESC, id DESC');
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

  Future<double> obtenerTotalGastosMesActual() async {
    final db = await instance.database;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final result = await db.rawQuery('''
      SELECT SUM(costo) as total 
      FROM gastos 
      WHERE fecha BETWEEN ? AND ?
    ''', [
      DateFormat('yyyy-MM-dd').format(firstDayOfMonth),
      DateFormat('yyyy-MM-dd').format(lastDayOfMonth)
    ]);

    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> obtenerTotalGastosSemanaActual() async {
    final db = await instance.database;
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));

    final result = await db.rawQuery('''
      SELECT SUM(costo) as total 
      FROM gastos 
      WHERE fecha BETWEEN ? AND ?
    ''', [
      DateFormat('yyyy-MM-dd').format(firstDayOfWeek),
      DateFormat('yyyy-MM-dd').format(lastDayOfWeek)
    ]);

    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> obtenerTotalGastosAnioActual() async {
    final db = await instance.database;
    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final lastDayOfYear = DateTime(now.year, 12, 31);

    final result = await db.rawQuery('''
      SELECT SUM(costo) as total 
      FROM gastos 
      WHERE fecha BETWEEN ? AND ?
    ''', [
      DateFormat('yyyy-MM-dd').format(firstDayOfYear),
      DateFormat('yyyy-MM-dd').format(lastDayOfYear)
    ]);

    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> eliminarGasto(int id) async {
    final db = await instance.database;
    return await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }

  // ========== MÉTODOS PARA PRESUPUESTOS MENSUALES ==========
  Future<void> guardarPresupuestoMensual(double monto) async {
    try {
      final db = await instance.database;
      final now = DateTime.now();
      await db.insert(
        'presupuestos_mensuales',
        {
          'mes': now.month,
          'anio': now.year,
          'monto': monto,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      if (e.toString().contains('no such table')) {
        await _crearEstructuraCompleta(await instance.database);
        await guardarPresupuestoMensual(monto); // Reintentar
      } else {
        rethrow;
      }
    }
  }

  Future<double> obtenerPresupuestoMensual() async {
    try {
      final db = await instance.database;
      final now = DateTime.now();
      final result = await db.query(
        'presupuestos_mensuales',
        where: 'mes = ? AND anio = ?',
        whereArgs: [now.month, now.year],
      );

      if (result.isEmpty) return 0.0;
      return result.first['monto'] as double;
    } catch (e) {
      if (e.toString().contains('no such table')) {
        await _crearEstructuraCompleta(await instance.database);
        return 0.0;
      }
      rethrow;
    }
  }

  Future<void> eliminarPresupuestoMensual() async {
    try {
      final db = await instance.database;
      final now = DateTime.now();
      await db.delete(
        'presupuestos_mensuales',
        where: 'mes = ? AND anio = ?',
        whereArgs: [now.month, now.year],
      );
    } catch (e) {
      if (e.toString().contains('no such table')) {
        await _crearEstructuraCompleta(await instance.database);
      } else {
        rethrow;
      }
    }
  }

  Future<List<Map<String, dynamic>>>
      obtenerHistorialPresupuestosMensuales() async {
    try {
      final db = await instance.database;
      final now = DateTime.now();
      return await db.query(
        'presupuestos_mensuales',
        where: 'anio < ? OR (anio = ? AND mes < ?)',
        whereArgs: [now.year, now.year, now.month],
        orderBy: 'anio DESC, mes DESC',
      );
    } catch (e) {
      if (e.toString().contains('no such table')) {
        await _crearEstructuraCompleta(await instance.database);
        return [];
      }
      rethrow;
    }
  }

  // ========== MÉTODOS PARA PRESUPUESTOS SEMANALES ==========
  Future<void> guardarPresupuestoSemanal(double monto) async {
    try {
      final db = await instance.database;
      final now = DateTime.now();
      final semana = _obtenerNumeroSemana(now);

      await db.insert(
        'presupuestos_semanales',
        {
          'semana': semana,
          'anio': now.year,
          'monto': monto,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      if (e.toString().contains('no such table')) {
        await _crearEstructuraCompleta(await instance.database);
        await guardarPresupuestoSemanal(monto);
      } else {
        rethrow;
      }
    }
  }

  Future<double> obtenerPresupuestoSemanal() async {
    try {
      final db = await instance.database;
      final now = DateTime.now();
      final semana = _obtenerNumeroSemana(now);

      final result = await db.query(
        'presupuestos_semanales',
        where: 'semana = ? AND anio = ?',
        whereArgs: [semana, now.year],
      );

      if (result.isEmpty) return 0.0;
      return result.first['monto'] as double;
    } catch (e) {
      if (e.toString().contains('no such table')) {
        await _crearEstructuraCompleta(await instance.database);
        return 0.0;
      }
      rethrow;
    }
  }

  Future<void> eliminarPresupuestoSemanal() async {
    try {
      final db = await instance.database;
      final now = DateTime.now();
      final semana = _obtenerNumeroSemana(now);

      await db.delete(
        'presupuestos_semanales',
        where: 'semana = ? AND anio = ?',
        whereArgs: [semana, now.year],
      );
    } catch (e) {
      if (e.toString().contains('no such table')) {
        await _crearEstructuraCompleta(await instance.database);
      } else {
        rethrow;
      }
    }
  }

  Future<List<Map<String, dynamic>>>
      obtenerHistorialPresupuestosSemanales() async {
    try {
      final db = await instance.database;
      final now = DateTime.now();
      final semanaActual = _obtenerNumeroSemana(now);

      return await db.query(
        'presupuestos_semanales',
        where: 'anio < ? OR (anio = ? AND semana < ?)',
        whereArgs: [now.year, now.year, semanaActual],
        orderBy: 'anio DESC, semana DESC',
      );
    } catch (e) {
      if (e.toString().contains('no such table')) {
        await _crearEstructuraCompleta(await instance.database);
        return [];
      }
      rethrow;
    }
  }

  // ========== MÉTODOS PARA PRESUPUESTOS ANUALES ==========
  Future<void> guardarPresupuestoAnual(double monto) async {
    try {
      final db = await instance.database;
      final now = DateTime.now();

      await db.insert(
        'presupuestos_anuales',
        {
          'anio': now.year,
          'monto': monto,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      if (e.toString().contains('no such table')) {
        await _crearEstructuraCompleta(await instance.database);
        await guardarPresupuestoAnual(monto);
      } else {
        rethrow;
      }
    }
  }

  Future<double> obtenerPresupuestoAnual() async {
    try {
      final db = await instance.database;
      final now = DateTime.now();

      final result = await db.query(
        'presupuestos_anuales',
        where: 'anio = ?',
        whereArgs: [now.year],
      );

      if (result.isEmpty) return 0.0;
      return result.first['monto'] as double;
    } catch (e) {
      if (e.toString().contains('no such table')) {
        await _crearEstructuraCompleta(await instance.database);
        return 0.0;
      }
      rethrow;
    }
  }

  Future<void> eliminarPresupuestoAnual() async {
    try {
      final db = await instance.database;
      final now = DateTime.now();

      await db.delete(
        'presupuestos_anuales',
        where: 'anio = ?',
        whereArgs: [now.year],
      );
    } catch (e) {
      if (e.toString().contains('no such table')) {
        await _crearEstructuraCompleta(await instance.database);
      } else {
        rethrow;
      }
    }
  }

  Future<List<Map<String, dynamic>>>
      obtenerHistorialPresupuestosAnuales() async {
    try {
      final db = await instance.database;
      final now = DateTime.now();

      return await db.query(
        'presupuestos_anuales',
        where: 'anio < ?',
        whereArgs: [now.year],
        orderBy: 'anio DESC',
      );
    } catch (e) {
      if (e.toString().contains('no such table')) {
        await _crearEstructuraCompleta(await instance.database);
        return [];
      }
      rethrow;
    }
  }

  // ========== FUNCIONES AUXILIARES ==========
  int _obtenerNumeroSemana(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(firstDayOfYear).inDays;
    return ((daysDifference + firstDayOfYear.weekday - 1) / 7).floor() + 1;
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
