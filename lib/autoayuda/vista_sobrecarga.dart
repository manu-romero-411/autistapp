import 'package:autistapp/autoayuda/vista_auto_ayuda.dart';
import 'package:autistapp/inicio/ajustes.dart';
import 'package:flutter/material.dart';

class VistaSobrecarga extends StatefulWidget {
  final Ajustes _ajustes;
  const VistaSobrecarga({Key? key, required Ajustes ajustes})
      : _ajustes = ajustes,
        super(key: key);

  @override
  _VistaSobrecargaState createState() => _VistaSobrecargaState();
}

class _VistaSobrecargaState extends State<VistaSobrecarga> {
  List<Widget> _pages = [];
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _pages = [
      const VistaDiapos(
        imagePath: "assets/images/check.png",
        title: "¡Todo en marcha!",
        content: "aaa",
      ),
      const VistaDiapos(
        imagePath: "assets/images/check.png",
        title: "¡Todo en marcha!",
        content: "aaa",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sobrecarga",
          style: TextStyle(color: widget._ajustes.fgColor),
        ),
        backgroundColor: widget._ajustes.color,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
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
              heroTag: "sobrecarga",
              onPressed: () {
                if (_currentPage == _pages.length - 1) {
                  setState(() {
                    Navigator.pop(context);
                  });
                } else {
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
    );
  }
}
