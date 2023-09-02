class Tarea {
  String _id;
  String _nombre;
  DateTime _fechaInicio;
  DateTime? _fechaFin = DateTime(DateTime.now().year + 99);
  int _tipo;
  int _prioridad;
  bool _repite;
  int _intervalo;
  int _unidad;
  bool _completada;

  get id => _id;

  set id(final value) => _id = value;

  get nombre => _nombre;

  set nombre(value) => _nombre = value;

  get fechaInicio => _fechaInicio;

  set fechaInicio(value) => _fechaInicio = value;

  get fechaFin => _fechaFin;

  set fechaFin(value) => _fechaFin = value;

  get tipo => _tipo;

  set tipo(value) => _tipo = value;

  get prioridad => _prioridad;

  set prioridad(value) => _prioridad = value;

  get repite => _repite;

  set repite(value) => _repite = value;

  get intervalo => _intervalo;

  set intervalo(value) => _intervalo = value;

  get unidad => _unidad;

  set unidad(value) => _unidad = value;

  get completada => _completada;

  set completada(value) => _completada = value;

  Tarea({
    required String id,
    required String nombre,
    required DateTime fechaInicio,
    required DateTime? fechaFin,
    required int tipo,
    required int prioridad,
    required bool repite,
    required int intervalo,
    required int unidad,
    required bool completada,
  })  : _completada = completada,
        _unidad = unidad,
        _intervalo = intervalo,
        _repite = repite,
        _prioridad = prioridad,
        _tipo = tipo,
        _fechaFin = fechaFin,
        _fechaInicio = fechaInicio,
        _nombre = nombre,
        _id = id {
    if (_nombre.length > 100) {
      _nombre = _nombre.substring(0, 100);
    }
  }
}
