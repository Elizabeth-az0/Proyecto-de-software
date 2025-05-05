import 'dart:async';
import 'package:MyCash/componentes/event_bus.dart';
import 'package:MyCash/database/gastos_db.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Pantalla que muestra un resumen visual de gastos con gráficos interactivos
/// 
/// Características principales:
/// - Filtrado por período (día, semana, mes, año)
/// - Gráfico circular por categorías
/// - Gráfico de barras por meses
/// - Actualización automática al agregar/eliminar gastos
class ResumenGastos extends StatefulWidget {
  const ResumenGastos({super.key});

  @override
  State<ResumenGastos> createState() => _ResumenGastosState();
}

/// [Estado] para la pantalla de ResumenGastos
/// 
/// Maneja:
/// - Carga y filtrado de datos
/// - Configuración de gráficos
/// - Suscripciones a eventos
class _ResumenGastosState extends State<ResumenGastos> {
  // =============================================
  // 1. CONSTANTES Y CONFIGURACIONES
  // =============================================
  static const _opcionesPeriodo = ['Día', 'Semana', 'Mes', 'Año'];
  static const _colorPrincipal = Color(0xFFC8EAD2);
  static const _colorFondoTarjetas = Color(0xFFE3F5E8);
  static const _colorVerde = Color(0xFF4CAF50);

  // =============================================
  // 2. ESTADO DEL WIDGET
  // =============================================
  String _periodoSeleccionado = 'Mes';
  List<Map<String, dynamic>> _gastos = [];
  List<Map<String, dynamic>> _gastosAno = [];
  double _totalGastos = 0.0;

  // =============================================
  // 3. CONTROL DE EVENTOS Y SUSCRIPCIONES
  // =============================================
  final _eventBus = EventBus();
  StreamSubscription<GastoAgregadoEvent>? _gastoAgregadoSubscription;
  StreamSubscription<GastoEliminadoEvent>? _gastoEliminadoSubscription;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  @override
  void dispose() {
    _limpiarSubscripciones();
    super.dispose();
  }

  // =============================================
  // 4. MÉTODOS DE INICIALIZACIÓN Y LIMPIEZA
  // =============================================

  /// Inicializa el componente con datos y listeners
  void _inicializar() {
    _cargarDatos();
    _configurarEventListeners();
  }

  /// Configura listeners para reaccionar a cambios en gastos
  void _configurarEventListeners() {
    _gastoAgregadoSubscription = _eventBus.onGastoAgregado.listen((_) {
      if (!mounted) return;
      _cargarDatos();
      _mostrarFeedback('Gasto agregado - Gráficos actualizados');
    });

    _gastoEliminadoSubscription = _eventBus.onGastoEliminado.listen((_) {
      if (!mounted) return;
      _cargarDatos();
      _mostrarFeedback('Gasto eliminado - Gráficos actualizados');
    });
  }

  /// Cancela las suscripciones a eventos para evitar memory leaks
  void _limpiarSubscripciones() {
    _gastoAgregadoSubscription?.cancel();
    _gastoEliminadoSubscription?.cancel();
  }

  // =============================================
  // 5. MANEJO DE DATOS
  // =============================================

  /// Carga y procesa los datos de gastos desde la base de datos
  Future<void> _cargarDatos() async {
    final todosGastos = await GastosDB.instance.obtenerTodosGastos();

    if (!mounted) return;

    setState(() {
      _gastos = _filtrarGastosPorPeriodo(todosGastos, _periodoSeleccionado);
      _gastosAno = _filtrarGastosPorPeriodo(todosGastos, 'Año');
      _totalGastos = _calcularTotalGastos(_gastos);
    });
  }

  /// Filtra gastos según el período seleccionado
  List<Map<String, dynamic>> _filtrarGastosPorPeriodo(
      List<Map<String, dynamic>> gastos, String periodo) {
    final now = DateTime.now();
    final startDate = _obtenerFechaInicioPeriodo(periodo, now);

    return gastos.where((gasto) {
      return _esGastoEnPeriodo(gasto['fecha'] ?? '', startDate, now);
    }).toList();
  }

  /// Calcula la fecha de inicio según el período
  DateTime _obtenerFechaInicioPeriodo(String periodo, DateTime now) {
    switch (periodo) {
      case 'Día':
        return DateTime(now.year, now.month, now.day);
      case 'Semana':
        return now.subtract(Duration(days: now.weekday - 1));
      case 'Mes':
        return DateTime(now.year, now.month, 1);
      case 'Año':
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(1970);
    }
  }

  /// Verifica si un gasto está dentro del rango de fechas (MODIFICADO)
  bool _esGastoEnPeriodo(String fechaStr, DateTime startDate, DateTime now) {
    try {
      final fecha = DateTime.parse(fechaStr);
      return fecha.isAfter(startDate.subtract(const Duration(seconds: 1)));
    } catch (e) {
      return false;
    }
  }

  /// Suma total de gastos para una lista dada
  double _calcularTotalGastos(List<Map<String, dynamic>> gastos) {
    return gastos.fold(
        0.0, (total, gasto) => total + (gasto['costo'] as num).toDouble());
  }

  // =============================================
  // 6. PROCESAMIENTO DE DATOS PARA GRÁFICOS
  // =============================================

  /// Agrupa gastos por categoría con sus totales
  Map<String, double> _calcularGastosPorCategoria() {
    final gastosPorCategoria = <String, double>{};

    for (final gasto in _gastos) {
      final categoria = gasto['categoria']?.toString() ?? 'Otros';
      final costo = (gasto['costo'] as num).toDouble();
      gastosPorCategoria[categoria] =
          (gastosPorCategoria[categoria] ?? 0) + costo;
    }

    return gastosPorCategoria;
  }

  /// Agrupa gastos anuales por mes con sus totales
  Map<String, double> _calcularGastosPorMes() {
    final gastosPorMes = <String, double>{};

    for (final gasto in _gastosAno) {
      final fecha =
          _formatearFechaParaGrafico(gasto['fecha']?.toString() ?? '');
      final costo = (gasto['costo'] as num).toDouble();
      gastosPorMes[fecha] = (gastosPorMes[fecha] ?? 0) + costo;
    }

    return gastosPorMes;
  }

  /// Formatea fecha a formato abreviado de mes (ej: "Ene")
  String _formatearFechaParaGrafico(String fecha) {
    try {
      return DateFormat('MMM', 'es').format(DateTime.parse(fecha));
    } catch (e) {
      return 'Inválido';
    }
  }

  // =============================================
  // 7. CONSTRUCCIÓN DE LA INTERFAZ DE USUARIO
  // =============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _construirAppBar(),
      body: _construirCuerpo(),
    );
  }

  /// Construye la barra superior de la aplicación
  AppBar _construirAppBar() {
    return AppBar(
      backgroundColor: _colorPrincipal,
      title: const Text(
        'Resumen de Gastos',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
      elevation: 1,
      iconTheme: const IconThemeData(color: Colors.black54),
    );
  }

  /// Construye el contenido principal de la pantalla
  Widget _construirCuerpo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _construirTarjetaTotal(),
          const SizedBox(height: 25),
          _construirSelectorPeriodo(),
          const SizedBox(height: 25),
          _construirGraficoTorta(),
          const SizedBox(height: 25),
          _construirGraficoBarras(),
        ],
      ),
    );
  }

  /// Tarjeta que muestra el total gastado
  Widget _construirTarjetaTotal() {
    return Container(
      decoration: _crearDecoracionTarjeta(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'TOTAL GASTADO',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${_totalGastos.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Período: $_periodoSeleccionado',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Selector de período para filtrar los gastos
  Widget _construirSelectorPeriodo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: _crearDecoracionSelector(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Visualizar por:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          DropdownButton<String>(
            value: _periodoSeleccionado,
            underline: Container(),
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            items: _opcionesPeriodo.map(_crearItemDropdown).toList(),
            onChanged: _actualizarPeriodoSeleccionado,
          ),
        ],
      ),
    );
  }

  /// Crea un ítem para el DropdownButton
  DropdownMenuItem<String> _crearItemDropdown(String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }

  /// Actualiza el período seleccionado y recarga los datos
  void _actualizarPeriodoSeleccionado(String? newValue) {
    if (newValue == null) return;

    setState(() {
      _periodoSeleccionado = newValue;
      _cargarDatos();
    });
  }

  /// Gráfico circular de distribución por categorías
  Widget _construirGraficoTorta() {
    final datosGrafica =
        _calcularGastosPorCategoria().entries.map(_crearDatoGrafica).toList();

    return _construirContenedorGrafico(
      titulo: 'Distribución por Categoría',
      altura: 350,
      grafico: SfCircularChart(
        margin: EdgeInsets.zero,
        legend: _crearLeyendaGrafico(),
        series: <CircularSeries>[
          PieSeries<_DatosGrafica, String>(
            dataSource: datosGrafica,
            xValueMapper: (datos, _) => datos.categoria,
            yValueMapper: (datos, _) => datos.valor,
            dataLabelSettings: _crearConfiguracionEtiquetas(),
            enableTooltip: true,
            pointColorMapper: (datos, _) => datos.color,
          ),
        ],
      ),
    );
  }

  /// Gráfico de barras de gastos por mes
  Widget _construirGraficoBarras() {
    final datosGrafica = _calcularGastosPorMes()
        .entries
        .map((e) => _DatosGrafica(e.key, e.value))
        .toList();

    return _construirContenedorGrafico(
      titulo: 'Gastos por Mes',
      altura: 300,
      grafico: SfCartesianChart(
        margin: EdgeInsets.zero,
        primaryXAxis: _crearEjeCategorias(),
        primaryYAxis: _crearEjeNumerico(),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries<_DatosGrafica, String>>[
          ColumnSeries<_DatosGrafica, String>(
            dataSource: datosGrafica,
            xValueMapper: (datos, _) => datos.categoria,
            yValueMapper: (datos, _) => datos.valor,
            name: 'Gastos',
            color: _colorVerde,
            borderRadius: BorderRadius.circular(2),
            width: 0.6,
          ),
        ],
      ),
    );
  }

  /// Contenedor estilizado para los gráficos
  Widget _construirContenedorGrafico({
    required String titulo,
    required double altura,
    required Widget grafico,
  }) {
    return Container(
      decoration: _crearDecoracionTarjeta(),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(height: altura, child: grafico),
        ],
      ),
    );
  }

  // =============================================
  // 8. COMPONENTES REUTILIZABLES Y ESTILOS
  // =============================================

  /// Crea un dato para los gráficos con formato y color
  _DatosGrafica _crearDatoGrafica(MapEntry<String, double> entry) {
    final porcentaje = _totalGastos > 0
        ? (entry.value / _totalGastos * 100).toStringAsFixed(1)
        : '0.0';

    return _DatosGrafica(
      '${entry.key}\n$porcentaje%',
      entry.value,
      color: _obtenerColorCategoria(entry.key),
    );
  }

  /// Decoración común para tarjetas
  BoxDecoration _crearDecoracionTarjeta() {
    return BoxDecoration(
      color: _colorFondoTarjetas,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Decoración para el selector de período
  BoxDecoration _crearDecoracionSelector() {
    return BoxDecoration(
      color: _colorFondoTarjetas,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  /// Configuración de la leyenda para gráficos
  Legend _crearLeyendaGrafico() {
    return Legend(
      isVisible: true,
      overflowMode: LegendItemOverflowMode.wrap,
      position: LegendPosition.bottom,
      textStyle: const TextStyle(fontSize: 12, color: Colors.black54),
    );
  }

  /// Configuración de etiquetas para gráficos
  DataLabelSettings _crearConfiguracionEtiquetas() {
    return const DataLabelSettings(
      isVisible: true,
      labelPosition: ChartDataLabelPosition.outside,
      textStyle: TextStyle(fontSize: 12),
      showZeroValue: false,
      useSeriesColor: true,
    );
  }

  /// Configuración del eje X (categorías)
  CategoryAxis _crearEjeCategorias() {
    return CategoryAxis(
      labelRotation: -45,
      labelStyle: const TextStyle(fontSize: 10),
    );
  }

  /// Configuración del eje Y (valores)
  NumericAxis _crearEjeNumerico() {
    return NumericAxis(
      title: AxisTitle(text: 'Monto (\$)'),
      labelStyle: const TextStyle(fontSize: 10),
    );
  }

  /// Muestra un mensaje feedback al usuario
  void _mostrarFeedback(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Obtiene color específico para cada categoría
  Color _obtenerColorCategoria(String categoria) {
    const colores = {
      'Comida': Color(0xFF4285F4),
      'Entretenimiento': Color(0xFFEA4335),
      'Compras': Color(0xFFFBBC05),
      'Salud': Color(0xFF34A853),
      'Transporte': Color(0xFF673AB7),
      'Otros': Color(0xFF9E9E9E),
    };

    return colores[categoria] ?? const Color(0xFF9E9E9E);
  }
}

/// Modelo para datos de gráficos
/// 
/// Contiene:
/// - categoría: Nombre de la categoría/mes
/// - valor: Monto total
/// - color: Color asociado (opcional)
class _DatosGrafica {
  final String categoria;
  final double valor;
  final Color? color;

  _DatosGrafica(this.categoria, this.valor, {this.color});
}