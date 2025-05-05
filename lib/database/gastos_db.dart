import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:MyCash/componentes/event_bus.dart';

/// Clase singleton para manejar la base de datos de la aplicación
/// 
/// Responsabilidades:
/// - Creación y mantenimiento de la estructura de la base de datos
/// - Operaciones CRUD para gastos
/// - Gestión de presupuestos (mensuales, semanales, anuales)
/// - Configuración de la aplicación
class GastosDB {
  // =============================================
  // 1. PATRÓN SINGLETON Y CONFIGURACIÓN INICIAL
  // =============================================
  
  /// Instancia única de la clase (patrón Singleton)
  static final GastosDB instance = GastosDB._init();
  
  /// Referencia a la base de datos
  static Database? _database;
  
  /// Versión actual de la base de datos (incrementar al hacer cambios)
  static const int _currentVersion = 8;

  /// Constructor privado para el patrón Singleton
  GastosDB._init();

  // =============================================
  // 2. MANEJO DE LA CONEXIÓN A LA BASE DE DATOS
  // =============================================

  /// Getter para acceder a la base de datos
  /// 
  /// Si la base de datos no está inicializada, la crea
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gastos.db');
    return _database!;
  }

  /// Inicializa la base de datos en la ruta especificada
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _currentVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // =============================================
  // 3. CREACIÓN Y ACTUALIZACIÓN DE LA ESTRUCTURA
  // =============================================

  /// Crea la estructura inicial de la base de datos
  Future<void> _createDB(Database db, int version) async {
    await _crearEstructuraCompleta(db);
  }

  /// Maneja la actualización de la base de datos cuando cambia la versión
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 8) {
      // En versiones anteriores a la 8, recreamos completamente la base de datos
      await db.execute('DROP TABLE IF EXISTS gastos');
      await db.execute('DROP TABLE IF EXISTS presupuestos_mensuales');
      await db.execute('DROP TABLE IF EXISTS presupuestos_semanales');
      await db.execute('DROP TABLE IF EXISTS presupuestos_anuales');
      await db.execute('DROP TABLE IF EXISTS configuracion');
      await _crearEstructuraCompleta(db);
    }
  }

  /// Crea todas las tablas necesarias en una transacción
  Future<void> _crearEstructuraCompleta(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE gastos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titulo TEXT NOT NULL,
          descripcion TEXT,
          costo REAL NOT NULL,
          categoria TEXT NOT NULL,
          fecha TEXT NOT NULL
        )
      ''');

      await txn.execute('''
        CREATE TABLE presupuestos_mensuales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          mes INTEGER NOT NULL,
          anio INTEGER NOT NULL,
          monto REAL NOT NULL,
          UNIQUE(mes, anio)
        )
      ''');

      await txn.execute('''
        CREATE TABLE presupuestos_semanales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          semana INTEGER NOT NULL,
          anio INTEGER NOT NULL,
          monto REAL NOT NULL,
          UNIQUE(semana, anio)
        )
      ''');

      await txn.execute('''
        CREATE TABLE presupuestos_anuales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          anio INTEGER NOT NULL UNIQUE,
          monto REAL NOT NULL
        )
      ''');

      await txn.execute('''
        CREATE TABLE configuracion (
          clave TEXT PRIMARY KEY,
          valor TEXT NOT NULL
        )
      ''');
    });
  }

  /// Verifica y crea las tablas si no existen
  /// 
  /// Útil para asegurar la estructura después de actualizaciones
  Future<void> asegurarEstructura() async {
    final db = await database;
    
    await _verificarOCrearTabla(db, 'gastos', '''
      CREATE TABLE gastos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        costo REAL NOT NULL,
        categoria TEXT NOT NULL,
        fecha TEXT NOT NULL
      )
    ''');

    await _verificarOCrearTabla(db, 'presupuestos_mensuales', '''
      CREATE TABLE presupuestos_mensuales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mes INTEGER NOT NULL,
        anio INTEGER NOT NULL,
        monto REAL NOT NULL,
        UNIQUE(mes, anio)
      )
    ''');

    await _verificarOCrearTabla(db, 'presupuestos_semanales', '''
      CREATE TABLE presupuestos_semanales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        semana INTEGER NOT NULL,
        anio INTEGER NOT NULL,
        monto REAL NOT NULL,
        UNIQUE(semana, anio)
      )
    ''');

    await _verificarOCrearTabla(db, 'presupuestos_anuales', '''
      CREATE TABLE presupuestos_anuales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        anio INTEGER NOT NULL UNIQUE,
        monto REAL NOT NULL
      )
    ''');

    await _verificarOCrearTabla(db, 'configuracion', '''
      CREATE TABLE configuracion (
        clave TEXT PRIMARY KEY,
        valor TEXT NOT NULL
      )
    ''');
  }

  /// Verifica si una tabla existe y la crea si no existe
  Future<void> _verificarOCrearTabla(
      Database db, String tableName, String createSql) async {
    final tableExists = await _tablaExiste(db, tableName);
    if (!tableExists) {
      await db.execute(createSql);
    }
  }

  /// Comprueba si una tabla existe en la base de datos
  Future<bool> _tablaExiste(Database db, String tableName) async {
    try {
      final result = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'");
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // =============================================
  // 4. OPERACIONES CRUD PARA GASTOS
  // =============================================

  /// Inserta un nuevo gasto en la base de datos
  /// 
  /// Si no se proporciona fecha, usa la fecha actual
  Future<int> insertarGasto(Map<String, dynamic> gasto) async {
    final db = await database;
    gasto['fecha'] =
        gasto['fecha'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    return await db.insert('gastos', gasto);
  }

  /// Actualiza un gasto existente
  Future<int> actualizarGasto(Map<String, dynamic> gasto) async {
    final db = await database;
    return await db.update(
      'gastos',
      gasto,
      where: 'id = ?',
      whereArgs: [gasto['id']],
    );
  }

  /// Obtiene todos los gastos ordenados por fecha descendente
  Future<List<Map<String, dynamic>>> obtenerTodosGastos() async {
    final db = await database;
    return await db.query('gastos', orderBy: 'fecha DESC, id DESC');
  }

  /// Obtiene los últimos N gastos ordenados por fecha descendente
  Future<List<Map<String, dynamic>>> obtenerUltimosGastos(int limit) async {
    final db = await database;
    return await db.query(
      'gastos',
      orderBy: 'fecha DESC, id DESC',
      limit: limit,
    );
  }

  /// Calcula el total de todos los gastos registrados
  Future<double> obtenerTotalGastos() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(costo) as total FROM gastos');
    return result.first['total'] as double? ?? 0.0;
  }

  /// Calcula el total de gastos del mes actual
  Future<double> obtenerTotalGastosMesActual() async {
    final db = await database;
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

  /// Calcula el total de gastos de la semana actual
  Future<double> obtenerTotalGastosSemanaActual() async {
    final db = await database;
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

  /// Calcula el total de gastos del año actual
  Future<double> obtenerTotalGastosAnioActual() async {
    final db = await database;
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

  /// Elimina un gasto por su ID
  Future<int> eliminarGasto(int id) async {
    final db = await database;
    return await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }

  // =============================================
  // 5. OPERACIONES PARA PRESUPUESTOS MENSUALES
  // =============================================

  /// Guarda o actualiza el presupuesto mensual actual
  Future<void> guardarPresupuestoMensual(double monto) async {
    final db = await database;
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
  }

  /// Obtiene el presupuesto mensual actual
  Future<double> obtenerPresupuestoMensual() async {
    final db = await database;
    final now = DateTime.now();
    final result = await db.query(
      'presupuestos_mensuales',
      where: 'mes = ? AND anio = ?',
      whereArgs: [now.month, now.year],
    );

    if (result.isEmpty) return 0.0;
    return result.first['monto'] as double;
  }

  /// Elimina el presupuesto mensual actual
  Future<void> eliminarPresupuestoMensual() async {
    final db = await database;
    final now = DateTime.now();
    await db.delete(
      'presupuestos_mensuales',
      where: 'mes = ? AND anio = ?',
      whereArgs: [now.month, now.year],
    );
  }

  /// Obtiene el historial de presupuestos mensuales anteriores al actual
  Future<List<Map<String, dynamic>>>
      obtenerHistorialPresupuestosMensuales() async {
    final db = await database;
    final now = DateTime.now();
    return await db.query(
      'presupuestos_mensuales',
      where: 'anio < ? OR (anio = ? AND mes < ?)',
      whereArgs: [now.year, now.year, now.month],
      orderBy: 'anio DESC, mes DESC',
    );
  }

  // =============================================
  // 6. OPERACIONES PARA PRESUPUESTOS SEMANALES
  // =============================================

  /// Guarda o actualiza el presupuesto semanal actual
  Future<void> guardarPresupuestoSemanal(double monto) async {
    final db = await database;
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
  }

  /// Obtiene el presupuesto semanal actual
  Future<double> obtenerPresupuestoSemanal() async {
    final db = await database;
    final now = DateTime.now();
    final semana = _obtenerNumeroSemana(now);

    final result = await db.query(
      'presupuestos_semanales',
      where: 'semana = ? AND anio = ?',
      whereArgs: [semana, now.year],
    );

    if (result.isEmpty) return 0.0;
    return result.first['monto'] as double;
  }

  /// Elimina el presupuesto semanal actual
  Future<void> eliminarPresupuestoSemanal() async {
    final db = await database;
    final now = DateTime.now();
    final semana = _obtenerNumeroSemana(now);

    await db.delete(
      'presupuestos_semanales',
      where: 'semana = ? AND anio = ?',
      whereArgs: [semana, now.year],
    );
  }

  /// Obtiene el historial de presupuestos semanales anteriores al actual
  Future<List<Map<String, dynamic>>>
      obtenerHistorialPresupuestosSemanales() async {
    final db = await database;
    final now = DateTime.now();
    final semanaActual = _obtenerNumeroSemana(now);

    return await db.query(
      'presupuestos_semanales',
      where: 'anio < ? OR (anio = ? AND semana < ?)',
      whereArgs: [now.year, now.year, semanaActual],
      orderBy: 'anio DESC, semana DESC',
    );
  }

  // =============================================
  // 7. OPERACIONES PARA PRESUPUESTOS ANUALES
  // =============================================

  /// Guarda o actualiza el presupuesto anual actual
  Future<void> guardarPresupuestoAnual(double monto) async {
    final db = await database;
    final now = DateTime.now();

    await db.insert(
      'presupuestos_anuales',
      {
        'anio': now.year,
        'monto': monto,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene el presupuesto anual actual
  Future<double> obtenerPresupuestoAnual() async {
    final db = await database;
    final now = DateTime.now();

    final result = await db.query(
      'presupuestos_anuales',
      where: 'anio = ?',
      whereArgs: [now.year],
    );

    if (result.isEmpty) return 0.0;
    return result.first['monto'] as double;
  }

  /// Elimina el presupuesto anual actual
  Future<void> eliminarPresupuestoAnual() async {
    final db = await database;
    final now = DateTime.now();

    await db.delete(
      'presupuestos_anuales',
      where: 'anio = ?',
      whereArgs: [now.year],
    );
  }

  /// Obtiene el historial de presupuestos anuales anteriores al actual
  Future<List<Map<String, dynamic>>>
      obtenerHistorialPresupuestosAnuales() async {
    final db = await database;
    final now = DateTime.now();

    return await db.query(
      'presupuestos_anuales',
      where: 'anio < ?',
      whereArgs: [now.year],
      orderBy: 'anio DESC',
    );
  }

  // =============================================
  // 8. FUNCIONES AUXILIARES Y MANTENIMIENTO
  // =============================================

  /// Calcula el número de semana del año para una fecha dada
  int _obtenerNumeroSemana(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(firstDayOfYear).inDays;
    return ((daysDifference + firstDayOfYear.weekday - 1) / 7).floor() + 1;
  }

  /// Cierra la conexión con la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  /// Resetea completamente la base de datos (elimina y recrea)
  Future<void> resetearBaseDeDatos() async {
    final db = await database;
    await db.close();
    final dbPath = join(await getDatabasesPath(), 'gastos.db');
    await deleteDatabase(dbPath);
    _database = null;
    await database;
  }

  /// Obtiene todos los gastos para exportar (ordenados por fecha)
  Future<List<Map<String, dynamic>>> obtenerTodosGastosParaExportar() async {
    final db = await database;
    return await db.query('gastos', orderBy: 'fecha DESC');
  }

  /// Elimina todos los gastos y presupuestos de la base de datos
  Future<void> eliminarTodosGastosYPresupuestos() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('gastos');
      await txn.delete('presupuestos_mensuales');
      await txn.delete('presupuestos_semanales');
      await txn.delete('presupuestos_anuales');
    });
    // Notificar a todos los listeners que los datos han cambiado
    EventBus().notifyGastoEliminado();
    EventBus().notifyPresupuestoActualizado('mensual');
    EventBus().notifyPresupuestoActualizado('semanal');
    EventBus().notifyPresupuestoActualizado('anual');
  }
}