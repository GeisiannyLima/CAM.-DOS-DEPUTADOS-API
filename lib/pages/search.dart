import 'Rodape.dart';
import 'package:flutter/material.dart';

import 'HomePage.dart';
import 'package:remove_diacritic/remove_diacritic.dart';

Future<List<Deputado>> buscarDeputados(String tipo) async {
  // Chamada à API para buscar todos os bioinsumos
  List<Deputado>? deputados = await fetchDeputados();

  // Converter as palavras-chave para sequências normalizadas sem acentos
  tipo = removeDiacritics(tipo);

  // Filtrar os bioinsumos pelo tipo de fertilizante e cultura
  List<Deputado>? DeputadosFiltrados = deputados
      .where((deputados) =>
          deputados.nome!.toLowerCase().contains(tipo.toLowerCase()) ||
          deputados.siglaPartido!.toLowerCase().contains(tipo.toLowerCase()) ||
          deputados.siglaUf!.toLowerCase().contains(tipo.toLowerCase()) ||
          deputados.email!.toLowerCase().contains(tipo.toLowerCase()))
      .toList();

  return DeputadosFiltrados;
}

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, required this.title}) : super(key: key);

  static const routeName = 'Pesquisa';

  final String title;

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<List<Deputado>> _futureDeputados;
  bool showSearch = false;
  bool isLoading = false;
  List<Deputado> searchResults = [];

  @override
  void initState() {
    super.initState();
  }

  void handleSearch(String searchTerm) {
    setState(() {
      isLoading = true;
    });

    buscarDeputados(searchTerm).then((results) {
      setState(() {
        isLoading = false;
        searchResults = results;
      });
    });
  }

  void clearSearch() {
    setState(() {
      showSearch = false;
      searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    final String campo = args['campo'];
    _futureDeputados = buscarDeputados(campo);
    return Scaffold(
      appBar: AppBar(
        title: showSearch
            ? TextField(
                onSubmitted: handleSearch,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Digite sua pesquisa',
                  hintStyle: TextStyle(color: Colors.black),
                ),
              )
            : Text(widget.title),
        actions: [
          if (showSearch)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: clearSearch,
            )
          else
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  showSearch = true;
                });
              },
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : searchResults.isNotEmpty
              ? DeputadosList(deputados: searchResults)
              : FutureBuilder<List<Deputado>>(
                  future: _futureDeputados,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('An error has occurred!');
                    } else if (snapshot.hasData) {
                      return DeputadosList(deputados: snapshot.data!);
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
      bottomNavigationBar: RodaPe(indiceAtual: 1),
    );
  }
}
