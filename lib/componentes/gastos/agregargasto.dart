import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_cash/database/gastos_db.dart';
import 'package:my_cash/componentes/event_bus.dart';

class AgregarGasto extends StatefulWidget {
  const AgregarGasto({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AgregarGastoState createState() => _AgregarGastoState();
}

class _AgregarGastoState extends State<AgregarGasto> {
  final _tituloController = TextEditingController();
  final _costoController = TextEditingController();
  final _fechaController = TextEditingController();
  String _categoria = 'Comida';
  DateTime _fecha = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  final List<String> _categorias = [
    'Comida',
    'Entretenimiento',
    'Compras',
    'Salud',
    'Transporte',
    'Otros',
  ];

  final Map<String, IconData> _categoriaIconos = {
    'Comida': Icons.restaurant,
    'Entretenimiento': Icons.movie,
    'Compras': Icons.shopping_cart,
    'Salud': Icons.medical_services,
    'Transporte': Icons.directions_car,
    'Otros': Icons.more_horiz,
  };

  @override
  void initState() {
    super.initState();
    _fechaController.text = DateFormat('yyyy-MM-dd').format(_fecha);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _costoController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

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
        _fechaController.text = DateFormat('yyyy-MM-dd').format(_fecha);
      });
    }
  }

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
        backgroundColor: const Color(0xFFD4F4E4),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
                  labelText: '\$0.00',
                  filled: true,
                  fillColor: const Color(0xFFE3F5E8),
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _categoria = newValue!;
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
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final titulo = _tituloController.text;
                      final costo = double.parse(_costoController.text);

                      final totalActual =
                          await GastosDB.instance.obtenerTotalGastos();

                      if (totalActual + costo > 9999) {
                        await _mostrarAlertaLimiteExcedido();
                        return;
                      }

                      final gasto = {
                        'titulo': titulo,
                        'costo': costo,
                        'categoria': _categoria,
                        'fecha': DateFormat('yyyy-MM-dd').format(_fecha),
                      };

                      await GastosDB.instance.insertarGasto(gasto);

                      // Notificar a todas las pantallas
                      EventBus().notifyGastoAgregado();

                      if (mounted) {
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context, true);
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
