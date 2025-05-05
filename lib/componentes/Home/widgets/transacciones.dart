import 'dart:async';
import 'package:MyCash/database/gastos_db.dart';
import 'package:flutter/material.dart';
import 'package:MyCash/componentes/event_bus.dart';
import 'package:MyCash/componentes/gastos/gastos.dart';
import 'package:MyCash/componentes/gastos/agregargasto.dart';
import 'package:intl/intl.dart';

/// Widget que muestra las últimas transacciones (gastos) registradas
/// 
/// Características:
/// - Muestra los 3 últimos gastos
/// - Iconos representativos por categoría
/// - Formato amigable de fechas
/// - Opción para agregar nuevos gastos
/// - Actualización automática al agregar/eliminar gastos
class Transacciones extends StatefulWidget {
  const Transacciones({super.key});

  @override
  State<Transacciones> createState() => _TransaccionesState();
}

class _TransaccionesState extends State<Transacciones> {
  // =============================================
  // 1. ESTADO DEL WIDGET
  // =============================================
  
  /// Lista de los últimos gastos registrados
  List<Map<String, dynamic>> _ultimosGastos = [];
  
  /// Suscripciones a eventos del bus de eventos
  late StreamSubscription _gastoAgregadoSubscription;
  late StreamSubscription _gastoEliminadoSubscription;

  /// Mapeo de categorías a iconos
  final Map<String, IconData> _categoriaIconos = {
    'Comida': Icons.restaurant,
    'Entretenimiento': Icons.movie,
    'Compras': Icons.shopping_cart,
    'Salud': Icons.medical_services,
    'Transporte': Icons.directions_car,
    'Otros': Icons.more_horiz,
  };

  // =============================================
  // 2. CICLO DE VIDA DEL WIDGET
  // =============================================

  @override
  void initState() {
    super.initState();
    _cargarUltimosGastos();
    _configurarEventListeners();
  }

  @override
  void dispose() {
    _limpiarSubscripciones();
    super.dispose();
  }

  // =============================================
  // 3. MANEJO DE DATOS
  // =============================================

  /// Carga los últimos gastos desde la base de datos
  Future<void> _cargarUltimosGastos() async {
    final gastos = await GastosDB.instance.obtenerUltimosGastos(3);
    if (mounted) {
      setState(() {
        _ultimosGastos = gastos;
      });
    }
  }

  /// Configura listeners para eventos de gastos
  void _configurarEventListeners() {
    _gastoAgregadoSubscription = EventBus().onGastoAgregado.listen((_) {
      _cargarUltimosGastos();
    });

    _gastoEliminadoSubscription = EventBus().onGastoEliminado.listen((_) {
      _cargarUltimosGastos();
    });
  }

  /// Cancela las suscripciones a eventos
  void _limpiarSubscripciones() {
    _gastoAgregadoSubscription.cancel();
    _gastoEliminadoSubscription.cancel();
  }

  // =============================================
  // 4. FUNCIONES AUXILIARES
  // =============================================

  /// Formatea una fecha string a formato legible
  String _formatearFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return DateFormat('dd MMM yyyy', 'es').format(date);
    } catch (e) {
      return fecha;
    }
  }

  // =============================================
  // 5. CONSTRUCCIÓN DE LA INTERFAZ
  // =============================================

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD4F4E4),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con título y botón de agregar
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PantallaGastos()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Últimos gastos',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AgregarGasto()),
                    );
                    if (result == true) {
                      _cargarUltimosGastos();
                      EventBus().notifyGastoAgregado();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Lista de transacciones o mensaje vacío
          _ultimosGastos.isEmpty
              ? const Center(
                  child: Text(
                    'Aún no hay transacciones registradas',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : Column(
                  children: _ultimosGastos.map((gasto) {
                    return _buildItemGasto(context, gasto);
                  }).toList(),
                ),
        ],
      ),
    );
  }

  /// Construye un ítem de gasto individual
  Widget _buildItemGasto(BuildContext context, Map<String, dynamic> gasto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFC8EAD2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila principal con icono, título, categoría y monto/fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Columna izquierda: Icono, título y categoría
                Row(
                  children: [
                    Icon(
                      _categoriaIconos[gasto['categoria']] ?? Icons.more_horiz,
                      color: Colors.black,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Text(
                            gasto['titulo'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        Text(
                          gasto['categoria'] ?? '',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Columna derecha: Monto y fecha
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${(gasto['costo'] ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _formatearFecha(gasto['fecha'] ?? ''),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Descripción (si existe)
            if (gasto['descripcion'] != null && gasto['descripcion'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  gasto['descripcion']!,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}