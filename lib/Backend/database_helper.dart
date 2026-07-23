import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  Database? _database;
  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("inventario.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    if (kDebugMode) {
      // esto es solo para el modo debug
      print(dbPath);
    }
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      singleInstance: true,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE productos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT UNIQUE,
        nombre TEXT NOT NULL,
        cantidad REAL NOT NULL,
        precio REAL NOT NULL,
        tipo_venta TEXT NOT NULL CHECK(tipo_venta IN ('unidad','peso'))
      )
    ''');
    await db.execute('''
    CREATE TABLE ventas(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha TEXT DEFAULT (date('now','localtime')),
      hora TEXT DEFAULT (time('now','localtime')),
      total REAL
    )
  ''');
    // Tabla detalle_venta
    await db.execute('''
    CREATE TABLE detalle_venta(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_venta INTEGER,
      id_producto INTEGER,
      cantidad INTEGER,
      subtotal REAL,
      FOREIGN KEY (id_venta) REFERENCES ventas(id),
      FOREIGN KEY (id_producto) REFERENCES productos(id)
    )
  ''');
  }

  Future<int> insertProducto(Map<String, dynamic> producto) async {
    final db = await database;
    return await db.insert('productos', producto);
  }

  Future<List<Map<String, dynamic>>> getProductos() async {
    final db = await database;
    return await db.query('productos');
  }

  // SELECT
  Future<List<Map<String, dynamic>>> getProductoPorCodigo(String codigo) async {
    final db = await database;
    return await db.query(
      'productos',
      where: 'codigo = ?',
      whereArgs: [codigo],
    );
  }

  Future<List<Map<String, dynamic>>> getProductoPorID(int iD) async {
    final db = await database;
    return await db.query(
      'productos',
      columns: ['nombre', 'precio'],
      where: 'id=?',
      whereArgs: [iD],
    );
  }

  // UPDATE
  Future<int> actualizarProducto(Map<String, dynamic> producto) async {
    final db = await database;
    return await db.update(
      'productos',
      producto,
      where: 'codigo = ?',
      whereArgs: [producto['codigo']],
    );
  }

  Future<int> actualizarProductoPorNombre(Map<String, dynamic> producto) async {
    final db = await database;
    return await db.update(
      'productos',
      producto,
      where: 'nombre= ?',
      whereArgs: [producto['nombre']],
    );
  }

  //Delete
  Future<int> descontinuarProducto(Map<String, dynamic> producto) async {
    final db = await database;
    return await db.delete(
      'productos',
      where: 'codigo = ?',
      whereArgs: [producto['codigo']],
    );
  }

  Future<void> volcarVenta(
    double totalDeVenta,
    List<Map<String, dynamic>> cart,
  ) async {
    final db = await database;

    await db.transaction((txn) async {
      //esta transacción inserta en la tabla Ventas
      final idVenta = await txn.insert('ventas', {'total': totalDeVenta});
      for (var item in cart) {
        await txn.insert('detalle_venta', {
          'id_venta': idVenta,
          'id_producto': item['id'],
          'cantidad': item['cantidad'],
          'subtotal': item['subtotal'],
        });
        // await txn.update('productos', {'cantidad':?});
        await txn.rawUpdate(
          '''
          UPDATE productos
          SET cantidad=cantidad-?
          WHERE id = ?
        ''',
          [item['cantidad'], item['id']],
        );
      }
    });
  }

  Future<List<Map<String, dynamic>>> getGranelProducts() async {
    final db = await database;
    return db.query(
      'productos',
      columns: ['nombre'],
      where: "tipo_venta='peso'",
    );
  }

  Future<List<Map<String, dynamic>>> getDetalleVentas2(int id) async {
    final db = await database;
    return db.query(
      'detalle_venta',
      columns: ['id_venta', 'id_producto', 'cantidad', 'subtotal'],
      where: "id_venta=?",
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getVentas() async {
    final db = await database;
    return db.query('ventas');
  }

  Future<List<Map<String, dynamic>>> getDetalleVentas(int id) async {
    final db = await database;
    return db.rawQuery(
      ''' 
      SELECT * 
      FROM detalle_venta
      WHERE id=?
    ''',
      [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllDetails() async {
    final db = await database;
    return db.query('detalle_venta');
  }
}
