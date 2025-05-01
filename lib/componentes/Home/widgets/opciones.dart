import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_cash/componentes/gastos/gastos.dart';

class OpcionesRapidas extends StatelessWidget {
  const OpcionesRapidas({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        BotonOpcion(
          icono: 'assets/icons/payment.svg',
          texto: 'Resumen\nde gastos',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Resumen en construcción 🛠')),
            );
          },
        ),
        BotonOpcion(
          icono: 'assets/icons/setting.svg',
          texto: 'Más opciones',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Opciones avanzadas próximamente 📦'),
              ),
            );
          },
        ),
        BotonOpcion(
          icono: 'assets/icons/add.svg',
          texto: 'Añadir\ngastos',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PantallaGastos()),
            );
          },
        ),
      ],
    );
  }
}

class BotonOpcion extends StatelessWidget {
  final String icono;
  final String texto;
  final VoidCallback onTap;

  const BotonOpcion({
    super.key,
    required this.icono,
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 100,
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFAEEBC1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icono,
              width: 36,
              height: 36,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
