class NotaTexto {
  String _id;
  String _titulo;
  final DateTime _fecha;
  String _texto;
  int _mood;
  int _ambito;

  NotaTexto({
    required String id,
    required String titulo,
    required DateTime fecha,
    String texto = 'sin descripción',
    int mood = 1,
    int ambito = 0,
  })  : _id = id,
        _titulo = titulo,
        _fecha = fecha,
        _texto = texto,
        _mood = mood,
        _ambito = ambito {
    if (titulo.length > 100) {
      titulo = titulo.substring(0, 100);
    }
  }

  get id => _id;
  set id(value) => _id = value;

  get titulo => _titulo;
  set titulo(value) => _titulo = value;

  get fecha => _fecha;

  get texto => _texto;
  set texto(value) => _texto = value;

  get mood => _mood;
  set mood(value) => _mood = value;

  get ambito => _ambito;
  set ambito(value) => _ambito = value;
}
