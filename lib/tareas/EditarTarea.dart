import 'package:autistapp/tareas/tarea.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class EditorTareas extends StatefulWidget {
  final Tarea? tarea;

  const EditorTareas({this.tarea});
  @override
  _EditorTareasState createState() => _EditorTareasState();

  // ...
}

class _EditorTareasState extends State<EditorTareas> {
  final listaTareas = ListaTareas();

  late TextEditingController _nombreController;
  late TextEditingController _intervaloController;

  late String _id;
  late DateTime _fechaInicio;
  late DateTime? _fechaFin;
  late DateTime? _fechaLimite;
  late int _tipo;
  late int _prioridad;
  late bool _repite;
  late int _unidad;
  late bool _completada;

  @override
  void initState() {
    _nombreController = TextEditingController(text: widget.tarea?.nombre);
    _intervaloController =
        TextEditingController(text: widget.tarea?.intervalo.toString());

    if (widget.tarea != null) {
      _id = widget.tarea?.id;
      _nombreController.text = widget.tarea?.nombre;
      _fechaInicio = widget.tarea?.fechaInicio;
      _fechaFin = widget.tarea?.fechaFin;
      _tipo = widget.tarea?.tipo;
      _prioridad = widget.tarea?.prioridad;
      _repite = widget.tarea?.repite;
      _intervaloController.text = widget.tarea!.intervalo.toString();
      _unidad = widget.tarea?.unidad;
      _completada = widget.tarea?.completada;
    } else {
      _id = const Uuid().v4();
      _nombreController.text = "Nueva tarea";
      _fechaInicio = DateTime.now();
      _fechaFin = DateTime(DateTime.now().year + 99);
      _fechaLimite = DateTime(DateTime.now().year + 99);
      _tipo = 0;
      _prioridad = 1;
      _repite = false;
      _intervaloController.text = "1";
      _unidad = 0;
      _completada = false;
    }

    listaTareas.cargarDatos().then((_) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nota de texto'),
        actions: [
          if (widget.tarea != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                listaTareas.eliminarTarea(widget.tarea?.id);
                Navigator.of(context).pop();
              },
            ),
          if (widget.tarea != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                await Share.share(
                    "AutistApp - ¡TENGO QUE HACER ESTA TAREA!: \n📝 Nombre: ${_nombreController.text} \n📅 Fecha en que se programó: ${DateFormat('yyyy-MM-dd - EEEE - HH:mm', 'es_ES').format(_fechaInicio!)}\n📅 Fecha límite: ${DateFormat('yyyy-MM-dd - EEEE - HH:mm', 'es_ES').format(_fechaLimite!)}\n*️⃣ Ámbito: ${_tipo == 0 ? '📚⛏ Académico/Laboral' : _tipo == 1 ? '🗣 Social' : '😇 Personal'}\n🚧 Prioridad: ${_prioridad == 0 ? '🟢 Baja' : _prioridad == 1 ? '🟡 Media' : '🔴 ¡Alta!'}\n");
              },
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              listaTareas.agregarTarea(
                  _id,
                  _nombreController.text,
                  _fechaFin!,
                  _tipo,
                  _prioridad,
                  _repite,
                  int.parse(_intervaloController.text),
                  _unidad,
                  _completada);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _nombreController,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          DropdownButtonFormField<int>(
            value: _tipo,
            items: const [
              DropdownMenuItem(value: 0, child: Text('Académico/laboral')),
              DropdownMenuItem(value: 1, child: Text('Social')),
              DropdownMenuItem(value: 2, child: Text('Personal')),
            ],
            onChanged: (value) => setState(() => _tipo = value!),
            decoration: const InputDecoration(labelText: 'Tipo'),
          ),
          const SizedBox(height: 16),
          const Text('Prioridad'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _prioridad = 0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _prioridad == 0 ? Colors.green : Colors.grey,
                ),
                child: const Text('Baja'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _prioridad = 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _prioridad == 1 ? Colors.orange : Colors.grey,
                ),
                child: const Text('Media'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _prioridad = 2),
                child: const Text('Alta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _prioridad == 2 ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
          SwitchListTile(
            title: const Text('Repetir periódicamente'),
            value: _repite,
            onChanged: (value) => setState(() => _repite = value),
          ),
          if (_repite)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _intervaloController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Intervalo'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _unidad,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Días')),
                      DropdownMenuItem(value: 1, child: Text('Semanas')),
                      DropdownMenuItem(value: 2, child: Text('Meses')),
                    ],
                    onChanged: (value) => setState(() => _unidad = value!),
                    decoration: const InputDecoration(labelText: 'Unidad'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
