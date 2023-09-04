import 'dart:async';
import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/inicio/vista_ajustes.dart';
import 'package:flutter/material.dart';

class PantallaBienvenida extends StatefulWidget {
  final Ajustes ajustes;
  final Function(Color) onColorSelected;
  final ValueChanged<String> onThemeChanged;

  const PantallaBienvenida(
      {super.key,
      required this.ajustes,
      required this.onColorSelected,
      required this.onThemeChanged});

  @override
  _PantallaBienvenidaState createState() => _PantallaBienvenidaState();
}

class _PantallaBienvenidaState extends State<PantallaBienvenida> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  final List<Color> _rainbowColors = [
    Colors.purple,
    Colors.indigo,
    Colors.blue,
    Colors.green,
    Colors.amber,
    Colors.orange,
    Colors.red,
  ];
  int _currentColorIndex = 0;
  Timer? _colorTimer;

  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    widget.ajustes.cargarDatos().then((_) {
      setState(() {
        widget.onThemeChanged(widget.ajustes.theme);
      });
    });
    _pages = [
      const WelcomePage(
        imagePath: "assets/images/infinity_loop_white.png",
        title: "¡Hola!",
        content:
            "autistApp es una aplicación que para ayudar a las personas autistas (TEA) con su día a día, gestión de tiempos y tareas, toma de apuntes para un buen registro de las situaciones personales, auxilio ante adversidades, etc. Su finalidad es complementar las terapias psicológicas con profesionales.",
      ),
      ColorPage(
        ajustes: widget.ajustes,
        onColorSelected: widget.onColorSelected,
        onThemeChanged: widget.onThemeChanged,
      ),
      const WelcomePage(
        imagePath: "assets/images/check.png",
        title: "¡Todo en marcha!",
        content: "aaa",
      ),
    ];

    _colorTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        _currentColorIndex = (_currentColorIndex + 1) % _rainbowColors.length;
      });
    });
  }

  @override
  void dispose() {
    _colorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(seconds: 10),
        color: _rainbowColors[_currentColorIndex],
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _pages[index];
              },
            ),
            Positioned(
              bottom: 20.0,
              right: 20.0,
              child: FloatingActionButton(
                onPressed: () {
                  if (_currentPage == _pages.length - 1) {
                    setState(() {
                      widget.ajustes.welcome = false;
                      Navigator.pushReplacementNamed(context, '/home');
                    });
                  } else {
                    // Avanzar a la siguiente página
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Icon(_currentPage == _pages.length - 1
                    ? Icons.check
                    : Icons.arrow_forward),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  final String _title;
  final String _content;
  final String _imagePath;

  const WelcomePage({
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
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
                child: Text(_content,
                    style: const TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }
}

class ColorPage extends StatefulWidget {
  final Ajustes ajustes;
  final Function(Color) onColorSelected;
  final ValueChanged<String> onThemeChanged;

  const ColorPage(
      {super.key,
      required this.ajustes,
      required this.onColorSelected,
      required this.onThemeChanged});

  @override
  _ColorPageState createState() => _ColorPageState();
}

class _ColorPageState extends State<ColorPage> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    widget.ajustes.cargarDatos();
    setState(() {
      _textController = TextEditingController(text: widget.ajustes.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 100,
          ),
          const Text(
            "Tu nombre:",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onTapOutside: (event) {
                widget.ajustes.name = _textController.text;
              },
              controller: _textController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  labelText: 'Texto',
                  hintText: "Introduce tu nombre aquí"),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          const Text(
            "Selecciona un color:",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ColorSelectionGrid(
              ajustes: widget.ajustes, onColorSelected: widget.onColorSelected),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
