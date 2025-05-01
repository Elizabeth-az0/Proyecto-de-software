import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_cash/componentes/gastos/agregargasto.dart'; // Importa la pantalla de agregar gasto

class PantallaGastos extends StatefulWidget {
  const PantallaGastos({super.key});

  @override
  State<PantallaGastos> createState() => _PantallaGastosState();
}

class _PantallaGastosState extends State<PantallaGastos> {
  List<Map<String, String>> gastos = [
    {
      'titulo': 'Pizza especial',
      'categoria': 'Comida',
      'fecha': 'Abril 25, 2025',
      'monto': '\$ 24.50',
    },
    {
      'titulo': 'Pizza especial',
      'categoria': 'Comida',
      'fecha': 'Abril 25, 2025',
      'monto': '\$ 24.50',
    },
    {
      'titulo': 'Pizza especial',
      'categoria': 'Comida',
      'fecha': 'Abril 25, 2025',
      'monto': '\$ 24.50',
    },
  ];

  void eliminarGasto(int index) {
    setState(() {
      gastos.removeAt(index);
    });
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
            onPressed: () {
              // Redirige a la pantalla AgregarGasto al presionar el botón
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AgregarGasto()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAEEBC1),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Agregar gasto'),
          ),
          const SizedBox(height: 30),
          Expanded(
            child:
                gastos.isEmpty
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
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Transacciones recientes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Aún no hay transacciones registradas',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : ListView.builder(
                      itemCount: gastos.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      gasto['titulo']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      gasto['categoria']!,
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
                                    gasto['monto']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    gasto['fecha']!,
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
                                onPressed: () => eliminarGasto(index),
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
