import 'dart:ui';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:intl/intl.dart';
import 'package:my_cash/componentes/event_bus.dart';
import 'package:my_cash/database/gastos_db.dart';

class PresupuestoAnual extends StatefulWidget {
  const PresupuestoAnual({super.key});

  @override
  State<PresupuestoAnual> createState() => _PresupuestoAnualState();
}

class _PresupuestoAnualState extends State<PresupuestoAnual> {
  double _presupuestoActual = 0.0;
  final TextEditingController _presupuestoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPresupuesto();
  }

  Future<void> _cargarPresupuesto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final presupuesto = await GastosDB.instance.obtenerPresupuestoAnual();
      setState(() {
        _presupuestoActual = presupuesto;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar presupuesto anual: $e');
      setState(() {
        _presupuestoActual = 0.0;
        _isLoading = false;
      });
    }
  }

  Future<void> _guardarPresupuesto() async {
    if (_formKey.currentState!.validate()) {
      final nuevoPresupuesto = double.parse(_presupuestoController.text);

      await GastosDB.instance.guardarPresupuestoAnual(nuevoPresupuesto);

      // Notificar actualización
      EventBus().notifyPresupuestoActualizado('anual');

      setState(() {
        _presupuestoActual = nuevoPresupuesto;
        _presupuestoController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Presupuesto anual actualizado'),
          backgroundColor: Colors.green[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _eliminarPresupuesto() async {
    await GastosDB.instance.eliminarPresupuestoAnual();

    // Notificar actualización
    EventBus().notifyPresupuestoActualizado('anual');

    setState(() {
      _presupuestoActual = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Presupuesto anual eliminado'),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC8EAD2),
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.3),
        title: const Text(
          'Presupuesto Anual',
          style: TextStyle(
            color: Color(0xDD000000),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tarjeta de resumen
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
                            color: Color(0x89000000),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '\$${_presupuestoActual.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Año: ${DateTime.now().year}',
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
                              labelText: 'Nuevo presupuesto anual',
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
                    future: GastosDB.instance.obtenerTotalGastosAnioActual(),
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
                              'Progreso del Año',
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
                                      : const Color(0xFF66BB6A),
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
                          'Historial de Presupuestos Anuales',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: GastosDB.instance
                              .obtenerHistorialPresupuestosAnuales(),
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
                                      'No hay presupuestos anuales previos registrados',
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
                                final anio = presupuesto['anio'] as int;
                                final monto = presupuesto['monto'] as double;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    leading: const Icon(Icons.calendar_today,
                                        color: Colors.blue),
                                    title: Text(
                                      'Año $anio',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Text(
                                      '\$${monto.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
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
