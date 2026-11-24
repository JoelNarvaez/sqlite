# Gestor de tareas local

Es una app en Flutter para guardar tareas: puedo agregarlas, verlas, cambiarles el título, marcarlas como completadas y borrarlas. Todo se guarda en una base de datos SQLite dentro del mismo dispositivo, así que no necesita internet ni un servidor.

Práctica de Programación de Dispositivos Móviles — UAA, 7.º semestre.

## ¿Qué usé para guardar los datos?

Usé **Drift** con **drift_flutter**.

Lo elegí porque con el mismo código funciona en Android, iOS, Windows, Linux, macOS y en el navegador. Además, Drift me deja escuchar los cambios de la tabla, entonces cuando agrego o borro una tarea la lista se actualiza sola.

También vi `sqflite`, pero para Windows, Linux y web hay que agregar otros paquetes y configurarlos aparte. `shared_preferences` no me servía porque no es una base de datos SQLite.

## La tabla

Solo tengo una tabla llamada `tareas`:

| Columna      | Tipo    | Para qué es |
|--------------|---------|-------------|
| `id`         | INTEGER | El número de cada tarea. Se genera solo y no se repite. |
| `titulo`     | TEXT    | El nombre de la tarea. No puede ir vacío. |
| `completada` | INTEGER | SQLite no tiene booleanos, así que uso `0` para pendiente y `1` para completada. Empieza en `0`. |

## Cómo correrla

```bash
flutter pub get
flutter run -d chrome
```

Si quiero probar en otro dispositivo, cambio `chrome` por uno de los que salen en `flutter devices`.
