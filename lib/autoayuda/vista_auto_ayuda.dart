import 'package:autistapp/autoayuda/vista_sobrecarga.dart';
import 'package:autistapp/inicio/ajustes.dart';
import 'package:flutter/material.dart';

class VistaAyuda extends StatefulWidget {
  final Ajustes _ajustes;
  const VistaAyuda({Key? key, required Ajustes ajustes})
      : _ajustes = ajustes,
        super(key: key);

  @override
  _VistaAyudaState createState() => _VistaAyudaState();
}

class _VistaAyudaState extends State<VistaAyuda> {
  void sobrecarga() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => VistaSobrecarga(ajustes: widget._ajustes),
      ),
    )
        .then((_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "¿Necesitas ayuda?",
          style: TextStyle(color: widget._ajustes.fgColor),
        ),
        backgroundColor: widget._ajustes.color,
        leading: BackButton(color: widget._ajustes.fgColor),
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: BuildCard(
                  title: 'Estoy teniendo una sobrecarga sensorial/emocional',
                  icon: Icons.sentiment_very_dissatisfied,
                  onPressed: sobrecarga)),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: BuildCard(
                  title: 'Estoy teniendo dificultades con la gente',
                  icon: Icons.group,
                  onPressed: sobrecarga)),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: BuildCard(
                  title: 'Me está costando planificarme.',
                  icon: Icons.event_busy,
                  onPressed: sobrecarga)),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: BuildCard(
                  title: 'Me ha ocurrido un imprevisto',
                  icon: Icons.error,
                  onPressed: sobrecarga)),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
      // Aquí puedes construir tu interfaz de usuario
    );
  }
}

class BuildCard extends StatelessWidget {
  final String _title;
  final IconData _icon;
  Function() _onPressed;

  BuildCard({required title, required icon, required onPressed})
      : _title = title,
        _icon = icon,
        _onPressed = onPressed;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        leading: Icon(_icon),
        title: Text(_title),
        onTap: _onPressed,
      ),
    );
  }
}

class VistaDiapos extends StatelessWidget {
  final String _title;
  final String _content;
  final String _imagePath;

  const VistaDiapos({
    super.key,
    required String title,
    required String content,
    required String imagePath,
  })  : _content = content,
        _title = title,
        _imagePath = imagePath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return FittedBox(
                    fit: BoxFit.cover,
                    child: Image.asset(
                      _imagePath,
                      width: 200,
                      height: 200,
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Text(
                _title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(child: Text(_content)),
          ],
        ),
      ),
    );
  }
}
