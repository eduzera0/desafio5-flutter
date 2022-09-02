import 'package:biblioteca_flutter/entities/tipoimovel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:http/http.dart' as http;



import 'package:biblioteca_flutter/modules/login/pages/login_page.dart';
import 'package:biblioteca_flutter/config/api.dart';

import '../../../entities/tipoimovel.dart';

class TipoImovelPage extends StatefulWidget {
  const TipoImovelPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _TipoImovelPageState();
}

Future<List<TipoImovelData>> _fetchTipoImovel() async {
  const url = '$baseURL/tipos-imoveis';
  final preferences = await SharedPreferences.getInstance();
  final token = preferences.getString('auth_token');
  Map<String, String> headers = {};
  headers["Authorization"] = 'Bearer $token';
  final response = await http.get(Uri.parse(url), headers: headers);
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
    return jsonResponse.map((tipoimovel) => TipoImovelData.fromJson(tipoimovel)).toList();
  } else {
    Fluttertoast.showToast(
        msg: 'Erro ao listar os tipos de imóveis!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        fontSize: 20.0
    );
    throw('Sem Tipos de Imóveis');
  }
}

class _TipoImovelPageState extends State<TipoImovelPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future <List<TipoImovelData>> futureTipoImovel;

  @override
  void initState() {
    super.initState();
    futureTipoImovel = _fetchTipoImovel();
  }

  void submit(String action, TipoImovelData tipoimovelData) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (tipoimovelData.nome == "") {
        Fluttertoast.showToast(
            msg: 'Por favor, informe o nome!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            fontSize: 20.0
        );
      } else {
        if (action == "adicionar") {
          _adicionarTipoImovel(tipoimovelData);
        } else {
          _editarTipoImovel(tipoimovelData);
        }
      }
    }
  }

  void _adicionarTipoImovel(TipoImovelData tipoimovelData) async {
    const url = '$baseURL/tipos-imoveis';
    var body = json.encode({'nome': tipoimovelData.nome});
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('auth_token');
    Map<String, String> headers = {};
    headers["Content-Type"] = "application/json";
    headers["Authorization"] = 'Bearer $token';
    try {
      final response = await http
          .post(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: 'Tipo Imóvel Adicionado!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            fontSize: 20.0
        );
        futureTipoImovel = _fetchTipoImovel();
      } else {
        Fluttertoast.showToast(
            msg: 'Erro ao editar o tipo imóvel!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            fontSize: 20.0
        );
      }
    } on Object catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  void _editarTipoImovel(TipoImovelData tipoimovelData) async {
    var id = tipoimovelData.id;
    var url = '$baseURL/tipos-imoveis/$id';
    var body = json.encode({
        'nome': tipoimovelData.nome,
      });
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('auth_token');
    Map<String, String> headers = {};
    headers["Content-Type"] = "application/json";
    headers["Authorization"] = 'Bearer $token';
    try {
      final response = await http
          .put(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: 'Tipo Imóvel Editado!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            fontSize: 20.0
        );
        futureTipoImovel = _fetchTipoImovel();
      } else {
        Fluttertoast.showToast(
            msg: 'Erro ao inserir o Tipo de Imóvel!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            fontSize: 20.0
        );
      }
    } on Object catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  Future<void> _excluirTipoImovel(int id) async {
    var url = '$baseURL/tipos-imoveis/$id';
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('auth_token');
    Map<String, String> headers = {};
    headers["Authorization"] = 'Bearer $token';
    try {
      final response = await http
          .delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: 'Tipo Imóvel Excluído!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            fontSize: 20.0
        );
      } else {
        Fluttertoast.showToast(
            msg: 'Erro ao excluir o Tipo Imóvel!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            fontSize: 20.0
        );
      }
    } on Object catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  Future<void> _adicionarOuEditarTipoImovel(TipoImovelData tipoimovelData) async {
    String action = 'adicionar';
    if (tipoimovelData.id != 0) {
      action = 'editar';
    }
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                      decoration: const InputDecoration(hintText: 'Nome', labelText: 'Nome'),
                      initialValue: tipoimovelData.nome,
                      onSaved: (String? value) { tipoimovelData.nome = value!; }
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    child: Text(action == 'adicionar' ? 'Adicionar' : 'Editar'),
                    onPressed: () { submit(action, tipoimovelData); },
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () async {
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
      final preferences = await SharedPreferences.getInstance();
      final token = preferences.getString('auth_token');
      if (token == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage(),),
        );
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Tipo Imóvel'),
      ),
      body: Center(
        child: FutureBuilder <List<TipoImovelData>>(
          future: futureTipoImovel,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<TipoImovelData> _tipoimovel = snapshot.data!;
              return
                ListView.builder(
                    itemCount: _tipoimovel.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(_tipoimovel[index].nome),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                    _adicionarOuEditarTipoImovel(_tipoimovel[index])),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      if (await confirm(
                                        context,
                                        title: const Text('Confirmar Exclusão'),
                                        content: Text('Você deseja excluir o tipo imóvel "' + _tipoimovel[index].nome + '"?'),
                                        textOK: const Text('Sim'),
                                        textCancel: const Text('Não'),
                                        )) {
                                        _excluirTipoImovel(_tipoimovel[index].id!).whenComplete(() {
                                          setState(() {
                                            _tipoimovel.removeAt(index);
                                          });
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                          ),
                        ),
                      );
                    }
                );
            } else if (snapshot.hasError) {
              return const Text("Sem Tipos Imóveis");
            }
            // By default show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),

      // Ícone para dicionar um novo livro
      floatingActionButton: FloatingActionButton(
        onPressed: () => _adicionarOuEditarTipoImovel(TipoImovelData(id: 0, nome: "")),
        child: const Icon(Icons.add),
      ),
    );
  }
}