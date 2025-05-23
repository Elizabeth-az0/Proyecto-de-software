import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:MyCash/database/gastos_db.dart';
import 'package:MyCash/componentes/event_bus.dart';

/// Widget para agregar un nuevo gasto
///
/// Permite al usuario ingresar los detalles de un gasto (título, descripción, costo, categoría y fecha)
/// y guardarlos en la base de datos
class AgregarGasto extends StatefulWidget {
  const AgregarGasto({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AgregarGastoState createState() => _AgregarGastoState();
}

/// Clase de estado para manejar la lógica y UI del widget AgregarGasto
class _AgregarGastoState extends State<AgregarGasto> {
  // Controladores para los campos de texto
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _costoController = TextEditingController();
  final _fechaController = TextEditingController();
  // Variables para categoría y fecha seleccionada
  String _categoria = 'Comida'; // Categoría por defecto
  DateTime _fecha = DateTime.now(); // Fecha actual por defecto
  // Clave para validar el formulario
  final _formKey = GlobalKey<FormState>();

  // Lista de categorías disponibles
  final List<String> _categorias = [
    'Comida',
    'Entretenimiento',
    'Compras',
    'Salud',
    'Transporte',
    'Otros',
  ];

  // Mapeo de categorías a iconos para visualización
  final Map<String, IconData> _categoriaIconos = {
    'Comida': Icons.restaurant,
    'Entretenimiento': Icons.movie,
    'Compras': Icons.shopping_cart,
    'Salud': Icons.medical_services,
    'Transporte': Icons.directions_car,
    'Otros': Icons.more_horiz,
  };

  // =============================================
  // 1. CICLO DE VIDA
  // =============================================

  /// Inicialización del estado
  @override
  void initState() {
    super.initState();
    // Inicializa el controlador de fecha con la fecha actual
    _fechaController.text = DateFormat('yyyy-MM-dd').format(_fecha);

    // Agrega listeners para actualizar los contadores de caracteres
    _tituloController.addListener(() {
      setState(() {}); // Refresca la UI al cambiar el texto
    });
    _descripcionController.addListener(() {
      setState(() {}); // Refresca la UI al cambiar el texto
    });
  }

  /// Limpieza de recursos al destruir el widget
  @override
  void dispose() {
    // Libera los controladores
    _tituloController.dispose();
    _descripcionController.dispose();
    _costoController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  // =============================================
  // 2. MÉTODOS AUXILIARES
  // =============================================

  /// Abre el selector de fechas y actualiza la fecha seleccionada
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _fecha) {
      setState(() {
        _fecha = picked;
        _fechaController.text = DateFormat('yyyy-MM-dd').format(_fecha); // Actualiza el controlador
      });
    }
  }

  /// Muestra una alerta si el total de gastos supera el límite
  Future<void> _mostrarAlertaLimiteExcedido() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Límite Excedido'),
          content: const Text(
              'No puedes agregar este gasto porque el total de gastos no puede superar \$9999.'),
          actions: [
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  // =============================================
  // 3. INTERFAZ DE USUARIO
  // =============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agregar Gasto',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFD4F4E4), // Color de fondo de la AppBar
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Campo de título
              Text(
                'Título del gasto',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  filled: true,
                  fillColor: const Color(0xFFE3F5E8),
                  border: const OutlineInputBorder(),
                  counterText: '${_tituloController.text.length}/30',
                ),
                maxLength: 30,
                buildCounter: (context,
                    {required currentLength, required isFocused, maxLength}) {
                  return Text(
                    '$currentLength/$maxLength',
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  if (value.length > 30) {
                    return 'Máximo 30 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 5),
              // Campo de descripción
              Text(
                'Descripción',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción (opcional)',
                  filled: true,
                  fillColor: const Color(0xFFE3F5E8),
                  border: const OutlineInputBorder(),
                  counterText: '${_descripcionController.text.length}/100',
                ),
                maxLength: 100,
                maxLines: 1,
                buildCounter: (context,
                    {required currentLength, required isFocused, maxLength}) {
                  return Text(
                    '$currentLength/$maxLength',
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                },
                validator: (value) {
                  if (value != null && value.length > 100) {
                    return 'Máximo 100 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 0),
              // Campo de costo
              Text(
                'Costo',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _costoController,
                decoration: InputDecoration(
                  labelText: '\$',
                  filled: true,
                  fillColor: const Color(0xFFE3F5E8),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un monto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingresa un número válido';
                  }
                  final double monto = double.parse(value);
                  if (monto <= 0) {
                    return 'El monto debe ser mayor a cero';
                  }
                  if (monto > 9999) {
                    return 'El monto no puede ser mayor a \$9999';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Campo de categoría
              Text(
                'Categoría',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _categoria,
                icon: const Icon(Icons.arrow_drop_down),
                elevation: 4,
                style: const TextStyle(color: Colors.black, fontSize: 16.0),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFE3F5E8),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _categoria = newValue!; // Actualiza la categoría seleccionada
                  });
                },
                items: _categorias.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(
                          _categoriaIconos[value],
                          color: Colors.black,
                        ),
                        const SizedBox(width: 10),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Campo de fecha
              Text(
                'Fecha',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fechaController,
                decoration: InputDecoration(
                  labelText: 'YYYY-MM-DD',
                  filled: true,
                  fillColor: const Color(0xFFE3F5E8),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context), // Abre el selector de fechas
                  ),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una fecha';
                  }
                  try {
                    DateFormat('yyyy-MM-dd').parseStrict(value);
                  } catch (e) {
                    return 'Ingresa una fecha válida (YYYY-MM-DD)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              // Botón para guardar el gasto
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final titulo = _tituloController.text;
                      final costo = double.parse(_costoController.text);

                      // Verifica si el total de gastos supera el límite
                      final totalActual =
                          await GastosDB.instance.obtenerTotalGastos();

                      if (totalActual + costo > 9999) {
                        await _mostrarAlertaLimiteExcedido();
                        return;
                      }

                      // Crea el mapa del gasto
                      final gasto = {
                        'titulo': titulo,
                        'descripcion': _descripcionController.text,
                        'costo': costo,
                        'categoria': _categoria,
                        'fecha': DateFormat('yyyy-MM-dd').format(_fecha),
                      };

                      // Inserta el gasto en la base de datos
                      await GastosDB.instance.insertarGasto(gasto);

                      // Notifica a otras pantallas sobre el nuevo gasto
                      EventBus().notifyGastoAgregado();

                      if (mounted) {
                        Navigator.pop(context, true); // Regresa con resultado exitoso
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9DD8AF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('GUARDAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}