import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:http/http.dart' as http;

import 'package:biblioteca_flutter/entities/livro.dart';
import 'package:biblioteca_flutter/modules/login/pages/login_page.dart';
import 'package:biblioteca_flutter/config/api.dart';

class LivroPage extends StatefulWidget {
  const LivroPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _LivroPageState();
}

Future<List<LivroData>> _fetchLivros() async {
  const url = '$baseURL/livros';
  final preferences = await SharedPreferences.getInstance();
  final token = preferences.getString('auth_token');
  Map<String, String> headers = {};
  headers["Authorization"] = 'Bearer $token';
  final response = await http.get(Uri.parse(url), headers: headers);
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
    return jsonResponse.map((livro) => LivroData.fromJson(livro)).toList();
  } else {
    Fluttertoast.showToast(
        msg: 'Erro ao listar os livros!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        fontSize: 20.0
    );
    throw('Sem livros');
  }
}

class _LivroPageState extends State<LivroPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future <List<LivroData>> futureLivros;

  @override
  void initState() {
    super.initState();
    futureLivros = _fetchLivros();
  }

  void submit(String action, LivroData livroData) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (livroData.titulo == "") {
        Fluttertoast.showToast(
            msg: 'Por favor, informe o título!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            fontSize: 20.0
        );
      } else if (livroData.resumo == "") {
        Fluttertoast.showToast(
            msg: 'Por favor, informe o resumo!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            fontSize: 20.0
        );
      } else {
        if (action == "adicionar") {
          _adicionarLivro(livroData);
        } else {
          _editarLivro(livroData);
        }
      }
    }
  }

  void _adicionarLivro(LivroData livroData) async {
    const url = '$baseURL/livros';
    var body = json.encode({'titulo': livroData.titulo, 'resumo': livroData.resumo});
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
            msg: 'Livro Adicionado!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            fontSize: 20.0
        );
        futureLivros = _fetchLivros();
      } else {
        Fluttertoast.showToast(
            msg: 'Erro ao editar o livro!',
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

  void _editarLivro(LivroData livroData) async {
    var id = livroData.id;
    var url = '$baseURL/livros/$id';
    var body = json.encode({
        'titulo': livroData.titulo,
        'resumo': livroData.resumo,
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
            msg: 'Livro Editado!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            fontSize: 20.0
        );
        futureLivros = _fetchLivros();
      } else {
        Fluttertoast.showToast(
            msg: 'Erro ao inserir o livro!',
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

  Future<void> _excluirLivro(int id) async {
    var url = '$baseURL/livros/$id';
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('auth_token');
    Map<String, String> headers = {};
    headers["Authorization"] = 'Bearer $token';
    try {
      final response = await http
          .delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: 'Livro Excluído!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            fontSize: 20.0
        );
      } else {
        Fluttertoast.showToast(
            msg: 'Erro ao excluir o livro!',
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

  Future<void> _adicionarOuEditarLivro(LivroData livroData) async {
    String action = 'adicionar';
    if (livroData.id != 0) {
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
                      decoration: const InputDecoration(hintText: 'Título', labelText: 'Título'),
                      initialValue: livroData.titulo,
                      onSaved: (String? value) { livroData.titulo = value!; }
                  ),
                  TextFormField(
                      maxLines: 8,
                      decoration: const InputDecoration(hintText: 'Resumo', labelText: 'Resumo'),
                      initialValue: livroData.resumo,
                      onSaved: (String? value) { livroData.resumo = value!; }
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    child: Text(action == 'adicionar' ? 'Adicionar' : 'Editar'),
                    onPressed: () { submit(action, livroData); },
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
        title: const Text('Gerenciar Livros'),
      ),
      body: Center(
        child: FutureBuilder <List<LivroData>>(
          future: futureLivros,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<LivroData> _livro = snapshot.data!;
              return
                ListView.builder(
                    itemCount: _livro.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(_livro[index].titulo),
                            subtitle: Text(_livro[index].resumo),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                    _adicionarOuEditarLivro(_livro[index])),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      if (await confirm(
                                        context,
                                        title: const Text('Confirmar Exclusão'),
                                        content: Text('Você deseja excluir o livro "' + _livro[index].titulo + '"?'),
                                        textOK: const Text('Sim'),
                                        textCancel: const Text('Não'),
                                        )) {
                                        _excluirLivro(_livro[index].id).whenComplete(() {
                                          setState(() {
                                            _livro.removeAt(index);
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
              return const Text("Sem livros");
            }
            // By default show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),

      // Ícone para dicionar um novo livro
      floatingActionButton: FloatingActionButton(
        onPressed: () => _adicionarOuEditarLivro(LivroData(id: 0, titulo: "", resumo: "")),
        child: const Icon(Icons.add),
      ),
    );
  }
}