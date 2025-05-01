import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_cash/componentes/Home/widgets/transacciones.dart';
import 'package:my_cash/componentes/home/widgets/appbar.dart';
import 'package:my_cash/componentes/home/widgets/balance.dart';
import 'package:my_cash/componentes/home/widgets/opciones.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFD4F4E4),
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFD4F4E4),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(180),
          child: CustomAppBar(),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Center(child: GastoTotalCard(monto: 123.45)),
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: OpcionesRapidas(),
              ),
              SizedBox(height: 30),
              Transacciones(),
            ],
          ),
        ),
      ),
    );
  }
}
