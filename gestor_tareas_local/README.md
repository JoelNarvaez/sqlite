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

## Cómo está organizado

- `lib/data/base_datos.dart`: aquí está la tabla y las funciones para agregar, ver, editar, marcar y borrar tareas.
- `lib/data/base_datos.g.dart`: lo genera Drift, no se edita a mano.
- `lib/screens/tareas_page.dart`: la pantalla. La lista escucha la base con un `Stream`, así que se actualiza sola después de cada cambio.
- `web/sqlite3.wasm` y `web/drift_worker.js`: los necesita el navegador para usar SQLite. Los bajé del release `drift-2.35.4` en GitHub, que es la misma versión de Drift del proyecto.

## Cómo correrla

```bash
git clone https://github.com/JoelNarvaez/sqlite.git
cd sqlite
flutter pub get
flutter run -d chrome --web-port 8080
```

Uso un puerto fijo porque el navegador guarda los datos por dirección. Si cada vez se abre en un puerto distinto, parece que se borraron las tareas.

Para Windows uso `flutter run -d windows` (hay que tener activado el Modo de desarrollador de Windows). Para otro dispositivo cambio `chrome` por uno de los que salen en `flutter devices`.

Si cambio la tabla tengo que volver a generar el código de Drift:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Pruebas automatizadas

Se corren con `flutter test`. Todas usan una base en memoria, así que no tocan las tareas reales.

- **La pantalla inicial se muestra sin errores**: abre la app y revisa que estén el título, el campo de texto y el botón.
- **No se agrega una tarea con título vacío**: escribe solo espacios, presiona agregar y revisa que salga el aviso y que la lista siga vacía.
- **Agregar una tarea la guarda como pendiente**: guarda una tarea y revisa que se lea con el mismo título y sin completar.
- **Editar, completar y eliminar una tarea**: cambia el título, la marca como completada y luego la borra, revisando la base después de cada paso.

## Pruebas manuales

| Prueba | Qué hice | Windows | Chrome |
|--------|----------|---------|--------|
| P1 | Agregar 3 tareas, cerrar la app y abrirla | Sí. Las 3 tareas siguieron ahí | Sí. Las 3 tareas siguieron ahí |
| P2 | Marcar una como completada y reiniciar | Sí. Siguió marcada | Sí. Siguió marcada |
| P3 | Cambiar el título de una tarea y reiniciar | Sí. Se quedó el título nuevo | Sí. Se quedó el título nuevo |
| P4 | Eliminar una tarea y reiniciar | Sí. No volvió a aparecer | Sí. No volvió a aparecer |
| P5 | Intentar agregar un título vacío | Sí. Salió el aviso y no se agregó | Sí. Salió el aviso y no se agregó |
| P6 | Recargar y cerrar/abrir la pestaña | Si, los datos persisten | Sí. Los datos se conservaron |

## Plataformas

- **Probadas:** Windows, Chrome y Android.
- **Previstas pero no probadas:** iOS, Linux y macOS. El código es el mismo y `drift_flutter` se encarga de abrir la base en cada una.
