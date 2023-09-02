import 'package:autistapp/apuntes/audio/apuntes_audio.dart';
import 'package:autistapp/apuntes/audio/vista_grabador_audio.dart';
import 'package:autistapp/inicio/ajustes.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VistaListaNotasVoz extends StatefulWidget {
  final Ajustes ajustes;
  const VistaListaNotasVoz({required this.ajustes});

  @override
  _VistaListaNotasVozState createState() => _VistaListaNotasVozState();
}

class _VistaListaNotasVozState extends State<VistaListaNotasVoz> {
  final listaNotasVoz = ListaNotasVoz();
  List<NotaVoz> busqueda = [];
  bool isSearch = false;

  @override
  void initState() {
    listaNotasVoz.cargarDatos().then((_) {
      setState(() {
        busqueda = listaNotasVoz.toList();
      });
    });
    super.initState();
  }

  void _filtrarBusqueda(String valor) {
    setState(() {
      if (valor.isEmpty) {
        busqueda = listaNotasVoz.toList();
      } else {
        busqueda = listaNotasVoz
            .toList()
            .where((nota) => _operadorBusqueda(nota, removeDiacritics(valor)))
            .toList();
      }
    });
  }

  bool _operadorBusqueda(NotaVoz nota, String valor) {
    if (removeDiacritics(nota.descripcion.toLowerCase()).contains(valor)) {
      return true;
    }
    //if (nota.texto.toLowerCase().contains(valor)) return true;
    if ((DateFormat('yyyy-MM-dd', "es_ES")
        .format(nota.fecha)
        .contains(valor))) {
      return true;
    }
    if (valor.toLowerCase().contains("acad") ||
        valor.toLowerCase().contains("laboral")) {
      if (nota.ambito == 0) return true;
    }
    if (valor.toLowerCase().contains("social")) {
      if (nota.ambito == 1) return true;
    }

    if (valor.toLowerCase().contains("personal")) {
      if (nota.ambito == 2) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: widget.ajustes.fgColor),
        backgroundColor: widget.ajustes.color,
        title: Text(
          'Lista de notas de voz',
          style: TextStyle(color: widget.ajustes.fgColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: widget.ajustes.fgColor,
            onPressed: () {
              setState(() {
                isSearch = !isSearch;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (isSearch) const SizedBox(height: 20),
          if (isSearch)
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value) => _filtrarBusqueda(value),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      labelText: "Busca notas...",
                      suffixIcon: const Icon(Icons.search)),
                )),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: busqueda.length,
              itemBuilder: (context, index) {
                final reversedIndex = busqueda.length - 1 - index;
                final nota = busqueda[reversedIndex];
                return ListTile(
                  title: Text(nota.descripcion),
                  subtitle: Text(
                      DateFormat('yyyy-MM-dd - EEEE - HH:mm:ss', "es_ES")
                          .format(nota.fecha)),
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) =>
                            GrabadorAudio(ajustes: widget.ajustes, nota: nota),
                      ),
                    )
                        .then((_) {
                      listaNotasVoz.cargarDatos().then((_) {
                        setState(() {
                          busqueda = listaNotasVoz.toList();
                        });
                      });
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "btn3",
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => GrabadorAudio(ajustes: widget.ajustes),
            ),
          )
              .then((_) {
            listaNotasVoz.cargarDatos().then((_) {
              setState(() {
                busqueda = listaNotasVoz.toList();
              });
            });
          });
        },
      ),
    );
  }
}
