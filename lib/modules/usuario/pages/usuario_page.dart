import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:http/http.dart' as http;

import 'package:biblioteca_flutter/entities/usuario.dart';
import 'package:biblioteca_flutter/modules/login/pages/login_page.dart';
import 'package:biblioteca_flutter/config/api.dart';

class UsuarioPage extends StatefulWidget {
  const UsuarioPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _UsuarioPageState();
}

Future<List<UsuarioData>> _fetchUsuarios() async {
  const url = '$baseURL/administradores';
  final preferences = await SharedPreferences.getInstance();
  final token = preferences.getString('auth_token');
  Map<String, String> headers = {};
  headers["Authorization"] = 'Bearer $token';
  final response = await http.get(Uri.parse(url), headers: headers);
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
    return jsonResponse.map((usuario) => UsuarioData.fromJson(usuario)).toList();
  } else {
    Fluttertoast.showToast(
        msg: 'Erro ao listar os administradores!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        fontSize: 20.0
    );
    throw('Sem administradores');
  }
}

class _UsuarioPageState extends State<UsuarioPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future <List<UsuarioData>> futureUsuarios;

  @override
  void initState() {
    super.initState();
    futureUsuarios = _fetchUsuarios();
  }

  void submit(String action, UsuarioData usuarioData) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (usuarioData.nome == "") {
        Fluttertoast.showToast(
            msg: 'Por favor, informe o nome!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            fontSize: 20.0
        );
      } else if (usuarioData.email == "") {
        Fluttertoast.showToast(
            msg: 'Por favor, informe o e-mail!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            fontSize: 20.0
        );
      } else if (action == "adicionar" && usuarioData.senha == "") {
        Fluttertoast.showToast(
            msg: 'Por favor, informe a senha!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            fontSize: 20.0
        );
      } else if (action == "adicionar" && usuarioData.confirmarSenha == "") {
        Fluttertoast.showToast(
            msg: 'Por favor, informe a confirmação da senha!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            fontSize: 20.0
        );
      } else if (action == "adicionar" && usuarioData.senha != usuarioData.confirmarSenha) {
        Fluttertoast.showToast(
            msg: 'As senhas não são iguais!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            fontSize: 20.0
        );
      } else if (action == "editar" && usuarioData.senha != "" &&
          usuarioData.confirmarSenha == "") {
        Fluttertoast.showToast(
            msg: 'Por favor, informe a confirmação da senha!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            fontSize: 20.0
        );
      } else if (action == "editar" && usuarioData.senha != "" &&
          usuarioData.senha != usuarioData.confirmarSenha) {
        Fluttertoast.showToast(
            msg: 'As senhas não são iguais!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            fontSize: 20.0
        );
      } else {
        if (action == "adicionar") {
          _adicionarUsuario(usuarioData);
        } else {
          _editarUsuario(usuarioData);
        }
      }
    }
  }

  void _adicionarUsuario(UsuarioData usuarioData) async {
    const url = '$baseURL/administradores';
    var body = json.encode({'nome': usuarioData.nome, 'email': usuarioData.email, 'senha': usuarioData.senha, 'status': usuarioData.status });
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
            msg: 'Administrador Adicionado!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            fontSize: 20.0
        );
        futureUsuarios = _fetchUsuarios();
      } else {
        Map<String, dynamic> responseMap = json.decode(response.body);
        if (responseMap["message"].contains('ConstraintViolationException')) {
          Fluttertoast.showToast(
              msg: 'E-mail duplicado!',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              fontSize: 20.0
          );
        } else {
          Fluttertoast.showToast(
              msg: 'Erro ao editar o administrador!',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              fontSize: 20.0
          );
        }
      }
    } on Object catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  void _editarUsuario(UsuarioData usuarioData) async {
    var id = usuarioData.id;
    var url = '$baseURL/administradores/$id';
    var body = '';
    if (usuarioData.senha != "") {
      body = json.encode({
        'nome': usuarioData.nome,
        'email': usuarioData.email,
        'senha': usuarioData.senha,
        'status': usuarioData.status
      });
    } else {
      body = json.encode({
        'nome': usuarioData.nome,
        'email': usuarioData.email
      });
    }
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
            msg: 'Administrador Editado!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            fontSize: 20.0
        );
        futureUsuarios = _fetchUsuarios();
      } else {
        Map<String, dynamic> responseMap = json.decode(response.body);
        if (responseMap["message"].contains('ConstraintViolationException')) {
          Fluttertoast.showToast(
              msg: 'E-mail duplicado!',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              fontSize: 20.0
          );
        } else {
          Fluttertoast.showToast(
              msg: 'Erro ao inserir o administrador!',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              fontSize: 20.0
          );
        }
      }
    } on Object catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  Future<void> _excluirUsuario(int id) async {
    var url = '$baseURL/administradores/$id';
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('auth_token');
    Map<String, String> headers = {};
    headers["Authorization"] = 'Bearer $token';
    try {
      final response = await http
          .delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: 'Administrador Excluído!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            fontSize: 20.0
        );
      } else {
        Fluttertoast.showToast(
            msg: 'Erro ao excluir o administrador!',
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

  Future<void> _adicionarOuEditarUsuario(UsuarioData usuarioData) async {
    String action = 'adicionar';
    if (usuarioData.id != 0) {
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
                      initialValue: usuarioData.nome,
                      onSaved: (String? value) { usuarioData.nome = value!; }
                  ),
                  TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'E-mail', labelText: 'E-mail'),
                      initialValue: usuarioData.email,
                      onSaved: (String? value) { usuarioData.email = value!; }
                  ),
                  TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(hintText: 'Senha', labelText: 'Senha'),
                      initialValue: '',
                      onSaved: (String? value) { usuarioData.senha = value!; }
                  ),
                  TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(hintText: 'Confirmar Senha', labelText: 'Confirmar Senha'),
                      initialValue: '',
                      onSaved: (String? value) { usuarioData.confirmarSenha = value!; }
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    child: Text(action == 'adicionar' ? 'Adicionar' : 'Editar'),
                    onPressed: () { submit(action, usuarioData); },
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
        title: const Text('Gerenciar Administradores'),
      ),
      body: Center(
        child: FutureBuilder <List<UsuarioData>>(
          future: futureUsuarios,
          builder: (context, snapshot) {
            print(snapshot);
            if (snapshot.hasData) {

              List<UsuarioData> _usuario = snapshot.data!;
              return
                ListView.builder(
                    itemCount: _usuario.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(_usuario[index].nome!),
                            subtitle: Text(
                              'E-mail: ${_usuario[index].email} \nStatus: ${_usuario[index].status}'),
                              trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                    _adicionarOuEditarUsuario(_usuario[index])),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      if (await confirm(
                                        context,
                                        title: const Text('Confirmar Exclusão'),
                                        content: Text('Você deseja excluir o administrador "' + _usuario[index].nome! + '"?'),
                                        textOK: const Text('Sim'),
                                        textCancel: const Text('Não'),
                                        )) {
                                        _excluirUsuario(_usuario[index].id!).whenComplete(() {
                                          setState(() {
                                            _usuario.removeAt(index);
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
              return const Text("Sem administradores");
            }
            // By default show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),

      // Ícone para dicionar um novo usuário
      floatingActionButton: FloatingActionButton(
        onPressed: () => _adicionarOuEditarUsuario(UsuarioData()),
        child: const Icon(Icons.add),
      ),
    );
  }
}