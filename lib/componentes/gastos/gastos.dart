import 'dart:async';
import 'package:flutter/material.dart';
import 'package:MyCash/componentes/event_bus.dart';
import 'package:MyCash/componentes/gastos/agregargasto.dart';
import 'package:MyCash/componentes/gastos/editar_gasto.dart';
import 'package:MyCash/database/gastos_db.dart';
import 'package:intl/intl.dart';

/// Pantalla principal para gestión de gastos
///
/// Permite:
/// - Ver listado de gastos
/// - Agregar nuevos gastos
/// - Editar gastos existentes
/// - Eliminar gastos
/// - Filtrar por categorías
class PantallaGastos extends StatefulWidget {
  const PantallaGastos({super.key});

  @override
  State<PantallaGastos> createState() => _PantallaGastosState();
}

/// Clase de estado para manejar la lógica y UI de la pantalla de gastos
class _PantallaGastosState extends State<PantallaGastos> {
  // =============================================
  // 1. ESTADO Y VARIABLES
  // =============================================

  // Lista de gastos obtenida de la base de datos
  List<Map<String, dynamic>> gastos = [];
  // Suscripciones a eventos de gasto agregado y eliminado
  late StreamSubscription _gastoAgregadoSubscription;
  late StreamSubscription _gastoEliminadoSubscription;
  // Último mensaje mostrado en SnackBar para evitar repeticiones
  String? _ultimoMensajeMostrado;
  // Temporizador para controlar la duración del SnackBar
  Timer? _snackBarTimer;

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
  // 2. CICLO DE VIDA
  // =============================================

  /// Inicialización del estado
  @override
  void initState() {
    super.initState();
    _cargarGastos(); // Carga inicial de gastos
    _configurarSubscripcionesEventos(); // Configura las suscripciones a eventos
  }

  /// Limpieza de recursos al destruir el widget
  @override
  void dispose() {
    _gastoAgregadoSubscription.cancel(); // Cancela suscripción de gasto agregado
    _gastoEliminadoSubscription.cancel(); // Cancela suscripción de gasto eliminado
    _snackBarTimer?.cancel(); // Cancela el temporizador del SnackBar
    super.dispose();
  }

  // =============================================
  // 3. MANEJO DE DATOS
  // =============================================

  /// Configura las suscripciones a eventos de la aplicación
  void _configurarSubscripcionesEventos() {
    // Suscripción para actualizar la lista cuando se agrega un gasto
    _gastoAgregadoSubscription = EventBus().onGastoAgregado.listen((_) {
      _cargarGastos();
      _mostrarSnackBar(
          'Gasto agregado correctamente', Colors.green.withOpacity(0.85));
    });

    // Suscripción para actualizar la lista cuando se elimina un gasto
    _gastoEliminadoSubscription = EventBus().onGastoEliminado.listen((_) {
      _cargarGastos();
      _mostrarSnackBar(
          'Gasto eliminado correctamente', Colors.redAccent.withOpacity(0.85));
    });
  }

  /// Carga la lista de gastos desde la base de datos
  Future<void> _cargarGastos() async {
    final listaGastos = await GastosDB.instance.obtenerTodosGastos();

    if (mounted) {
      setState(() {
        gastos = listaGastos; // Actualiza la lista de gastos
      });
    }
  }

  /// Elimina un gasto con confirmación del usuario
  Future<void> eliminarGasto(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => _buildDialogoConfirmacionEliminacion(),
    );

    if (confirm == true) {
      await GastosDB.instance.eliminarGasto(id); // Elimina el gasto de la base de datos
      EventBus().notifyGastoEliminado(); // Notifica la eliminación
    }
  }

  /// Construye el diálogo de confirmación para eliminar un gasto
  Widget _buildDialogoConfirmacionEliminacion() {
    return AlertDialog(
      backgroundColor: const Color(0xFFE3F5E8), // Fondo del diálogo
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE74C3C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Confirmar eliminación',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ),
      content: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Esta acción eliminará permanentemente el gasto.\n¿Deseas continuar?',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsPadding: const EdgeInsets.only(bottom: 16),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF35844D),
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(false), // Cancela la eliminación
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE74C3C),
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true), // Confirma la eliminación
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, size: 18),
              SizedBox(width: 6),
              Text('Eliminar'),
            ],
          ),
        ),
      ],
    );
  }

  /// Edita un gasto existente
  Future<void> _editarGasto(int id, String titulo, String descripcion,
      String costo, String categoria, String fecha) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarGasto(
          id: id,
          titulo: titulo,
          descripcion: descripcion,
          costo: costo,
          categoria: categoria,
          fecha: fecha,
        ),
      ),
    );

    if (result == true) {
      _cargarGastos(); // Recarga la lista de gastos
      EventBus().notifyGastoAgregado(); // Notifica la edición como si fuera un nuevo gasto
    }
  }

  // =============================================
  // 4. MÉTODOS AUXILIARES
  // =============================================

  /// Muestra un mensaje SnackBar
  void _mostrarSnackBar(String mensaje, Color color) {
    if (!mounted || _ultimoMensajeMostrado == mensaje) return;

    _ultimoMensajeMostrado = mensaje;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(mensaje, textAlign: TextAlign.center),
      backgroundColor: color.withOpacity(0.85),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    _snackBarTimer = Timer(const Duration(seconds: 2), () {
      _ultimoMensajeMostrado = null; // Resetea el mensaje para permitir nuevos SnackBars
    });
  }

  /// Formatea una fecha para mostrarla
  String _formatearFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return DateFormat('MMM d, yyyy', 'es').format(date); // Formato en español
    } catch (e) {
      return fecha; // Retorna la fecha original en caso de error
    }
  }

  // =============================================
  // 5. INTERFAZ DE USUARIO
  // =============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 30),
          _buildBotonAgregarGasto(),
          const SizedBox(height: 30),
          _buildListaGastos(),
        ],
      ),
    );
  }

  /// Construye la AppBar de la pantalla
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFD4F4E4), // Color de fondo de la AppBar
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
        onPressed: () => Navigator.pop(context), // Navega hacia atrás
      ),
    );
  }

  /// Construye el botón para agregar nuevos gastos
  Widget _buildBotonAgregarGasto() {
    return ElevatedButton.icon(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AgregarGasto()),
        );
        if (result == true) {
          EventBus().notifyGastoAgregado(); // Notifica la adición de un gasto
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
    );
  }

  /// Construye la lista de gastos
  Widget _buildListaGastos() {
    return Expanded(
      child: gastos.isEmpty
          ? _buildMensajeListaVacia() // Muestra mensaje si no hay gastos
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: gastos.length,
              itemBuilder: (context, index) => _buildItemGasto(gastos[index]),
            ),
    );
  }

  /// Construye el mensaje cuando no hay gastos
  Widget _buildMensajeListaVacia() {
    return Center(
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
    );
  }

  /// Construye un ítem de gasto individual
  Widget _buildItemGasto(Map<String, dynamic> gasto) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEncabezadoGasto(gasto),
          const SizedBox(height: 8),
          _buildPieGasto(gasto),
        ],
      ),
    );
  }

  /// Construye la parte superior del ítem de gasto
  Widget _buildEncabezadoGasto(Map<String, dynamic> gasto) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gasto['titulo'] ?? '', // Título del gasto
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              if (gasto['descripcion'] != null && gasto['descripcion'].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    gasto['descripcion'] ?? '', // Descripción del gasto
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${(gasto['costo'] ?? 0).toStringAsFixed(2)}', // Costo del gasto
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construye la parte inferior del ítem de gasto
  Widget _buildPieGasto(Map<String, dynamic> gasto) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              _categoriaIconos[gasto['categoria']] ?? Icons.more_horiz, // Icono de la categoría
              color: Colors.black,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              gasto['categoria'] ?? '', // Nombre de la categoría
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              _formatearFecha(gasto['fecha'] ?? ''), // Fecha formateada
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () => _editarGasto(
                int.parse(gasto['id'].toString()),
                gasto['titulo'] ?? '',
                gasto['descripcion'] ?? '',
                (gasto['costo'] ?? 0).toString(),
                gasto['categoria'] ?? 'Comida',
                gasto['fecha'] ?? '',
              ), // Edita el gasto
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.black),
              onPressed: () => eliminarGasto(
                  int.parse(gasto['id'].toString())), // Elimina el gasto
            ),
          ],
        ),
      ],
    );
  }
}