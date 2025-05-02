import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:my_cash/database/gastos_db.dart';
import 'package:my_cash/componentes/event_bus.dart';

class ResumenGastos extends StatefulWidget {
  const ResumenGastos({super.key});

  @override
  State<ResumenGastos> createState() => _ResumenGastosState();
}

class _ResumenGastosState extends State<ResumenGastos> {
  List<Map<String, dynamic>> _gastos = [];
  List<Map<String, dynamic>> _gastosAno = [];
  double _totalGastos = 0.0;
  String _periodoSeleccionado = 'Mes';
  final List<String> _opcionesPeriodo = ['Día', 'Semana', 'Mes', 'Año'];
  StreamSubscription<GastoAgregadoEvent>? _gastoAgregadoSubscription;
  StreamSubscription<GastoEliminadoEvent>? _gastoEliminadoSubscription;

  @override
  void initState() {
    super.initState();
    _cargarDatos();

    _gastoAgregadoSubscription = EventBus().onGastoAgregado.listen((_) {
      if (mounted) {
        _cargarDatos();
        _mostrarSnackBar('Gasto agregado - Gráficos actualizados');
      }
    });

    _gastoEliminadoSubscription = EventBus().onGastoEliminado.listen((_) {
      if (mounted) {
        _cargarDatos();
        _mostrarSnackBar('Gasto eliminado - Gráficos actualizados');
      }
    });
  }

  void _mostrarSnackBar(String mensaje) {
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

  @override
  void dispose() {
    _gastoAgregadoSubscription?.cancel();
    _gastoEliminadoSubscription?.cancel();
    super.dispose();
  }

  /// Filtra los gastos según el período indicado
  List<Map<String, dynamic>> _filtrarGastosPorPeriodo(
      List<Map<String, dynamic>> gastos, String periodo) {
    final now = DateTime.now();
    DateTime startDate;

    switch (periodo) {
      case 'Día':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Semana':
        int weekday = now.weekday; // 1=Monday,...7=Sunday
        startDate = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: weekday - 1));
        break;
      case 'Mes':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Año':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(1970);
    }

    return gastos.where((gasto) {
      String fechaStr = gasto['fecha'] ?? '';
      try {
        final fecha = DateTime.parse(fechaStr);
        return fecha.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
            fecha.isBefore(now.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  Future<void> _cargarDatos() async {
    final todosGastos = await GastosDB.instance.obtenerTodosGastos();

    // Para el pie chart, filtrar según periodo seleccionado
    final gastosFiltrados =
        _filtrarGastosPorPeriodo(todosGastos, _periodoSeleccionado);

    // Para la barra, siempre filtrar por año
    final gastosFiltradosAno = _filtrarGastosPorPeriodo(todosGastos, 'Año');

    // Total Gastos para el pie chart periodo seleccionado
    double total = 0.0;
    for (var gasto in gastosFiltrados) {
      final costo = (gasto['costo'] as num).toDouble();
      total += costo;
    }

    if (mounted) {
      setState(() {
        _gastos = gastosFiltrados;
        _totalGastos = total;
        _gastosAno = gastosFiltradosAno;
      });
    }
  }

  Map<String, double> _calcularGastosPorCategoria() {
    final Map<String, double> gastosPorCategoria = {};

    for (var gasto in _gastos) {
      final categoria = gasto['categoria'] ?? 'Otros';
      final costo = (gasto['costo'] as num).toDouble();

      gastosPorCategoria.update(
        categoria,
        (value) => value + costo,
        ifAbsent: () => costo,
      );
    }

    return gastosPorCategoria;
  }

  Map<String, double> _calcularGastosPorFecha() {
    final Map<String, double> gastosPorFecha = {};

    for (var gasto in _gastosAno) {
      final fecha = _formatearFechaParaGrafico(gasto['fecha'] ?? '');
      final costo = (gasto['costo'] as num).toDouble();

      gastosPorFecha.update(
        fecha,
        (value) => value + costo,
        ifAbsent: () => costo,
      );
    }

    return gastosPorFecha;
  }

  String _formatearFechaParaGrafico(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return DateFormat('dd/MM').format(date);
    } catch (e) {
      return fecha;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gastosPorCategoria = _calcularGastosPorCategoria();
    final gastosPorFecha = _calcularGastosPorFecha();

    final datosGraficaPie = gastosPorCategoria.entries.map((entry) {
      final porcentaje = _totalGastos > 0
          ? (entry.value / _totalGastos * 100).toStringAsFixed(1)
          : '0.0';
      return _DatosGrafica(
        '${entry.key}\n$porcentaje%',
        entry.value,
        color: _obtenerColorPorCategoria(entry.key),
      );
    }).toList();

    final datosGraficaBarras = gastosPorFecha.entries.map((entry) {
      return _DatosGrafica(entry.key, entry.value);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFC8EAD2),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta de Total Gastado
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFC8EAD2),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
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
            ),
            const SizedBox(height: 25),

            // Selector de Período
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F5E8),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
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
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                    items: _opcionesPeriodo.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _periodoSeleccionado = newValue!;
                        _cargarDatos();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Gráfico de Pastel
            _buildChartCard(
              title: 'Distribución por Categoría',
              height: 350,
              child: SfCircularChart(
                margin: const EdgeInsets.all(0),
                legend: Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.wrap,
                  position: LegendPosition.bottom,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                series: <CircularSeries>[
                  PieSeries<_DatosGrafica, String>(
                    dataSource: datosGraficaPie,
                    xValueMapper: (_DatosGrafica datos, _) => datos.categoria,
                    yValueMapper: (_DatosGrafica datos, _) => datos.valor,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: TextStyle(fontSize: 12),
                      showZeroValue: false,
                      useSeriesColor: true,
                    ),
                    enableTooltip: true,
                    pointColorMapper: (_DatosGrafica datos, _) => datos.color,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Gráfico de Barras (siempre con gastos del año)
            _buildChartCard(
              title: 'Gastos por año',
              height: 300,
              child: SfCartesianChart(
                margin: const EdgeInsets.all(0),
                primaryXAxis: CategoryAxis(
                  labelRotation: -45,
                  labelStyle: const TextStyle(fontSize: 10),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Monto (\$)'),
                  labelStyle: const TextStyle(fontSize: 10),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<_DatosGrafica, String>>[
                  ColumnSeries<_DatosGrafica, String>(
                    dataSource: datosGraficaBarras,
                    xValueMapper: (_DatosGrafica datos, _) => datos.categoria,
                    yValueMapper: (_DatosGrafica datos, _) => datos.valor,
                    name: 'Gastos',
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(2),
                    width: 0.6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(
      {required String title, required double height, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE3F5E8), // Color de fondo cambiado aquí
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: height,
            child: child,
          ),
        ],
      ),
    );
  }

  Color _obtenerColorPorCategoria(String categoria) {
    final colores = {
      'Comida': const Color(0xFF4285F4),
      'Entretenimiento': const Color(0xFFEA4335),
      'Compras': const Color(0xFFFBBC05),
      'Salud': const Color(0xFF34A853),
      'Transporte': const Color(0xFF673AB7),
      'Otros': const Color(0xFF9E9E9E),
    };
    return colores[categoria] ?? const Color(0xFF9E9E9E);
  }
}

class _DatosGrafica {
  final String categoria;
  final double valor;
  final Color? color;

  _DatosGrafica(this.categoria, this.valor, {this.color});
}
