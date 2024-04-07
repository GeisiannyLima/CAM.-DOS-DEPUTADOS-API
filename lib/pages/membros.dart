import 'Rodape.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'HomePage.dart';
import 'details.dart';
import 'search.dart';
import 'package:http/http.dart' as http;

class Membro {
  int? id;
  int? codTitulo;
  int? idLegislatura;
  String? nome;
  String? uf;
  String? siglaPartido;
  String? urlFoto;
  String? email;
  Membro(
      {required this.id,
      required this.codTitulo,
      required this.idLegislatura,
      required this.nome,
      required this.siglaPartido,
      required this.uf,
      required this.urlFoto,
      required this.email});
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['codTitulo'] = this.codTitulo;
    data['idLegislatura'] = this.idLegislatura;
    data['nome'] = this.nome;
    data['siglaPartido'] = this.siglaPartido;
    data['siglaUf'] = this.uf;
    data['urlFoto'] = this.urlFoto;
    data['email'] = this.email;
    return data;
  }

  Membro.fromJson(Map<String, dynamic> json) {
    codTitulo = json['codTitulo'];
    idLegislatura = json['idLegislatura'];
    id = json['id'];
    uf = json['siglaUf'];
    siglaPartido = json['siglaPartido'];
    nome = json['nome'];
    urlFoto = json['urlFoto'];
    email = json['email'];
  }
}

Future<List<Membro>> fetchMembros(int? id) async {
  final response = await http.get(Uri.parse(
      'https://dadosabertos.camara.leg.br/api/v2/orgaos/${id}/membros'));

  if (response.statusCode == 200) {
    final jsonDecoded = jsonDecode(response.body);
    final despesaJson = jsonDecoded['dados'] as List<dynamic>;

    return despesaJson.map((json) => Membro.fromJson(json)).toList();
  } else {
    throw Exception('Failed to fetch deputados');
  }
}

class Membros extends StatefulWidget {
  const Membros({Key? key, required this.title}) : super(key: key);

  static const routeName = 'membros';

  final String title;

  @override
  _MembrosState createState() => _MembrosState();
}

class _MembrosState extends State<Membros> {
  late Future<List<Membro>> _futureMembros;
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
    final int id = args['id'];
    _futureMembros = fetchMembros(id);
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
      body: FutureBuilder<List<Membro>>(
        future: _futureMembros,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('An error has occurred!');
          } else if (snapshot.hasData) {
            return MembrosList(membros: snapshot.data!);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: RodaPe(indiceAtual: 2),
    );
  }
}

class MembrosList extends StatelessWidget {
  const MembrosList({Key? key, required this.membros}) : super(key: key);

  final List<Membro> membros;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Text(
            'Comições',
            style: TextStyle(fontSize: 30),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.99,
          height: MediaQuery.of(context).size.height * 0.80,
          child: ListView.builder(
            itemCount: membros.length,
            itemBuilder: (context, index) {
              final membro = membros[index];
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
                                'id': membros[index].id,
                                'nome': membros[index].nome,
                                'siglaPartido': membros[index].siglaPartido,
                                'siglaUf': membros[index].uf,
                                'urlFoto': membros[index].urlFoto,
                                'email': membros[index].email,
                              },
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    "${membro.urlFoto}",
                                    width: MediaQuery.of(context).size.width *
                                        0.26,
                                    height: MediaQuery.of(context).size.height *
                                        0.13,
                                    alignment: Alignment.center,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${membro.nome}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color.fromRGBO(0, 0, 0, 0.7),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "${membro.siglaPartido}",
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
    );
  }
}
