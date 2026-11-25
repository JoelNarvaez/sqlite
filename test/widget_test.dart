import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/base_datos.dart';
import 'package:gestor_tareas_local/main.dart';

void main() {
  testWidgets('La pantalla inicial se muestra sin errores', (tester) async {
    // Base en memoria para no tocar la base real del dispositivo.
    final BaseDatos baseDatos = BaseDatos(NativeDatabase.memory());

    await tester.pumpWidget(GestorTareasApp(baseDatos: baseDatos));
    expect(find.text('Gestor de tareas'), findsOneWidget);
    expect(find.text('Agregar tarea'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Quita la pantalla y deja que Drift termine de cerrar la consulta.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });

  testWidgets('No se agrega una tarea con título vacío', (tester) async {
    final BaseDatos baseDatos = BaseDatos(NativeDatabase.memory());

    await tester.pumpWidget(GestorTareasApp(baseDatos: baseDatos));
    await tester.pumpAndSettle();

    // Un título solo con espacios también cuenta como vacío.
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Agregar tarea'));
    await tester.pump();

    expect(find.text('Escribe un título para la tarea'), findsOneWidget);
    expect(find.text('Todavía no hay tareas guardadas'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
