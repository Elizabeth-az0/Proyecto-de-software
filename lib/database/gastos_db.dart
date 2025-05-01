class GastosDB {
  // Definición de métodos y propiedades para la base de datos
  static final GastosDB instance = GastosDB._();

  // Constructor privado para usar la instancia única
  GastosDB._();

  Future<void> insertarGasto(Map<String, dynamic> gasto) async {
    // Lógica para insertar el gasto en la base de datos
  }
}
