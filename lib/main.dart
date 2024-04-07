import 'package:flutter/material.dart';
import '../pages/comicoes.dart';
import '../pages/membros.dart';
import '../pages/HomePage.dart';
import '../pages/details.dart';
import '../pages/search.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Prova Programação Mobile';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prova Programação Mobile',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          //color: Colors.lightBlue, // cor de fundo
          foregroundColor: Colors.black, // cor do texto
          elevation: 2, // sombreamento
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(title: appTitle),
        Details.routeName: (context) => Details(),
        'Pesquisa': (context) => SearchPage(title: 'Buscas'),
        "organizacoes": (context) => Comicoes(),
        "membros": (context) => Membros(
              title: 'Membros',
            ),
      },
    );
  }
}
