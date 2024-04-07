import 'dart:convert';
import 'Rodape.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'details.dart';
import 'search.dart';

class Deputados {
  List<Deputado>? dados;

  Deputados({this.dados});

  Deputados.fromJson(Map<String, dynamic> json) {
    if (json['dados'] != null) {
      dados = <Deputado>[];
      json['dados'].forEach((v) {
        dados!.add(Deputado.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.dados != null) {
      data['dados'] = this.dados!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Deputado {
  int? id;
  String? uri;
  String? nome;
  String? siglaPartido;
  String? uriPartido;
  String? siglaUf;
  int? idLegislatura;
  String? urlFoto;
  String? email;

  Deputado({
    this.id,
    this.uri,
    this.nome,
    this.siglaPartido,
    this.uriPartido,
    this.siglaUf,
    this.idLegislatura,
    this.urlFoto,
    this.email,
  });

  Deputado.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uri = json['uri'];
    nome = json['nome'];
    siglaPartido = json['siglaPartido'];
    uriPartido = json['uriPartido'];
    siglaUf = json['siglaUf'];
    idLegislatura = json['idLegislatura'];
    urlFoto = json['urlFoto'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uri'] = this.uri;
    data['nome'] = this.nome;
    data['siglaPartido'] = this.siglaPartido;
    data['uriPartido'] = this.uriPartido;
    data['siglaUf'] = this.siglaUf;
    data['idLegislatura'] = this.idLegislatura;
    data['urlFoto'] = this.urlFoto;
    data['email'] = this.email;
    return data;
  }
}

Future<List<Deputado>> fetchDeputados() async {
  final response = await http
      .get(Uri.parse('https://dadosabertos.camara.leg.br/api/v2/deputados'));

  if (response.statusCode == 200) {
    final jsonDecoded = jsonDecode(response.body);
    final deputadosJson = jsonDecoded['dados'] as List<dynamic>;

    return deputadosJson.map((json) => Deputado.fromJson(json)).toList();
  } else {
    throw Exception('Failed to fetch deputados');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  static const routeName = '/';
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Deputado>> _futureDeputados;
  bool showSearch = false;
  @override
  void initState() {
    super.initState();
    _futureDeputados = fetchDeputados();
  }

  bool searchVisible = false;
  TextEditingController searchController = TextEditingController();

  void handleSearch(String searchTerm) {
    // Aqui você pode implementar a lógica para realizar a pesquisa
    Navigator.pushNamed(
      context,
      SearchPage.routeName,
      arguments: {
        'campo': searchTerm,
      },
    );
    // Atualize o estado, se necessário
  }

  void clearSearch() {
    setState(() {
      showSearch = false;
      searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showSearch
            ? TextField(
                onSubmitted: handleSearch,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Digite sua pesquisa',
                  hintStyle: TextStyle(color: Colors.white70),
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
      body: FutureBuilder<List<Deputado>>(
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
      bottomNavigationBar: RodaPe(indiceAtual: 0),
    );
  }
}

class DeputadosList extends StatelessWidget {
  const DeputadosList({Key? key, required this.deputados}) : super(key: key);

  final List<Deputado> deputados;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 1,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              'Deputados',
              style: TextStyle(fontSize: 30),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.99,
            height: MediaQuery.of(context).size.height * 0.80,
            child: ListView.builder(
              itemCount: deputados.length,
              itemBuilder: (context, index) {
                final deputado = deputados[index];
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.20,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.70,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 216, 216, 216),
                              ),
                              onPressed: () => Navigator.pushNamed(
                                context,
                                Details.routeName,
                                arguments: {
                                  'id': deputados[index].id,
                                  'nome': deputados[index].nome,
                                  'siglaPartido': deputados[index].siglaPartido,
                                  'siglaUf': deputados[index].siglaUf,
                                  'urlFoto': deputados[index].urlFoto,
                                  'email': deputados[index].email,
                                },
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    child: Image.network(
                                      "${deputado.urlFoto}",
                                      width: MediaQuery.of(context).size.width *
                                          0.26,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.13,
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${deputado.nome}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Color.fromRGBO(0, 0, 0, 0.7),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "${deputado.siglaPartido}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Color.fromRGBO(0, 0, 0, 0.7),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
