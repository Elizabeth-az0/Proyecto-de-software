import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:MyCash/componentes/home/home_page.dart';
import 'package:MyCash/database/gastos_db.dart';

// Observador de rutas para seguimiento de navegación
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

/// Función principal que inicia la aplicación
void main() async {
  // Inicialización obligatoria de Flutter antes de cualquier operación
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración de la base de datos
  await _initializeDatabase();

  // Configuración de internacionalización (i18n)
  await _initializeLocalization();

  // Inicio de la aplicación
  runApp(const MyApp());
}

/// Inicializa y configura la base de datos de gastos
/// 
/// Crea la base de datos si no existe y verifica/crea las tablas necesarias
Future<void> _initializeDatabase() async {
  final db = GastosDB.instance;
  await db.database; // Crea la base de datos si no existe
  await db.asegurarEstructura(); // Verifica/crea las tablas necesarias
}

/// Configura la localización e internacionalización
/// 
/// Establece el formato de fechas en español y configura el idioma predeterminado
Future<void> _initializeLocalization() async {
  await initializeDateFormatting('es'); // Formato de fechas en español
  Intl.defaultLocale = 'es'; // Establece español como idioma predeterminado
}

/// Widget principal de la aplicación que configura el MaterialApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyCash',
      theme: _buildAppTheme(),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
      localizationsDelegates: _getLocalizationDelegates(),
      supportedLocales: _getSupportedLocales(),
      builder: _appBuilder,
      navigatorObservers: [routeObserver],
    );
  }

  /// Construye el tema visual de la aplicación
  /// 
  /// Configura la fuente personalizada, esquema de colores basado en verde
  /// y habilita Material 3
  ThemeData _buildAppTheme() {
    return ThemeData(
      fontFamily: 'MiFuente',
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      useMaterial3: true,
    );
  }

  /// Proporciona los delegados de localización necesarios
  /// 
  /// Incluye soporte para Material, Widgets y Cupertino localizations
  List<LocalizationsDelegate> _getLocalizationDelegates() {
    return const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];
  }

  /// Define los idiomas soportados por la aplicación
  /// 
  /// Actualmente soporta español e inglés
  List<Locale> _getSupportedLocales() {
    return const [
      Locale('es', ''), // Español
      Locale('en', ''), // Inglés
    ];
  }

  /// Builder personalizado para la aplicación
  /// 
  /// Configura:
  /// - Escalado de texto fijo (evita cambios por configuración del sistema)
  /// - GestureDetector para ocultar teclado al tocar fuera de campos de texto
  Widget _appBuilder(BuildContext context, Widget? child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        // ignore: deprecated_member_use
        textScaleFactor:
            1.0, // Evita escalado de texto por configuración del sistema
      ),
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            // Oculta el teclado cuando se toca fuera de un campo de texto
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: child!,
        ),
      ),
    );
  }
}