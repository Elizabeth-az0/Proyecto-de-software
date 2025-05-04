import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_cash/componentes/event_bus.dart';
import 'package:my_cash/componentes/home/widgets/transacciones.dart';
import 'package:my_cash/componentes/home/widgets/appbar.dart';
import 'package:my_cash/componentes/home/widgets/balance.dart';
import 'package:my_cash/componentes/home/widgets/opciones.dart';
import 'package:my_cash/database/gastos_db.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _totalGastos = 0.0;
  double _presupuestoMensual = 0.0;
  double _gastosMesActual = 0.0;
  double _presupuestoSemanal = 0.0;
  double _gastosSemanaActual = 0.0;
  double _presupuestoAnual = 0.0;
  double _gastosAnioActual = 0.0;

  late StreamSubscription _gastoAgregadoSubscription;
  late StreamSubscription _gastoEliminadoSubscription;
  late StreamSubscription _presupuestoActualizadoSubscription;

  @override
  void initState() {
    super.initState();
    _cargarDatos();

    final eventBus = EventBus();
    _gastoAgregadoSubscription = eventBus.onGastoAgregado.listen((_) {
      _cargarDatos();
    });
    _gastoEliminadoSubscription = eventBus.onGastoEliminado.listen((_) {
      _cargarDatos();
    });
    _presupuestoActualizadoSubscription =
        eventBus.onPresupuestoActualizado.listen((event) {
      // Actualizar solo el presupuesto afectado
      _cargarPresupuestoEspecifico(event.tipo);
    });
  }

  @override
  void dispose() {
    _gastoAgregadoSubscription.cancel();
    _gastoEliminadoSubscription.cancel();
    _presupuestoActualizadoSubscription.cancel();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final total = await GastosDB.instance.obtenerTotalGastos();
    final presupuestoMensual =
        await GastosDB.instance.obtenerPresupuestoMensual();
    final gastosMes = await GastosDB.instance.obtenerTotalGastosMesActual();
    final presupuestoSemanal =
        await GastosDB.instance.obtenerPresupuestoSemanal();
    final gastosSemana =
        await GastosDB.instance.obtenerTotalGastosSemanaActual();
    final presupuestoAnual = await GastosDB.instance.obtenerPresupuestoAnual();
    final gastosAnio = await GastosDB.instance.obtenerTotalGastosAnioActual();

    if (mounted) {
      setState(() {
        _totalGastos = total;
        _presupuestoMensual = presupuestoMensual;
        _gastosMesActual = gastosMes;
        _presupuestoSemanal = presupuestoSemanal;
        _gastosSemanaActual = gastosSemana;
        _presupuestoAnual = presupuestoAnual;
        _gastosAnioActual = gastosAnio;
      });
    }
  }

  Future<void> _cargarPresupuestoEspecifico(String tipo) async {
    switch (tipo) {
      case 'mensual':
        final presupuesto = await GastosDB.instance.obtenerPresupuestoMensual();
        final gastos = await GastosDB.instance.obtenerTotalGastosMesActual();
        if (mounted) {
          setState(() {
            _presupuestoMensual = presupuesto;
            _gastosMesActual = gastos;
          });
        }
        break;
      case 'semanal':
        final presupuesto = await GastosDB.instance.obtenerPresupuestoSemanal();
        final gastos = await GastosDB.instance.obtenerTotalGastosSemanaActual();
        if (mounted) {
          setState(() {
            _presupuestoSemanal = presupuesto;
            _gastosSemanaActual = gastos;
          });
        }
        break;
      case 'anual':
        final presupuesto = await GastosDB.instance.obtenerPresupuestoAnual();
        final gastos = await GastosDB.instance.obtenerTotalGastosAnioActual();
        if (mounted) {
          setState(() {
            _presupuestoAnual = presupuesto;
            _gastosAnioActual = gastos;
          });
        }
        break;
    }
  }

  Widget _buildPresupuestoProgressWidget(
      String tipo, double presupuesto, double gastosPeriodo) {
    if (presupuesto <= 0) return SizedBox.shrink();

    final porcentaje = (gastosPeriodo / presupuesto).clamp(0.0, 1.0);
    final disponible = presupuesto - gastosPeriodo;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Text(
            'Presupuesto $tipo',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
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
                'Gastado: \$${gastosPeriodo.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Text(
                'Disponible: \$${disponible.toStringAsFixed(2)}',
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
  }

  Widget _buildPresupuestos() {
    final widgets = [
      _buildPresupuestoProgressWidget(
          'Mensual', _presupuestoMensual, _gastosMesActual),
      _buildPresupuestoProgressWidget(
          'Semanal', _presupuestoSemanal, _gastosSemanaActual),
      _buildPresupuestoProgressWidget(
          'Anual', _presupuestoAnual, _gastosAnioActual),
    ].where((w) => w is! SizedBox).toList();

    if (widgets.isEmpty) {
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
        child: const Center(
          child: Text(
            'No hay presupuestos configurados',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Column(children: widgets);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFC8EAD2),
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFC8EAD2),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(180),
          child: CustomAppBar(),
        ),
        body: RefreshIndicator(
          onRefresh: _cargarDatos,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(child: GastoTotalCard(monto: _totalGastos)),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: OpcionesRapidas(),
                ),
                const SizedBox(height: 30),
                const Transacciones(),
                const SizedBox(height: 30),
                _buildPresupuestos(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
