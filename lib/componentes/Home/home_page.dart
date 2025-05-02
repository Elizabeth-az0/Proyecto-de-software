import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_cash/componentes/event_bus.dart';
import 'package:my_cash/componentes/home/widgets/transacciones.dart';
import 'package:my_cash/componentes/home/widgets/appbar.dart';
import 'package:my_cash/componentes/home/widgets/balance.dart';
import 'package:my_cash/componentes/home/widgets/opciones.dart';
import 'package:my_cash/database/gastos_db.dart';
// ignore: unused_import
import 'package:rxdart/rxdart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _totalGastos = 0.0;
  late StreamSubscription _gastoAgregadoSubscription;
  late StreamSubscription _gastoEliminadoSubscription;

  @override
  void initState() {
    super.initState();
    _cargarTotalGastos();

    final eventBus = EventBus();
    _gastoAgregadoSubscription = eventBus.onGastoAgregado.listen((_) {
      _cargarTotalGastos();
    });
    _gastoEliminadoSubscription = eventBus.onGastoEliminado.listen((_) {
      _cargarTotalGastos();
    });
  }

  @override
  void dispose() {
    _gastoAgregadoSubscription.cancel();
    _gastoEliminadoSubscription.cancel();
    super.dispose();
  }

  Future<void> _cargarTotalGastos() async {
    final total = await GastosDB.instance.obtenerTotalGastos();
    if (mounted) {
      setState(() {
        _totalGastos = total;
      });
    }
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
          onRefresh: _cargarTotalGastos,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
