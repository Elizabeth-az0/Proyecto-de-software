import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget que muestra una tarjeta con el gasto total acumulado
///
/// Características:
/// - Diseño circular con sombra
/// - Icono SVG de dinero
/// - Formato monetario con 2 decimales
/// - Tamaño fijo de 250px de ancho
class GastoTotalCard extends StatelessWidget {
  /// Monto total a mostrar
  final double monto;

  /// Constructor del widget
  ///
  /// [monto] - Cantidad total de gastos a mostrar
  const GastoTotalCard({
    super.key,
    required this.monto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, // Ancho fijo para consistencia
      padding: const EdgeInsets.all(16), // Espaciado interno
      decoration: BoxDecoration(
        color: const Color(0xFFC8EAD2), // Color de fondo verde claro
        borderRadius: BorderRadius.circular(20), // Bordes redondeados
        boxShadow: const [
          BoxShadow(
            color: Colors.black12, // Sombra sutil
            blurRadius: 8,
            offset: Offset(0, 4), // Desplazamiento vertical
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ocupa solo espacio necesario
        children: [
          // Título "Gasto total"
          const Text(
            'Gasto total',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500, // Peso semi-negrita
              color: Colors.black87, // Color de texto oscuro
            ),
          ),
          const SizedBox(height: 6), // Espacio entre título y monto

          // Fila con icono y monto
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centrado horizontal
            children: [
              // Icono SVG de dinero
              SvgPicture.asset(
                'assets/icons/money.svg',
                width: 44,
                height: 44,
                colorFilter: const ColorFilter.mode(
                  Colors.black, // Icono negro
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12), // Espacio entre icono y texto

              // Monto formateado
              Text(
                '\$${monto.toStringAsFixed(2)}', // Formato monetario
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold, // Texto en negrita
                  color: Colors.black, // Color negro
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}