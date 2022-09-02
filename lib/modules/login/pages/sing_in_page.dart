import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:biblioteca_flutter/config/api.dart';
import 'package:biblioteca_flutter/entities/usuario.dart';
import 'package:biblioteca_flutter/modules/home/pages/home_page.dart';

class SingInPage extends StatefulWidget {
  const SingInPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SingInPageState();
}

class _SingInPageState extends State<SingInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late UsuarioData usuarioData = UsuarioData();

  void submit() {
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
      } else if (usuarioData.senha == "") {
        Fluttertoast.showToast(
            msg: 'Por favor, informe a senha!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            fontSize: 20.0
        );
      } else if (usuarioData.confirmarSenha == "") {
        Fluttertoast.showToast(
            msg: 'Por favor, informe a confirmação da senha!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            fontSize: 20.0
        );
      } else if (usuarioData.senha != usuarioData.confirmarSenha) {
        Fluttertoast.showToast(
            msg: 'As senhas não são iguais!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            fontSize: 20.0
        );
      } else {
        criarConta();
      }
    }
  }

  void criarConta() async {
    const url = '$baseURL/administradores/criar';
    var body = json.encode({'nome': usuarioData.nome, 'email': usuarioData.email, 'senha': usuarioData.senha,'status': usuarioData.status});
    try {
      final response = await http
          .post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: body);
      Map<String, dynamic> responseMap = json.decode(response.body);
      if (response.statusCode == 200) {
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString('auth_token', responseMap["token"]);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage(),),
        );
      } else {
        if (responseMap["message"].contains('EMAIL_DUPLICADO')) {
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
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    Future.delayed(Duration.zero, () async {
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
      final preferences = await SharedPreferences.getInstance();
      final token = preferences.getString('auth_token');
      if (token != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage(),),
        );
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta')),
      body: Container(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                    decoration: const InputDecoration(hintText: 'Nome', labelText: 'Nome'),
                    initialValue: usuarioData.nome,
                    onSaved: (String? value) { usuarioData.nome = value!; }
                ),
                TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'E-mail', labelText: 'E-mail'),
                    onSaved: (String? value) { usuarioData.email = value!; }
                ),
                TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                        hintText: 'Senha',
                        labelText: 'Senha'
                    ),
                    onSaved: (String? value) { usuarioData.senha = value!; }
                ),
                TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'Confirmar Senha', labelText: 'Confirmar Senha'),
                    initialValue: '',
                    onSaved: (String? value) { usuarioData.confirmarSenha = value!; }
                ),
                Container(
                  width: screenSize.width,
                  child: ElevatedButton(
                    child: const Text('Criar', style: TextStyle(color: Colors.white)),
                    onPressed: submit,
                  ),
                  margin: const EdgeInsets.only(top: 20.0),
                ),
              ],
            ),
          )
      ),
    );
  }
}

