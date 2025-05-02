import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_cash/componentes/event_bus.dart';
import 'package:my_cash/componentes/gastos/agregargasto.dart';
import 'package:my_cash/database/gastos_db.dart';
import 'package:intl/intl.dart';

class PantallaGastos extends StatefulWidget {
  const PantallaGastos({super.key});

  @override
  State<PantallaGastos> createState() => _PantallaGastosState();
}

class _PantallaGastosState extends State<PantallaGastos> {
  List<Map<String, dynamic>> gastos = [];
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

  String? _ultimoMensajeMostrado;
  Timer? _snackBarTimer;

  @override
  void initState() {
    super.initState();
    _cargarGastos();

    _gastoAgregadoSubscription = EventBus().onGastoAgregado.listen((_) {
      _cargarGastos();
      _mostrarSnackBar(
          // ignore: deprecated_member_use
          'Gasto agregado correctamente',
          Colors.green.withOpacity(0.85));
    });

    _gastoEliminadoSubscription = EventBus().onGastoEliminado.listen((_) {
      _cargarGastos();
      _mostrarSnackBar(
          // ignore: deprecated_member_use
          'Gasto eliminado correctamente',
          Colors.redAccent.withOpacity(0.85));
    });
  }

  @override
  void dispose() {
    _gastoAgregadoSubscription.cancel();
    _gastoEliminadoSubscription.cancel();
    _snackBarTimer?.cancel();
    super.dispose();
  }

  Future<void> _cargarGastos() async {
    final listaGastos = await GastosDB.instance.obtenerTodosGastos();

    if (mounted) {
      setState(() {
        gastos = listaGastos;
      });
    }
  }

  Future<void> eliminarGasto(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFD4F4E4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Confirmar eliminación',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            '¿Estás seguro de que deseas eliminar este gasto?',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF44336),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'CANCELAR',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'ELIMINAR',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await GastosDB.instance.eliminarGasto(id);
      EventBus().notifyGastoEliminado();
    }
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    if (!mounted) return;

    if (_ultimoMensajeMostrado == mensaje) {
      return;
    }

    _ultimoMensajeMostrado = mensaje;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(
        mensaje,
        textAlign: TextAlign.center,
      ),
      // ignore: deprecated_member_use
      backgroundColor: color.withOpacity(0.85),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    Future.delayed(const Duration(seconds: 2), () {
      _ultimoMensajeMostrado = null;
    });
  }

  String _formatearFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return DateFormat('MMM d, yyyy', 'es').format(date);
    } catch (e) {
      return fecha;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4F4E4),
        elevation: 0,
        title: const Text(
          'Mis gastos',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AgregarGasto()),
              );
              if (result == true) {
                EventBus().notifyGastoAgregado();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9DD8AF),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              'Agregar gasto',
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: gastos.isEmpty
                ? Center(
                    child: Container(
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
                      child: const Text(
                        'Aún no hay transacciones registradas',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: gastos.length,
                    itemBuilder: (context, index) {
                      final gasto = gastos[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4F4E4),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _categoriaIconos[gasto['categoria']] ??
                                  Icons.more_horiz,
                              color: Colors.black,
                              size: 36,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gasto['titulo'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    gasto['categoria'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
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
                                const SizedBox(height: 4),
                                Text(
                                  _formatearFecha(gasto['fecha'] ?? ''),
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/icons/trash.svg',
                                width: 40,
                                height: 40,
                                colorFilter: const ColorFilter.mode(
                                  Colors.black,
                                  BlendMode.srcIn,
                                ),
                              ),
                              onPressed: () => eliminarGasto(
                                  int.parse(gasto['id'].toString())),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
