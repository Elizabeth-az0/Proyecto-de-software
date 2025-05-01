import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_cash/database/gastos_db.dart';

class AgregarGasto extends StatefulWidget {
  const AgregarGasto({super.key});

  @override
  _AgregarGastoState createState() => _AgregarGastoState();
}

class _AgregarGastoState extends State<AgregarGasto> {
  final _tituloController = TextEditingController();
  final _costoController = TextEditingController();
  final _fechaController = TextEditingController();
  String _categoria = 'Comida';
  DateTime _fecha = DateTime.now();

  final List<String> _categorias = [
    'Comida',
    'Entretenimiento',
    'Compras',
    'Salud',
    'Transporte',
    'Otros',
  ];

  // Variables para personalizar colores y bordes
  final Color _backgroundColor = Color(0xFFD4F4E4); // Fondo de la app
  final Color _inputFieldColor = Color(
    0xFFE3F5E8,
  ); // Color del fondo de los campos de texto
  final Color _buttonColor = Color(0xFF9DD8AF); // Color de fondo del botón
  final Color _textColor = Colors.black; // Color de los textos
  final Color _labelTextColor =
      Colors.grey; // Color de los textos de las etiquetas
  final OutlineInputBorder _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: const Color(0xFFE3F5E8), width: 1.5),
  );

  // Nuevas variables para personalizar el dropdown
  final Color _dropdownBackgroundColor = Color(
    0xFFF5FFFA,
  ); // Color de fondo del menú desplegable
  final Color _dropdownItemColor = Color(
    0xFFE3F5E8,
  ); // Color de fondo de cada ítem

  // Mapa de íconos para cada categoría
  final Map<String, IconData> _categoriaIconos = {
    'Comida': Icons.restaurant,
    'Entretenimiento': Icons.movie,
    'Compras': Icons.shopping_cart,
    'Salud': Icons.medical_services,
    'Transporte': Icons.directions_car,
    'Otros': Icons.more_horiz,
  };

  @override
  void initState() {
    super.initState();
    _fechaController.text = DateFormat('yyyy-MM-dd').format(_fecha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agregar Gasto',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: _backgroundColor,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Título del gasto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: 'Título',
                labelStyle: TextStyle(color: _labelTextColor),
                filled: true,
                fillColor: _inputFieldColor,
                border: _inputBorder,
                enabledBorder: _inputBorder.copyWith(
                  borderSide: BorderSide(
                    color: const Color(0xFF0e2517),
                    width: 2.0,
                  ),
                ),
                focusedBorder: _inputBorder.copyWith(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Costo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _costoController,
              decoration: InputDecoration(
                labelText: '\$\$\$',
                labelStyle: TextStyle(color: _labelTextColor),
                filled: true,
                fillColor: _inputFieldColor,
                border: _inputBorder,
                enabledBorder: _inputBorder.copyWith(
                  borderSide: BorderSide(
                    color: const Color(0xFF0e2517),
                    width: 2.0,
                  ),
                ),
                focusedBorder: _inputBorder.copyWith(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text(
              'Categoría',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _categoria,
              dropdownColor: _dropdownBackgroundColor,
              icon: Icon(Icons.arrow_drop_down, color: _textColor),
              iconSize: 30,
              elevation: 4,
              style: TextStyle(color: _textColor, fontSize: 16.0),
              decoration: InputDecoration(
                filled: true,
                fillColor: _inputFieldColor,
                border: _inputBorder,
                enabledBorder: _inputBorder.copyWith(
                  borderSide: BorderSide(
                    color: const Color(0xFF0e2517),
                    width: 2.0,
                  ),
                ),
                focusedBorder: _inputBorder.copyWith(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _categoria = newValue!;
                });
              },
              items:
                  _categorias.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: MouseRegion(
                        onHover: (_) => setState(() {}),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: _dropdownItemColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _categoriaIconos[value],
                                color: _textColor,
                                size: 24.0,
                              ),
                              SizedBox(width: 10),
                              Text(
                                value,
                                style: TextStyle(
                                  color: _textColor,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
              selectedItemBuilder: (BuildContext context) {
                return _categorias.map<Widget>((String value) {
                  return Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _categoriaIconos[value],
                          color: _textColor,
                          size: 24.0,
                        ),
                        SizedBox(width: 20),
                        Text(
                          value,
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Fecha',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fechaController,
              decoration: InputDecoration(
                labelText: 'YYYY-MM-DD',
                labelStyle: TextStyle(color: _labelTextColor),
                filled: true,
                fillColor: _inputFieldColor,
                border: _inputBorder,
                enabledBorder: _inputBorder.copyWith(
                  borderSide: BorderSide(
                    color: const Color(0xFF0e2517),
                    width: 2.0,
                  ),
                ),
                focusedBorder: _inputBorder.copyWith(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
              ),
              keyboardType: TextInputType.datetime,
              onChanged: (String value) {
                setState(() {
                  try {
                    _fecha = DateFormat('yyyy-MM-dd').parseStrict(value);
                  } catch (e) {
                    // Si la fecha no es válida, mantenemos la fecha original
                  }
                });
              },
            ),
            const SizedBox(height: 90),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final titulo = _tituloController.text;
                  final costo = double.tryParse(_costoController.text) ?? 0.0;
                  if (titulo.isEmpty || costo <= 0.0) return;

                  final gasto = {
                    'titulo': titulo,
                    'costo': costo,
                    'categoria': _categoria,
                    'fecha': DateFormat('yyyy-MM-dd').format(_fecha),
                  };

                  await GastosDB.instance.insertarGasto(gasto);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonColor,
                  foregroundColor: const Color(
                    0xFF0E2517,
                  ), // Cambia el color del texto del botón
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
