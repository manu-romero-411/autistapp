import 'package:autistapp/inicio/ajustes.dart';
import 'package:flutter/material.dart';

class VistaAjustes extends StatefulWidget {
  final Function(Color) _onColorSelected;
  final Function() _onChangedAjustes;
  final Ajustes _ajustes;

  const VistaAjustes(
      {required Ajustes ajustes,
      required dynamic Function(Color) onColorSelected,
      required onChangedAjustes})
      : _ajustes = ajustes,
        _onColorSelected = onColorSelected,
        _onChangedAjustes = onChangedAjustes;

  @override
  _VistaAjustesState createState() => _VistaAjustesState();
}

class _VistaAjustesState extends State<VistaAjustes> {
  late TextEditingController _textController;
  bool _notificationsEnabled = false;
  String _frequency = '1 hora';

  Color? selectedColor;
  int? _horaMin;
  int? _horaMax;

  @override
  void initState() {
    super.initState();
    _horaMin = widget._ajustes.minHoraGantt;
    _horaMax = widget._ajustes.maxHoraGantt;

    selectedColor = widget._ajustes.color;
    _textController = TextEditingController(text: widget._ajustes.name);
  }

  void guardarSalir() {
    setState(() {
      if (_horaMax! <= _horaMin!) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'ERROR: La hora de fin no puede ser más temprana que la de inicio.')),
        );
      } else {
        widget._ajustes.name = _textController.text;
        widget._ajustes.minHoraGantt = _horaMin;
        widget._ajustes.maxHoraGantt = _horaMax;
        widget._onChangedAjustes();
        if (!context.mounted) return;

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ajustes guardados correctamente')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: widget._ajustes.fgColor,
        ),
        centerTitle: true,
        backgroundColor: widget._ajustes.color,
        title:
            Text("Ajustes", style: TextStyle(color: widget._ajustes.fgColor)),
        elevation: 0,
        actions: [
          IconButton(
            color: widget._ajustes.fgColor,
            icon: const Icon(Icons.save),
            onPressed: guardarSalir,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(height: 16),
          const Text(
            "Tus datos personales",
            style: TextStyle(fontSize: 16),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 20, left: 16, right: 16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    const Icon(Icons.person),
                    const SizedBox(width: 10),
                    const Text(
                      'Nombre',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          labelText: 'Texto',
                          hintText: "Introduce tu nombre aquí",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Text(
            "Tablas de planificaciones",
            style: TextStyle(fontSize: 16),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 20, left: 16, right: 16),
            child: Card(
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.schedule),
                          SizedBox(width: 10),
                          Text(
                            'Hora inicial',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      DropdownButton<int>(
                        value: _horaMin,
                        onChanged: (int? newValue) {
                          setState(() {
                            _horaMin = newValue!;
                          });
                        },
                        items: List.generate(24, (index) => index)
                            .map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text("$value:00"),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.schedule),
                          SizedBox(width: 10),
                          Text(
                            'Hora final',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      DropdownButton<int>(
                        value: _horaMax,
                        onChanged: (int? newValue) {
                          setState(() {
                            _horaMax = newValue!;
                          });
                        },
                        items: List.generate(24, (index) => index)
                            .map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text("$value:00"),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ),
          const Text(
            "Notificaciones",
            style: TextStyle(fontSize: 16),
          ),
          Padding(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 20, left: 16, right: 16),
              child: Card(
                child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.notifications),
                              SizedBox(width: 10),
                              Text(
                                'Notificaciones',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Switch(
                            value: _notificationsEnabled,
                            onChanged: (bool newValue) {
                              setState(() {
                                _notificationsEnabled = newValue;
                              });
                            },
                          ),
                        ],
                      ),
                      if (_notificationsEnabled)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.hourglass_bottom),
                                SizedBox(width: 10),
                                Text(
                                  'Frecuencia',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            DropdownButton<String>(
                              value: _frequency,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _frequency = newValue!;
                                });
                              },
                              items: <String>[
                                '1 hora',
                                '2 horas',
                                '3 horas'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              )),
          const Text(
            "Colores de la app",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(
            height: 20,
          ),
          ColorSelectionGrid(
              ajustes: widget._ajustes,
              onColorSelected: widget._onColorSelected),
          const SizedBox(
            height: 24,
          ),
        ]),
      ),
    );
  }
}

/**/

class ColorSelectionGrid extends StatefulWidget {
  final Ajustes ajustes;
  final Function(Color) onColorSelected;

  ColorSelectionGrid({required this.ajustes, required this.onColorSelected});
  @override
  _ColorSelectionGridState createState() => _ColorSelectionGridState();
}

class _ColorSelectionGridState extends State<ColorSelectionGrid> {
  Color? _selectedColor;

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedColor = widget.ajustes.color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.ajustes.colors.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, crossAxisSpacing: 20, mainAxisSpacing: 20),
        itemBuilder: (context, index) {
          final color = widget.ajustes.colors[index];
          return GestureDetector(
            onTap: () => setState(() {
              _selectedColor = color;
              widget.onColorSelected(color);
            }),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: _selectedColor == color
                      ? Border.all(width: 3, color: Colors.cyanAccent)
                      : null),
            ),
          );
        },
      ),
    );
  }
}
