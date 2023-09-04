import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/tareas/lista_tareas.dart';
import 'package:autistapp/tareas/tarea.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class EditorTareas extends StatefulWidget {
  final Tarea? _tarea;
  final Ajustes _ajustes;
  final ListaTareas _listaTareas;
  final Function() _onUpdateTareas;

  const EditorTareas(
      {Tarea? tarea,
      required Ajustes ajustes,
      required listaTareas,
      required onUpdateTareas})
      : _tarea = tarea,
        _ajustes = ajustes,
        _listaTareas = listaTareas,
        _onUpdateTareas = onUpdateTareas;
  @override
  _EditorTareasState createState() => _EditorTareasState();

  // ...
}

class _EditorTareasState extends State<EditorTareas> {
  late TextEditingController _nombreController;
  late TextEditingController _intervaloController;

  late String _id;
  late DateTime _fechaInicio;
  late DateTime? _fechaFin;
  //late DateTime? _fechaLimite;
  late int _tipo;
  late int _prioridad;
  late bool _repite;
  late int _unidad;
  late bool _completada;

  @override
  void initState() {
    _nombreController = TextEditingController(text: widget._tarea?.nombre);
    _intervaloController =
        TextEditingController(text: widget._tarea?.intervalo.toString());

    if (widget._tarea != null) {
      _id = widget._tarea?.id;
      _nombreController.text = widget._tarea?.nombre;
      _fechaInicio = widget._tarea?.fechaInicio;
      _fechaFin = widget._tarea?.fechaFin;
      _tipo = widget._tarea?.tipo;
      _prioridad = widget._tarea?.prioridad;
      _repite = widget._tarea?.repite;
      _intervaloController.text = widget._tarea!.intervalo.toString();
      _unidad = widget._tarea?.unidad;
      _completada = widget._tarea?.completada;
    } else {
      _id = const Uuid().v4();
      _nombreController.text = "Nueva tarea";
      _fechaInicio = DateTime.now();
      _fechaFin = DateTime(DateTime.now().year + 99);
      //_fechaLimite = DateTime(DateTime.now().year + 99);
      _tipo = 0;
      _prioridad = 1;
      _repite = false;
      _intervaloController.text = "1";
      _unidad = 0;
      _completada = false;
    }

    widget._listaTareas.cargarDatos().then((_) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: widget._ajustes.fgColor),
        backgroundColor: widget._ajustes.color,
        title: Text('Editar tarea',
            style: TextStyle(color: widget._ajustes.fgColor)),
        actions: [
          if (widget._tarea != null)
            IconButton(
              color: widget._ajustes.fgColor,
              icon: const Icon(Icons.delete),
              onPressed: () {
                widget._listaTareas.eliminarTarea(widget._tarea?.id);
                Navigator.of(context).pop();
              },
            ),
          if (widget._tarea != null)
            IconButton(
              color: widget._ajustes.fgColor,
              icon: const Icon(Icons.share),
              onPressed: () async {
                await Share.share(
                    "AutistApp - ¡TENGO QUE HACER ESTA TAREA!: \n📝 Nombre: ${_nombreController.text} \n📅 Fecha en que se programó: ${DateFormat('yyyy-MM-dd - EEEE - HH:mm', 'es_ES').format(_fechaInicio)}\n*️⃣ Ámbito: ${widget._ajustes.listaAmbitos[_tipo].emoji} ${widget._ajustes.listaAmbitos[_tipo].ambito}\n🚧 Prioridad: ${widget._ajustes.prioridadesEmoji[_tipo]}\n");
              },
            ),
          IconButton(
            color: widget._ajustes.fgColor,
            icon: const Icon(Icons.save),
            onPressed: () {
              widget._listaTareas.agregarTarea(
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  labelText: 'Nombre'),
            ),
            const SizedBox(height: 24),
            const Text(
              "Ámbito vital:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              widget._ajustes.getTextoAmbito(_tipo),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < widget._ajustes.listaAmbitos.length; ++i)
                  Row(children: [
                    if (i > 0) const SizedBox(width: 16),
                    FloatingActionButton(
                      backgroundColor: _tipo == i
                          ? Colors.blueAccent
                          : const Color.fromARGB(255, 212, 222, 219),
                      heroTag: "ambito$i",
                      onPressed: () async {
                        setState(() {
                          _tipo = i;
                        });
                      },
                      child: widget._ajustes.getIconoAmbitoBoton(i, _tipo),
                    ),
                  ]),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Prioridad:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              widget._ajustes.getTextoPrioridad(_prioridad),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0;
                    i < widget._ajustes.prioridadesColor.length;
                    ++i)
                  Row(children: [
                    if (i > 0) const SizedBox(width: 16),
                    FloatingActionButton(
                      backgroundColor: _prioridad == i
                          ? widget._ajustes.prioridadesColor[i]
                          : const Color.fromARGB(255, 212, 222, 219),
                      heroTag: "prio$i",
                      onPressed: () async {
                        setState(() {
                          _prioridad = i;
                        });
                      },
                      child: Icon(
                        widget._ajustes.prioridadesIcono[i],
                        color: _prioridad == i ? Colors.white : Colors.black,
                      ),
                    ),
                  ]),
              ],
            ),
            /*
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
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          labelText: 'Intervalo'),
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
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          labelText: 'Unidad'),
                    ),
                  ),
                ],
              ),*/
            const SizedBox(
              height: 24,
            ),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        "Puedes establecer el ámbito y la prioridad de cada tarea para ayudarte a organizarlas mejor.\n\nLa aplicación te notificará periódicamente para que entres a ver qué tareas y rutinas tienes pendientes. Haz primero las más laboriosas/importantes y después harás con más ánimo las demás.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                )),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
