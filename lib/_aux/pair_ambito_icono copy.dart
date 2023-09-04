import 'package:flutter/material.dart';

class RutinaGenerador {
  final String _nombre;
  final IconData _icono;
  final int? _hora;
  final int? _minuto;
  final String _emoji;

  RutinaGenerador(
      {required String nombre,
      required IconData icono,
      required String emoji,
      hora,
      minuto})
      : _icono = icono,
        _nombre = nombre,
        _emoji = emoji,
        _hora = hora,
        _minuto = minuto;

  get nombre => _nombre;
  get icono => _icono;
  get emoji => _emoji;
  get hora => _hora;
  get minuto => _minuto;
}
