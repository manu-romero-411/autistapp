import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/planes/lista_planes.dart';
import 'package:autistapp/planes/plan.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class EditorPlanes extends StatefulWidget {
  final Plan? plan;
  final Ajustes _ajustes;
  final Function() _onChangePlanes;
  final ListaPlanes _listaPlanes;
  const EditorPlanes(
      {super.key,
      this.plan,
      required ajustes,
      required onChangePlanes,
      required listaPlanes})
      : _ajustes = ajustes,
        _listaPlanes = listaPlanes,
        _onChangePlanes = onChangePlanes;
  @override
  EditorPlanesState createState() => EditorPlanesState();
}

class EditorPlanesState extends State<EditorPlanes> {
  late TextEditingController _descController;
  late int _horaInicioController;
  late int _minInicioController;
  late int _horaFinController;
  late int _minFinController;

  late int _tipo;
  late String _id;

  @override
  void initState() {
    super.initState();

    widget._listaPlanes.cargarDatos();

    if (widget.plan != null) {
      _id = widget.plan!.id;
      _tipo = widget.plan!.tipo;
      _descController = TextEditingController(text: widget.plan!.nombre);
      _horaInicioController = widget.plan!.horaInicio;
      _minInicioController = widget.plan!.minInicio;
      _horaFinController = widget.plan!.horaFin;
      _minFinController = widget.plan!.minFin;
    } else {
      _id = const Uuid().v4();
      _tipo = 0;
      _descController = TextEditingController(text: "");
      _horaInicioController = 8;
      _minInicioController = 00;
      _horaFinController = 9;
      _minFinController = 00;
    }

    if (widget.plan != null) {
      _descController.text = widget.plan!.nombre;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: widget._ajustes.fgColor,
        ),
        backgroundColor: widget._ajustes.color,
        title: Text('Plan', style: TextStyle(color: widget._ajustes.fgColor)),
        actions: [
          if (widget.plan != null)
            IconButton(
              color: widget._ajustes.fgColor,
              icon: const Icon(Icons.delete),
              onPressed: () {
                widget._listaPlanes.eliminarTarea(widget.plan!.id);
                widget._onChangePlanes();
                if (!context.mounted) return;

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('El plan ha sido eliminado con éxito')),
                );
              },
            ),
          IconButton(
            color: widget._ajustes.fgColor,
            icon: const Icon(Icons.save),
            onPressed: () {
              widget._onChangePlanes();
              if (_horaInicioController > _horaFinController ||
                  (_horaInicioController == _horaFinController &&
                      _minInicioController >= _minFinController)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'La hora de inicio no puede ser igual o superior a la hora de fin'),
                ));
              } else {
                widget._listaPlanes.agregarTarea(
                    _id,
                    _descController.text,
                    _tipo,
                    _horaInicioController,
                    _minInicioController,
                    _horaFinController,
                    _minFinController);
                if (!context.mounted) return;

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'El plan ha sido ${(widget.plan != null) ? 'editado' : 'creado'} con éxito')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 24),
              TextField(
                controller: _descController,
                maxLength: 100,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  labelText: 'Nombre',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Ámbito vital:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
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
                            ? widget._ajustes.listaAmbitos[i].color
                            : const Color.fromARGB(255, 212, 222, 219),
                        heroTag: "boton$i",
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
              const SizedBox(height: 20),
              const Text(
                "Hora de inicio:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton<int>(
                    value: _horaInicioController,
                    onChanged: (int? newValue) {
                      setState(() {
                        _horaInicioController = newValue!;
                      });
                    },
                    items: List.generate(24, (index) => index)
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  ),
                  const Text(':'),
                  DropdownButton<int>(
                    value: _minInicioController,
                    onChanged: (int? newValue) {
                      setState(() {
                        _minInicioController = newValue!;
                      });
                    },
                    items: List.generate(12, (index) => index * 5)
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString().padLeft(2, '0')),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Hora de finalización:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton<int>(
                    value: _horaFinController,
                    onChanged: (int? newValue) {
                      setState(() {
                        _horaFinController = newValue!;
                      });
                    },
                    items: List.generate(24, (index) => index)
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  ),
                  const Text(':'),
                  DropdownButton<int>(
                    value: _minFinController,
                    onChanged: (int? newValue) {
                      setState(() {
                        _minFinController = newValue!;
                      });
                    },
                    items: List.generate(12, (index) => index * 5)
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString().padLeft(2, '0')),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
