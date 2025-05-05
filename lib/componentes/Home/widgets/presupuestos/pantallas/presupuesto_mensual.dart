// PresupuestoMensual es un widget de Flutter que permite gestionar el presupuesto mensual.
// Este código implementa una interfaz para visualizar, actualizar, eliminar y consultar
// el historial de presupuestos mensuales, interactuando con una base de datos local
// a través de GastosDB y utilizando un EventBus para notificaciones.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:MyCash/componentes/event_bus.dart';
import 'package:MyCash/database/gastos_db.dart';

// Definición del widget PresupuestoMensual como StatefulWidget
class PresupuestoMensual extends StatefulWidget {
  const PresupuestoMensual({super.key});

  @override
  State<PresupuestoMensual> createState() => _PresupuestoMensualState();
}

// Clase de estado para manejar la lógica y UI del widget
class _PresupuestoMensualState extends State<PresupuestoMensual> {
  // Variables de estado
  double _presupuestoActual = 0.0; // Almacena el presupuesto mensual actual
  final TextEditingController _presupuestoController = TextEditingController(); // Controlador para el campo de texto
  final _formKey = GlobalKey<FormState>(); // Clave para validar el formulario
  bool _isLoading = true; // Indicador de carga inicial

  // Inicialización del estado
  @override
  void initState() {
    super.initState();
    _cargarPresupuesto(); // Carga el presupuesto al iniciar
  }

  // Método para cargar el presupuesto desde la base de datos
  Future<void> _cargarPresupuesto() async {
    setState(() {
      _isLoading = true; // Activa el indicador de carga
    });

    try {
      final presupuesto = await GastosDB.instance.obtenerPresupuestoMensual();
      setState(() {
        _presupuestoActual = presupuesto; // Actualiza el presupuesto
        _isLoading = false; // Desactiva el indicador de carga
      });
    } catch (e) {
      print('Error al cargar presupuesto: $e');
      setState(() {
        _presupuestoActual = 0.0; // Establece 0 en caso de error
        _isLoading = false;
      });
    }
  }

  // Método para guardar un nuevo presupuesto
  Future<void> _guardarPresupuesto() async {
    if (_formKey.currentState!.validate()) { // Valida el formulario
      final nuevoPresupuesto = double.parse(_presupuestoController.text);

      await GastosDB.instance.guardarPresupuestoMensual(nuevoPresupuesto); // Guarda en la base de datos

      // Notifica la actualización a otros componentes
      EventBus().notifyPresupuestoActualizado('mensual');

      setState(() {
        _presupuestoActual = nuevoPresupuesto; // Actualiza el estado
        _presupuestoController.clear(); // Limpia el campo de texto
      });

      // Muestra una notificación de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Presupuesto mensual actualizado'),
          backgroundColor: Colors.green[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // Método para eliminar el presupuesto actual
  Future<void> _eliminarPresupuesto() async {
    await GastosDB.instance.eliminarPresupuestoMensual(); // Elimina de la base de datos

    // Notifica la actualización
    EventBus().notifyPresupuestoActualizado('mensual');

    setState(() {
      _presupuestoActual = 0.0; // Resetea el presupuesto
    });

    // Muestra una notificación de eliminación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Presupuesto mensual eliminado'),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Construcción de la interfaz de usuario
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Color de fondo
      appBar: AppBar(
        backgroundColor: const Color(0xFFC8EAD2), // Color de la barra superior
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.3),
        title: const Text(
          'Presupuesto Mensual',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context), // Navega hacia atrás
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Muestra un indicador de carga
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tarjeta de resumen del presupuesto
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'PRESUPUESTO ACTUAL',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '\$${_presupuestoActual.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Mes: ${DateFormat('MMMM yyyy', 'es').format(DateTime.now())}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Formulario para actualizar presupuesto
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Actualizar Presupuesto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _presupuestoController,
                            decoration: InputDecoration(
                              labelText: 'Nuevo presupuesto',
                              prefixText: '\$',
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa un monto';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Ingresa un número válido';
                              }
                              if (double.parse(value) <= 0) {
                                return 'El monto debe ser mayor a cero';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _guardarPresupuesto,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9DD8AF),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Actualizar Presupuesto',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botón para eliminar presupuesto
                  if (_presupuestoActual > 0)
                    OutlinedButton(
                      onPressed: _eliminarPresupuesto,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Eliminar Presupuesto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),

                  // Progreso del presupuesto
                  const SizedBox(height: 30),
                  FutureBuilder<double>(
                    future: GastosDB.instance.obtenerTotalGastosMesActual(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final totalGastos = snapshot.data ?? 0.0;
                      final porcentaje = _presupuestoActual > 0
                          ? (totalGastos / _presupuestoActual).clamp(0.0, 1.0)
                          : 0.0;

                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Progreso del Mes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 15),
                            LinearProgressIndicator(
                              value: porcentaje,
                              minHeight: 20,
                              backgroundColor: Colors.grey[200],
                              color: porcentaje > 0.8
                                  ? Colors.red[400]
                                  : porcentaje > 0.5
                                      ? Colors.orange[400]
                                      : const Color.fromARGB(
                                          255, 102, 187, 106),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Gastado: \$${totalGastos.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  'Disponible: \$${(_presupuestoActual - totalGastos).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${(porcentaje * 100).toStringAsFixed(1)}% del presupuesto utilizado',
                              style: TextStyle(
                                fontSize: 14,
                                color: porcentaje > 0.8
                                    ? Colors.red[400]
                                    : porcentaje > 0.5
                                        ? Colors.orange[400]
                                        : const Color(0xFF66BB6A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Historial de presupuestos
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Historial de Presupuestos Mensuales',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: GastosDB.instance
                              .obtenerHistorialPresupuestosMensuales(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Text(
                                'Error al cargar historial: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              );
                            }

                            final presupuestos = snapshot.data ?? [];

                            if (presupuestos.isEmpty) {
                              return const Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'No hay presupuestos mensuales previos registrados',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: presupuestos.length,
                              itemBuilder: (context, index) {
                                final presupuesto = presupuestos[index];
                                final mes = presupuesto['mes'] as int;
                                final anio = presupuesto['anio'] as int;
                                final monto = presupuesto['monto'] as double;
                                final fecha = DateTime(anio, mes);

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    leading: const Icon(Icons.calendar_month,
                                        color: Colors.green),
                                    title: Text(
                                      DateFormat('MMMM yyyy', 'es')
                                          .format(fecha),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Text(
                                      '\$${monto.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}