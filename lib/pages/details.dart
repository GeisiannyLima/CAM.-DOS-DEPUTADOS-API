import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Atividade {
  String? dataHoraInicio;
  String? dataHoraFim;
  String? situacao;
  String? descricao;

  Atividade(
      {required this.dataHoraInicio,
      required this.dataHoraFim,
      required this.situacao,
      required this.descricao});

  Atividade.fromJson(Map<String, dynamic> json) {
    dataHoraInicio = json['dataHoraInicio'];
    dataHoraFim = json['dataHoraFim'];
    situacao = json['situacao'];
    descricao = json['descricao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dataHoraInicio'] = this.dataHoraInicio;
    data['dataHoraFim'] = this.dataHoraFim;
    data['situacao'] = this.situacao;
    data['descricao'] = this.descricao;
    return data;
  }
}

class Despesas {
  List<Despesa>? dados;

  Despesas({this.dados});

  Despesas.fromJson(Map<String, dynamic> json) {
    if (json['dados'] != null) {
      dados = <Despesa>[];
      json['dados'].forEach((v2) {
        dados!.add(Despesa.fromJson(v2));
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

class Despesa {
  String? tipoDespesa;
  double? valorDespesa;

  Despesa({required this.tipoDespesa, required this.valorDespesa});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tipoDespesa'] = this.tipoDespesa;
    data['valorDocumento'] = this.valorDespesa;
    return data;
  }

  Despesa.fromJson(Map<String, dynamic> json) {
    tipoDespesa = json['tipoDespesa'];
    valorDespesa = json['valorDocumento'];
  }
}

Future<List<Despesa>> fetchDespesas(int? id) async {
  final response = await http.get(Uri.parse(
      'https://dadosabertos.camara.leg.br/api/v2/deputados/${id}/despesas?ordem=ASC&ordenarPor=mes'));

  if (response.statusCode == 200) {
    final jsonDecoded = jsonDecode(response.body);
    final despesaJson = jsonDecoded['dados'] as List<dynamic>;

    return despesaJson.map((json) => Despesa.fromJson(json)).toList();
  } else {
    throw Exception('Failed to fetch deputados');
  }
}

Future<List<Atividade>> fetchAtividades(int? id) async {
  final response = await http.get(Uri.parse(
      'https://dadosabertos.camara.leg.br/api/v2/deputados/${id}/eventos?ordem=ASC&ordenarPor=dataHoraInicio'));

  if (response.statusCode == 200) {
    final jsonDecoded = jsonDecode(response.body);
    final AtividadeJson = jsonDecoded['dados'] as List<dynamic>;

    return AtividadeJson.map((json) => Atividade.fromJson(json)).toList();
  } else {
    throw Exception('Failed to fetch deputados');
  }
}

class Atividades extends StatefulWidget {
  const Atividades({super.key, this.id});
  final int? id;
  @override
  State<Atividades> createState() => _AtividadesState();
}

class _AtividadesState extends State<Atividades> {
  late Future<List<Atividade>> _futureAtividade;
  @override
  void initState() {
    super.initState();
    _futureAtividade = fetchAtividades(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Atividade>>(
      future: _futureAtividade,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('An error has occurred: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return MostraAtividades(atividades: snapshot.data!);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class MostraAtividades extends StatelessWidget {
  const MostraAtividades({super.key, required this.atividades});
  final List<Atividade> atividades;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color.fromRGBO(0, 0, 0, 0.5),
          ),
        ),
      ),
      width: MediaQuery.of(context).size.width * 0.74,
      height: MediaQuery.of(context).size.width * 0.55,
      child: ListView.builder(
        itemCount: atividades.length,
        itemBuilder: (context, index) {
          final ativdd = atividades[index];
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.5)))),
            child: Column(
              children: [
                Text(
                  "Descrição: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
                Text("${ativdd.descricao}"),
                Text(
                  "Início: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
                Text("${ativdd.dataHoraInicio}"),
                Text(
                  "Fim: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("${ativdd.dataHoraFim}"),
                Text(
                  "Situação: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
                Text("${ativdd.situacao}"),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Details extends StatelessWidget {
  const Details({super.key});
  static const routeName = 'details';

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    final String? nome = args['nome'];
    final int? id = args['id'];
    final String? siglaPartido = args['siglaPartido'];
    final String? siglaUf = args['siglaUf'];
    final String? urlFoto = args['urlFoto'];
    final String? email = args['email'];
    return Scaffold(
      appBar: AppBar(
        title: Text('${nome}'),
      ),
      body: Container(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              color: Color.fromRGBO(0, 0, 0, 0.5),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.78,
              height: MediaQuery.of(context).size.width * 1.28,
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.20,
                      margin: EdgeInsets.only(top: 20),
                      child: ClipOval(
                        child: Image.network(
                          "${urlFoto}",
                          width: MediaQuery.of(context).size.width * 0.28,
                          height: MediaQuery.of(context).size.height * 0.10,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.74,
                      child: Container(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 30),
                              width: MediaQuery.of(context).size.width * 0.37,
                              child: widget_descricao('Nome:', 0, nome),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 30),
                              width: MediaQuery.of(context).size.width * 0.37,
                              child: widget_descricao('UF:', 0, siglaUf),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color.fromRGBO(0, 0, 0, 0.5),
                          ),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width * 0.74,
                      child: Container(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: Color.fromRGBO(0, 0, 0, 0.5),
                                  ),
                                ),
                              ),
                              width: MediaQuery.of(context).size.width * 0.37,
                              child:
                                  widget_descricao('Partido:', 0, siglaPartido),
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(left: 8, top: 10),
                              width: MediaQuery.of(context).size.width * 0.37,
                              child: widget_descricao('E-mail:', 0, email),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 10, top: 10),
                      child: Text(
                        "Gastos",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Gastos(id: id),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Atividades recentes'),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Atividades(
                                      id: id,
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: Text('Fechar'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.history),
                      label: Text('Histórico'),
                      style: ButtonStyle(
                        textStyle: MaterialStateProperty.all<TextStyle>(
                            TextStyle(fontSize: 20)),
                        iconSize: MaterialStateProperty.all<double>(28),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

widget_descricao(String? texto, double distancia, String? valor) {
  return Container(
    margin: EdgeInsets.only(top: distancia),
    child: Column(
      children: [
        Text(
          "${texto}",
          style: TextStyle(fontSize: 17),
        ),
        Text(
          '${valor}',
          style: TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    ),
  );
}

class Gastos extends StatefulWidget {
  final int? id;
  const Gastos({super.key, this.id});

  @override
  State<Gastos> createState() => _GastosState();
}

class _GastosState extends State<Gastos> {
  late Future<List<Despesa>> _futureDespesa;
  @override
  void initState() {
    super.initState();
    _futureDespesa = fetchDespesas(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Despesa>>(
      future: _futureDespesa,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('An error has occurred!');
        } else if (snapshot.hasData) {
          return MostraGasto(despesas: snapshot.data!);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class MostraGasto extends StatelessWidget {
  const MostraGasto({super.key, required this.despesas});
  final List<Despesa> despesas;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color.fromRGBO(0, 0, 0, 0.5),
          ),
        ),
      ),
      width: MediaQuery.of(context).size.width * 0.74,
      height: MediaQuery.of(context).size.width * 0.35,
      child: ListView.builder(
        itemCount: despesas.length,
        itemBuilder: (context, index) {
          final gasto = despesas[index];
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.5)))),
            child: Column(
              children: [
                Text(
                  "Serviço: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
                Text("${gasto.tipoDespesa}"),
                Text(
                  "Custo: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("R\$ ${gasto.valorDespesa},00"),
              ],
            ),
          );
        },
      ),
    );
  }
}
