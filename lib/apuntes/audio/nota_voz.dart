class NotaVoz {
  String _id;
  final String _audioFileName;
  final DateTime _fecha;
  String _descripcion;
  int _mood;
  int _ambito;

  NotaVoz({
    required String id,
    required String audioFileName,
    required DateTime fecha,
    String descripcion = 'sin descripción',
    int mood = 1,
    int ambito = 0,
  })  : _ambito = ambito,
        _mood = mood,
        _descripcion = descripcion,
        _fecha = fecha,
        _audioFileName = audioFileName,
        _id = id {
    if (_descripcion.length > 100) {
      _descripcion = _descripcion.substring(0, 100);
    }
  }

  get id => _id;
  set id(value) => _id = value;
  get audioFileName => _audioFileName;
  get fecha => _fecha;
  get descripcion => _descripcion;
  set descripcion(value) => _descripcion = value;
  get mood => _mood;
  set mood(value) => _mood = value;
  get ambito => _ambito;
  set ambito(value) => _ambito = value;
}
