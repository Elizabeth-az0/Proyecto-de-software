import 'package:MyCash/componentes/Home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:MyCash/componentes/Home/widgets/presupuestos/gestion_presupuestos.dart';
import 'package:MyCash/database/gastos_db.dart';

/// Pantalla de configuración y opciones adicionales de la aplicación
/// 
/// Proporciona acceso a:
/// - Gestión de presupuestos
/// - Información sobre la aplicación
/// - Opción para restablecer todos los datos
class MasOpciones extends StatelessWidget {
  const MasOpciones({super.key});

  // =============================================
  // 1. MÉTODOS DE DIÁLOGOS
  // =============================================

  /// Muestra un diálogo de confirmación para restablecer la aplicación
  void _mostrarConfirmacionReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de advertencia
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  size: 40,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),

              // Título
              const Text(
                '¿Restablecer aplicación?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),

              // Mensaje
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Esta acción eliminará permanentemente todos tus gastos y presupuestos registrados.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón Cancelar
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF35844D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),

                  // Botón Restablecer
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _procesarRestablecimiento(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Restablecer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Procesa el restablecimiento de la aplicación
  Future<void> _procesarRestablecimiento(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 15),
              Text(
                'Restableciendo datos...',
                style: TextStyle(color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      await GastosDB.instance.eliminarTodosGastosYPresupuestos();
      Navigator.of(context).pop();

      // Mostrar mensaje de éxito
      messenger.showSnackBar(
        _crearSnackBar(
          icono: Icons.check_circle,
          mensaje: '¡Aplicación restablecida con éxito!',
          color: Colors.green,
        ),
      );

      // Volver a la pantalla principal
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyHomePage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      Navigator.of(context).pop();
      messenger.showSnackBar(
        _crearSnackBar(
          icono: Icons.error,
          mensaje: 'Error: ${e.toString()}',
          color: Colors.red,
        ),
      );
    }
  }

  /// Crea un SnackBar personalizado
  SnackBar _crearSnackBar({
    required IconData icono,
    required String mensaje,
    required Color color,
  }) {
    return SnackBar(
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icono, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(20),
      elevation: 6,
    );
  }

  /// Muestra un diálogo con información sobre la aplicación
  void _mostrarAcercaDe(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo/Icono de la app
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8EAD2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Título
              const Text(
                'My Cash',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),

              // Versión
              const Text(
                'Versión 1.0.0',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),

              // Descripción
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Aplicación de gestión de gastos personales que te ayuda a mantener el control de tus finanzas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Derechos de autor
              const Text(
                '© 2025 MyCash App',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 15),

              // Botón Cerrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9DD8AF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================
  // 2. INTERFAZ PRINCIPAL
  // =============================================

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
            // Botón para gestionar presupuestos
            _buildBotonOpcion(
              icono: Icons.account_balance_wallet,
              texto: 'Gestionar Presupuestos',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GestionPresupuestos()),
              ),
            ),
            const SizedBox(height: 20),
            
            // Botón para acerca de
            _buildBotonOpcion(
              icono: Icons.info_outline,
              texto: 'Acerca de',
              onPressed: () => _mostrarAcercaDe(context),
            ),
            const SizedBox(height: 20),
            
            // Botón para restablecer aplicación
            _buildBotonOpcion(
              icono: Icons.delete_forever,
              texto: 'Restablecer Aplicación',
              color: Colors.red[300],
              onPressed: () => _mostrarConfirmacionReset(context),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // 3. MÉTODOS AUXILIARES
  // =============================================

  /// Construye un botón de opción con estilo consistente
  Widget _buildBotonOpcion({
    required IconData icono,
    required String texto,
    Color? color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: _botonEstilo().copyWith(
        backgroundColor: MaterialStateProperty.all(
          color ?? const Color(0xFF9DD8AF),
        ),
      ),
      icon: Icon(icono),
      label: Text(texto, style: const TextStyle(fontSize: 20)),
    );
  }

  /// Define el estilo base para los botones
  ButtonStyle _botonEstilo() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF9DD8AF),
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}