// lib/componentes/opciones/mas_opciones.dart
import 'package:flutter/material.dart';
import 'package:my_cash/componentes/Home/widgets/presupuestos/gestion_presupuestos.dart';

class MasOpciones extends StatelessWidget {
  const MasOpciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFC8EAD2),
        elevation: 0,
        title: const Text(
          'Más Opciones',
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GestionPresupuestos()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9DD8AF),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text(
                'Gestionar Presupuestos',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
