import 'comicoes.dart';
import 'search.dart';
import 'package:flutter/material.dart';

class RodaPe extends StatefulWidget {
  final int indiceAtual;

  RodaPe({Key? key, required this.indiceAtual}) : super(key: key);

  @override
  State<RodaPe> createState() => _RodaPeState();
}

class _RodaPeState extends State<RodaPe> {
  late int _indiceAtual;

  @override
  void initState() {
    super.initState();
    _indiceAtual = widget.indiceAtual;
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = MediaQuery.of(context).size.width * 0.08;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.07,
      child: BottomNavigationBar(
        currentIndex: _indiceAtual,
        onTap: onTabTapped,
        iconSize: iconSize,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: iconSize - 5,
            ),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: iconSize - 5,
            ),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.book,
              size: iconSize - 5,
            ),
            label: 'Comições',
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _indiceAtual = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (Route<dynamic> route) => false,
        );
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(
          context,
          SearchPage.routeName,
          arguments: {
            'campo': '',
          },
          (Route<dynamic> route) => false,
        );
        break;
      case 2:
        Navigator.pushNamedAndRemoveUntil(
          context,
          Comicoes.routeName,
          (Route<dynamic> route) => false,
        );
        break;
    }
  }
}
