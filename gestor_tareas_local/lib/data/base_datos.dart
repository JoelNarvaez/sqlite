import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'base_datos.g.dart';

// Tabla de tareas. A partir de esta clase Drift genera la clase Tarea
// (una fila de la tabla) en base_datos.g.dart.
class Tareas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text()();
  // SQLite lo guarda como 0 (pendiente) o 1 (completada).
  BoolColumn get completada => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tareas])
class BaseDatos extends _$BaseDatos {
  // Si no recibe una conexión, abre la base guardada en el dispositivo.
  // En las pruebas se le pasa una base en memoria.
  BaseDatos([QueryExecutor? conexion]) : super(conexion ?? _abrirConexion());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _abrirConexion() {
    return driftDatabase(name: 'tareas_db');
  }

  // Regresa todas las tareas y vuelve a avisar cada vez que la tabla cambia.
  Stream<List<Tarea>> verTareas() {
    return select(tareas).watch();
  }

  Future<int> agregarTarea(String titulo) {
    return into(tareas).insert(TareasCompanion.insert(titulo: titulo));
  }
}
