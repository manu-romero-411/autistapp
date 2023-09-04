class NotaVoz {
  String id;
  final String audioFileName;
  final DateTime fecha;
  String descripcion;
  int mood;
  int ambito;

  NotaVoz({
    required this.id,
    required this.audioFileName,
    required this.fecha,
    this.descripcion = 'sin descripción',
    this.mood = 1,
    this.ambito = 0,
  }) {
    if (descripcion.length > 100) {
      descripcion = descripcion.substring(0, 100);
    }
  }
}
