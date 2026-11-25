import 'package:flutter/material.dart';

import 'data/base_datos.dart';
import 'screens/tareas_page.dart';

void main() {
  runApp(GestorTareasApp(baseDatos: BaseDatos()));
}

/// Punto de entrada de la aplicación.
/// Recibe la base de datos para poder usar una en memoria en las pruebas.
class GestorTareasApp extends StatelessWidget {
  final BaseDatos baseDatos;

  const GestorTareasApp({super.key, required this.baseDatos});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00796B)),
        scaffoldBackgroundColor: const Color(0xFFF1F7F6),
        useMaterial3: true,
      ),
      home: TareasPage(baseDatos: baseDatos),
    );
  }
}
