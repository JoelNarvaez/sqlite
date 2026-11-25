import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/base_datos.dart';

void main() {
  late BaseDatos baseDatos;

  // Cada prueba usa una base nueva en memoria.
  setUp(() {
    baseDatos = BaseDatos(NativeDatabase.memory());
  });

  tearDown(() async {
    await baseDatos.close();
  });

  test('Agregar una tarea la guarda como pendiente', () async {
    await baseDatos.agregarTarea('Estudiar SQLite');

    final List<Tarea> tareas = await baseDatos.verTareas().first;
    expect(tareas.length, 1);
    expect(tareas[0].titulo, 'Estudiar SQLite');
    expect(tareas[0].completada, false);
  });

  test('Editar, completar y eliminar una tarea', () async {
    final int id = await baseDatos.agregarTarea('Titulo viejo');

    await baseDatos.editarTitulo(id, 'Titulo nuevo');
    await baseDatos.cambiarEstado(id, true);

    List<Tarea> tareas = await baseDatos.verTareas().first;
    expect(tareas[0].titulo, 'Titulo nuevo');
    expect(tareas[0].completada, true);

    await baseDatos.eliminarTarea(id);

    tareas = await baseDatos.verTareas().first;
    expect(tareas.isEmpty, true);
  });
}
