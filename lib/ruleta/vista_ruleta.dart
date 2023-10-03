import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/ruleta/ruleta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';

class VistaRuleta extends StatefulWidget {
  final Ajustes _ajustes;
  final Ruleta _ruleta;
  final Function(Ruleta, String) _cambiarTitulo;
  final Function(Ruleta)? _eliminarRuleta;

  const VistaRuleta(
      {super.key,
      required ajustes,
      required ruleta,
      required onCambiarTitulo,
      required onDeleteRuleta})
      : _ajustes = ajustes,
        _ruleta = ruleta,
        _cambiarTitulo = onCambiarTitulo,
        _eliminarRuleta = onDeleteRuleta;

  @override
  VistaRuletaState createState() => VistaRuletaState();
}

class VistaRuletaState extends State<VistaRuleta> {
  final selected = BehaviorSubject<int>.seeded(0);
  int _itemIndex = 0;
  int _edited = -1;
  bool? isSpin;
  int? countRuleta;
  late TextEditingController _textController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: "Nuevo item");
    _nameController = TextEditingController(text: widget._ruleta.name);

    countRuleta = 0;
    isSpin = false;
    widget._ruleta.cargarDatos().then(
      (_) {
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  final colors = <Color>[
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
  ];

  void onNewItem() {
    setState(() {
      if (widget._ruleta.items.length < 2) countRuleta = 0;
      widget._ruleta.agregarItem("newItem");
      _textController.text = "Nuevo item";
      _edited = widget._ruleta.items.length - 1;
    });
  }

  void girarRuleta() {
    if (isSpin == false) {
      setState(() {
        isSpin = true;
        selected.add(
          Fortune.randomInt(0, widget._ruleta.items.length),
        );
      });
    }
  }

  void onRuletaStop() {
    selected.stream.listen((value) {
      _itemIndex = value;
    });

    setState(() {
      countRuleta = (countRuleta! + 1);
      isSpin = false;
      if (countRuleta! > 1 && isSpin != true) {
        widget._ruleta.nuevaRepeticionItem(_itemIndex);
      }
    });
  }

  void onEndEdit(String string) {
    if (_edited >= 0) {
      widget._ruleta.actualizarItem(widget._ruleta.ids[_edited], string);
    }
    _onNullEdit();
  }

  void _onNullEdit() {
    setState(() {
      _edited = -1;
    });
  }

  void _editarItem(int index) {
    setState(() {
      _edited = index;
      _textController.text = widget._ruleta.items[index];
    });
  }

  void _eliminarItem(int index) {
    setState(() {
      widget._ruleta.borrarItem(widget._ruleta.ids[index]);
    });
  }

  int valorColor(int index) {
    if (index < colors.length) {
      return index;
    } else {
      int diferencia = index - colors.length;
      if (diferencia >= colors.length) return index % colors.length;
      return ((colors.length - diferencia - 2) % colors.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: widget._ajustes.fgColor),
        backgroundColor: widget._ajustes.color,
        title: Text('Ruleta de decisiones',
            style: TextStyle(color: widget._ajustes.fgColor)),
        actions: [
          if (widget._eliminarRuleta != null)
            IconButton(
              color: widget._ajustes.fgColor,
              icon: const Icon(Icons.delete),
              onPressed: () {
                widget._eliminarRuleta!(widget._ruleta);
                if (!context.mounted) return;

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('La nota ha sido eliminada con éxito')),
                );
              },
            ),
          IconButton(
            color: widget._ajustes.fgColor,
            icon: const Icon(Icons.share),
            onPressed: () async {
              String shareString =
                  "AutistApp - Ruleta - ${widget._ruleta.name}\n\n";
              for (int i = 0; i < widget._ruleta.ids.length; ++i) {
                shareString +=
                    "* ${widget._ruleta.items[i]} => Veces que ha tocado: ${widget._ruleta.repet[i]}\n";
              }
              await Share.share(shareString);
            },
          ),
        ],
      ),
      floatingActionButton: _edited > -1
          ? null
          : widget._ruleta.ids.length > 18
              ? null
              : FloatingActionButton(
                  backgroundColor: widget._ajustes.color,
                  foregroundColor: widget._ajustes.fgColor,
                  heroTag: "newItem",
                  onPressed: onNewItem,
                  child: const Icon(Icons.add),
                ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              TextField(
                onTapOutside: (event) {
                  widget._cambiarTitulo(widget._ruleta, _nameController.text);
                },
                controller: _nameController,
                maxLength: 100,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  labelText: 'Título',
                ),
              ),
              widget._ruleta.items.length > 1
                  ? const Text(
                      "Tu resultado en la ruleta:",
                      style: TextStyle(fontSize: 18),
                    )
                  : const SizedBox(height: 0),
              widget._ruleta.items.length > 1
                  ? const SizedBox(
                      height: 20,
                    )
                  : const SizedBox(
                      height: 0,
                    ),
              widget._ruleta.items.length > 1
                  ? Text(
                      countRuleta! < 2 ||
                              isSpin == true ||
                              _itemIndex >= widget._ruleta.items.length
                          ? "????"
                          : widget._ruleta.items[_itemIndex],
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.w600),
                    )
                  : const SizedBox(height: 0),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 300, // Especifica una altura fija para el contenedor
                child: widget._ruleta.items.length > 1
                    ? Stack(
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget._ajustes.isDarkTheme
                                    ? Colors.white
                                    : Colors.black54,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(193, 1, 88, 89),
                                    blurRadius: 10.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: FortuneWheel(
                                selected: selected.stream,
                                onAnimationEnd: onRuletaStop,
                                animateFirst: false,
                                duration:
                                    Duration(seconds: countRuleta! < 1 ? 0 : 7),
                                onFling: girarRuleta,
                                indicators: [
                                  FortuneIndicator(
                                      alignment: Alignment.topCenter,
                                      child: TriangleIndicator(
                                        color: widget._ajustes.color,
                                      )),
                                ],
                                items: widget._ruleta.ids
                                    .map((it) {
                                      return FortuneItem(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 50),
                                          child: Text(
                                            widget._ruleta.items[
                                                widget._ruleta.ids.indexOf(it)],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              shadows: <Shadow>[
                                                Shadow(
                                                  offset: Offset(0.0, 0.0),
                                                  blurRadius: 3.0,
                                                  color: Color.fromARGB(
                                                      200, 0, 0, 0),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        style: FortuneItemStyle(
                                          color: colors[valorColor(
                                              widget._ruleta.ids.indexOf(it))],
                                          borderWidth: 0,
                                          borderColor: Colors.black12,
                                        ),
                                      );
                                    })
                                    .toList()
                                    .cast<FortuneItem>(),
                              )),
                          Align(
                            alignment: Alignment.center,
                            child: FloatingActionButton(
                              onPressed: girarRuleta,
                              backgroundColor: !widget._ajustes.isDarkTheme
                                  ? Colors.white
                                  : const Color.fromARGB(255, 64, 64, 64),
                              child: Icon(
                                Icons.fingerprint,
                                color: widget._ajustes.isDarkTheme
                                    ? Colors.white
                                    : const Color.fromARGB(255, 64, 64, 64),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(height: 0),
              ),
              const SizedBox(height: 30),
              const Text(
                "Lista de elementos:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget._ruleta.items.length,
                itemBuilder: (context, index) {
                  final reversedIndex = widget._ruleta.items.length - 1 - index;

                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: colors[valorColor(
                              reversedIndex)], // Cambia esto al color que desees
                          width: 2.0,
                        ),
                      ),
                    ),
                    child: reversedIndex != _edited
                        ? Dismissible(
                            key: Key(widget._ruleta.ids[reversedIndex]),
                            direction:
                                DismissDirection.startToEnd, // Añade esta línea

                            background: Container(
                                color: const Color.fromARGB(176, 213, 14, 0),
                                child: const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 16),
                                        Icon(Icons.delete),
                                      ],
                                    ))),
                            onDismissed: (direction) {
                              if (direction == DismissDirection.startToEnd) {
                                _eliminarItem(reversedIndex);
                              }
                            },
                            child: ListTile(
                                title:
                                    Text(widget._ruleta.items[reversedIndex]),
                                subtitle: Text(
                                    "Ha tocado ${widget._ruleta.repet[reversedIndex].toString()} ve${widget._ruleta.repet[reversedIndex] == 1 ? "z" : "ces"}"),
                                onTap: () {
                                  _editarItem(reversedIndex);
                                },
                                leading: const Icon(Icons.casino_outlined)),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _textController,
                              maxLines: 1,
                              maxLength: 42,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                labelText: 'Elemento',
                                hintText: "Nombre del elemento",
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.save),
                                  onPressed: () {
                                    onEndEdit(_textController.text);
                                  },
                                ),
                              ),
                              onSubmitted: (event) {
                                onEndEdit(_textController.text);
                              },
                              onTapOutside: (event) {
                                _onNullEdit();
                              },
                            )),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
