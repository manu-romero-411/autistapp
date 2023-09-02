import 'package:autistapp/inicio/ajustes.dart';
import 'package:flutter/material.dart';

class VistaAjustes extends StatefulWidget {
  final Function(Color) onColorSelected;
  final Ajustes ajustes;

  const VistaAjustes({required this.ajustes, required this.onColorSelected});

  @override
  _VistaAjustesState createState() => _VistaAjustesState();
}

class _VistaAjustesState extends State<VistaAjustes> {
  late TextEditingController _textController;
  bool _notificationsEnabled = false;
  String _frequency = '1 hora';

  Color? selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.ajustes.color;
    _textController = TextEditingController(text: widget.ajustes.name);
  }

  @override
  void dispose() {
    widget.ajustes.name = _textController.text;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: widget.ajustes.fgColor,
          onPressed: () {
            setState(() {
              widget.ajustes.name = _textController.text;
              Navigator.pop(context);
            });
          },
        ),
        centerTitle: true,
        backgroundColor: widget.ajustes.color,
        title: Text("Ajustes", style: TextStyle(color: widget.ajustes.fgColor)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(
            height: 28,
          ),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nombre',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    )
                  ])),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _textController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  labelText: 'Texto',
                  hintText: "Introduce tu nombre aquí"),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Habilitar notificaciones',
                  style: TextStyle(fontSize: 16),
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
          ),
          if (_notificationsEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Frecuencia', style: TextStyle(fontSize: 16)),
                  DropdownButton<String>(
                    value: _frequency,
                    onChanged: (String? newValue) {
                      setState(() {
                        _frequency = newValue!;
                      });
                    },
                    items: <String>['1 hora', '2 horas', '3 horas']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          const SizedBox(
            height: 20,
          ),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Colores de la app',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              )),
          const SizedBox(
            height: 20,
          ),
          ColorSelectionGrid(
              ajustes: widget.ajustes, onColorSelected: widget.onColorSelected),
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
