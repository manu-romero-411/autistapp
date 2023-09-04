import 'package:flutter/material.dart';

class PairAmbitoIcono {
  final String _ambito;
  final IconData _icono;
  final Color _color;
  final String _emoji;
  PairAmbitoIcono(
      {required String ambito,
      required IconData icono,
      required Color color,
      required String emoji})
      : _icono = icono,
        _ambito = ambito,
        _color = color,
        _emoji = emoji;

  get ambito => _ambito;
  get icono => _icono;
  get color => _color;
  get emoji => _emoji;
}
