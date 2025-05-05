import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:MyCash/componentes/home/widgets/mas_opciones.dart';
import 'package:MyCash/componentes/gastos/gastos.dart';
import 'package:MyCash/database/resumen_gastos.dart';

/// Widget que muestra opciones rápidas de navegación en la pantalla principal
/// 
/// Incluye botones para:
/// - Resumen de gastos
/// - Más opciones
/// - Añadir nuevos gastos
class OpcionesRapidas extends StatelessWidget {
  const OpcionesRapidas({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16, // Espacio horizontal entre elementos
      runSpacing: 16, // Espacio vertical entre líneas
      children: [
        // Botón para resumen de gastos
        BotonOpcion(
          icono: 'assets/icons/payment.svg',
          texto: 'Resumen\nde gastos',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ResumenGastos()),
            );
          },
        ),
        
        // Botón para más opciones
        BotonOpcion(
          icono: 'assets/icons/setting.svg',
          texto: 'Más opciones',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MasOpciones()),
            );
          },
        ),
        
        // Botón para añadir gastos
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

/// Widget personalizado para botones de opción rápida
/// 
/// Muestra un icono SVG con texto debajo, en un contenedor con sombra
class BotonOpcion extends StatelessWidget {
  final String icono; // Ruta del icono SVG
  final String texto; // Texto a mostrar (puede contener \n para saltos de línea)
  final VoidCallback onTap; // Función a ejecutar al hacer tap

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
          color: const Color(0xFF9DD8AF), // Color de fondo del botón
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4), // Sombra con desplazamiento hacia abajo
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono SVG
            SvgPicture.asset(
              icono,
              width: 36,
              height: 36,
              colorFilter: const ColorFilter.mode(
                Colors.black, // Color del icono
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 8), // Espacio entre icono y texto
            
            // Texto del botón
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