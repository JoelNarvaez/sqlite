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
    // Se guarda lo que se escribe en una variable en lugar de usar un
    // controller, porque el cuadro todavía se dibuja mientras se cierra.
    String textoEscrito = tituloActual;

    final String? resultado = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar tarea'),
          content: TextFormField(
            initialValue: tituloActual,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Título'),
            onChanged: (valor) {
              textoEscrito = valor;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, textoEscrito),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Gestor de tareas',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Organiza tus pendientes',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Nueva tarea',
                  hintText: '¿Qué necesitas hacer?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _agregarTarea,
                icon: const Icon(Icons.add),
                label: const Text('Agregar tarea'),
              ),
              const SizedBox(height: 16),
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

                    // Cuenta cuántas tareas están completadas.
                    int completadas = 0;
                    for (Tarea tarea in tareas) {
                      if (tarea.completada) {
                        completadas++;
                      }
                    }
                    final int pendientes = tareas.length - completadas;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Mis tareas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              avatar: const Icon(Icons.schedule, size: 18),
                              label: Text('Pendientes: $pendientes'),
                              backgroundColor: const Color(0xFFFFEFD2),
                              side: BorderSide.none,
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              avatar: const Icon(Icons.check_circle, size: 18),
                              label: Text('Completadas: $completadas'),
                              backgroundColor: const Color(0xFFD3EEEA),
                              side: BorderSide.none,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(child: _listaTareas(tareas)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listaTareas(List<Tarea> tareas) {
    if (tareas.isEmpty) {
      return const Center(child: Text('Todavía no hay tareas guardadas'));
    }

    return ListView.builder(
      itemCount: tareas.length,
      itemBuilder: (context, index) {
        final Tarea tarea = tareas[index];
        return Card(
          color: Colors.white,
          elevation: 0,
          child: ListTile(
            leading: Checkbox(
              value: tarea.completada,
              onChanged: (valor) {
                if (valor != null) {
                  _alternarCompletada(tarea, valor);
                }
              },
            ),
            title: Text(
              tarea.titulo,
              style: TextStyle(
                decoration: tarea.completada
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            subtitle: Text(tarea.completada ? 'Completada' : 'Pendiente'),
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
  }
}
