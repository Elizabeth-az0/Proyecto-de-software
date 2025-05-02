import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_cash/componentes/event_bus.dart';
import 'package:my_cash/componentes/gastos/gastos.dart';
import 'package:my_cash/database/gastos_db.dart';
import 'package:my_cash/componentes/gastos/agregargasto.dart';

class Transacciones extends StatefulWidget {
  const Transacciones({super.key});

  @override
  State<Transacciones> createState() => _TransaccionesState();
}

class _TransaccionesState extends State<Transacciones> {
  List<Map<String, dynamic>> _ultimosGastos = [];
  late StreamSubscription _gastoAgregadoSubscription;
  late StreamSubscription _gastoEliminadoSubscription;

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
    _cargarUltimosGastos();

    _gastoAgregadoSubscription = EventBus().onGastoAgregado.listen((_) {
      _cargarUltimosGastos();
    });

    _gastoEliminadoSubscription = EventBus().onGastoEliminado.listen((_) {
      _cargarUltimosGastos();
    });
  }

  @override
  void dispose() {
    _gastoAgregadoSubscription.cancel();
    _gastoEliminadoSubscription.cancel();
    super.dispose();
  }

  Future<void> _cargarUltimosGastos() async {
    final gastos = await GastosDB.instance.obtenerUltimosGastos(3);
    if (mounted) {
      setState(() {
        _ultimosGastos = gastos;
      });
    }
  }

  String _formatearFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return DateFormat('dd MMM yyyy', 'es').format(date);
    } catch (e) {
      return fecha;
    }
  }

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
                      MaterialPageRoute(builder: (context) => const AgregarGasto()),
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
          const SizedBox(height: 20),
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
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                                  Text(
                                    gasto['titulo'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}