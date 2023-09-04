class NotaTexto {
  String id;
  String titulo;
  final DateTime fecha;
  String texto;
  int mood;
  int ambito;

  NotaTexto({
    required this.id,
    required this.titulo,
    required this.fecha,
    this.texto = '',
    this.mood = 1,
    this.ambito = 0,
  }) {
    if (titulo.length > 100) {
      titulo = titulo.substring(0, 100);
    }
  }
}
