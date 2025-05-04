import 'package:flutter/material.dart';
import 'package:my_cash/componentes/Home/widgets/presupuestos/pantallas/presupuesto_mensual.dart';
import 'package:my_cash/componentes/Home/widgets/presupuestos/pantallas/presupuesto_semanal.dart';
import 'package:my_cash/componentes/Home/widgets/presupuestos/pantallas/presupuesto_anual.dart';

class GestionPresupuestos extends StatefulWidget {
  const GestionPresupuestos({super.key});

  @override
  State<GestionPresupuestos> createState() => _GestionPresupuestosState();
}

class _GestionPresupuestosState extends State<GestionPresupuestos> {
  // Colores ajustados
  final Color green100 = const Color(0xFFE3F5E8);
  final Color green200 = const Color(0xFFA5D3B5);
  final Color green300 = const Color(0xFF7CC894);
  final Color green400 = const Color(0xFF589E6C);
  final Color darkGreen = const Color(0xFF2E7D32); // Verde oscuro para íconos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFC8EAD2),
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.3),
        title: const Text(
          'Gestión de Presupuestos',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Colors.black87, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Center(
              child: Text(
                'Selecciona un tipo de presupuesto',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildBudgetCard(
                    title: 'Presupuesto Semanal',
                    icon: Icons.date_range_rounded,
                    gradientColors: [green200, green400],
                    iconColor: darkGreen,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PresupuestoSemanal()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBudgetCard(
                    title: 'Presupuesto Mensual',
                    icon: Icons.calendar_today_rounded,
                    gradientColors: [green400, green200],
                    iconColor: darkGreen,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PresupuestoMensual()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBudgetCard(
                    title: 'Presupuesto Anual',
                    icon: Icons.calendar_month_rounded,
                    gradientColors: [green200, green400],
                    iconColor: darkGreen,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PresupuestoAnual()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
