import "package:flutter/material.dart";
import 'componentes/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'MiFuente'),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}
