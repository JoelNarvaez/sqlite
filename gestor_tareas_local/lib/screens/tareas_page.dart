import 'package:flutter/material.dart';

import '../data/base_datos.dart';

class TareasPage extends StatefulWidget {
  final BaseDatos baseDatos;

  const TareasPage({super.key, required this.baseDatos});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController = TextEditingController();

  // La consulta se crea una sola vez aquí y no dentro de build().
  late final Stream<List<Tarea>> _tareas;

  @override
  void initState() {
    super.initState();
    _tareas = widget.baseDatos.verTareas();
  }

  Future<void> _agregarTarea() async {
    final String titulo = _tituloController.text.trim();
    if (titulo.isEmpty) {
      _mostrarMensaje('Escribe un título para la tarea');
      return;
    }

    try {
      await widget.baseDatos.agregarTarea(titulo);
      _tituloController.clear();
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('No se pudo guardar la tarea');
    }
  }

  Future<void> _alternarCompletada(Tarea tarea, bool completada) async {
    try {
      await widget.baseDatos.cambiarEstado(tarea.id, completada);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('No se pudo actualizar la tarea');
    }
  }

  Future<void> _editarTarea(Tarea tarea) async {
    final String? nuevoTitulo = await _pedirNuevoTitulo(tarea.titulo);
    // null significa que el usuario canceló.
    if (nuevoTitulo == null) return;

    final String titulo = nuevoTitulo.trim();
    if (titulo.isEmpty) {
      _mostrarMensaje('El título no puede quedar vacío');
      return;
    }

    try {
      await widget.baseDatos.editarTitulo(tarea.id, titulo);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('No se pudo editar la tarea');
    }
  }

  Future<void> _eliminarTarea(Tarea tarea) async {
    try {
      await widget.baseDatos.eliminarTarea(tarea.id);
      if (!mounted) return;
      _mostrarMensaje('Tarea eliminada');
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('No se pudo eliminar la tarea');
    }
  }

  // Muestra un cuadro con el título actual y regresa el texto nuevo.
  Future<String?> _pedirNuevoTitulo(String tituloActual) async {
    final TextEditingController controller = TextEditingController(
      text: tituloActual,
    );

    final String? resultado = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar tarea'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Título'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return resultado;
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  void dispose() {
    _tituloController.dispose();
    // Cierra la base de datos al salir de la pantalla para liberar recursos.
    widget.baseDatos.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de tareas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _agregarTarea,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tarea'),
            ),
            const SizedBox(height: 12),
            const Text('Mis tareas', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Tarea>>(
                stream: _tareas,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('No se pudieron cargar las tareas'),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final List<Tarea> tareas = snapshot.data!;
                  if (tareas.isEmpty) {
                    return const Center(
                      child: Text('Todavía no hay tareas guardadas'),
                    );
                  }

                  return ListView.builder(
                    itemCount: tareas.length,
                    itemBuilder: (context, index) {
                      final Tarea tarea = tareas[index];
                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: tarea.completada,
                            onChanged: (valor) {
                              if (valor != null) {
                                _alternarCompletada(tarea, valor);
                              }
                            },
                          ),
                          title: Text(tarea.titulo),
                          subtitle: Text('ID: ${tarea.id}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Editar',
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editarTarea(tarea),
                              ),
                              IconButton(
                                tooltip: 'Eliminar',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _eliminarTarea(tarea),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
