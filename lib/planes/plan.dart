class Plan {
  String _id;
  String _nombre;
  int _horaInicio;
  int _minInicio;
  int _horaFin;
  int _minFin;
  int _tipo;

  String get id => _id;

  set id(String value) => _id = value;

  get nombre => _nombre;

  set nombre(value) => _nombre = value;

  get horaInicio => _horaInicio;

  set horaInicio(value) => _horaInicio = value;

  get minInicio => _minInicio;

  set minInicio(value) => _minInicio = value;

  get horaFin => _horaFin;

  set horaFin(value) => _horaFin = value;

  get minFin => _minFin;

  set minFin(value) => _minFin = value;

  get tipo => _tipo;

  set tipo(value) => _tipo = value;

  Plan({
    required id,
    required nombre,
    required horaInicio,
    required minInicio,
    required horaFin,
    required minFin,
    required tipo,
  })  : _tipo = tipo,
        _nombre = nombre,
        _id = id,
        _horaInicio = horaInicio,
        _horaFin = horaFin,
        _minInicio = minInicio,
        _minFin = minFin {
    if (_nombre.length > 100) {
      _nombre = _nombre.substring(0, 100);
    }
  }
}
