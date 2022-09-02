import 'package:biblioteca_flutter/modules/login/pages/sing_in_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:biblioteca_flutter/config/api.dart';
import 'package:biblioteca_flutter/entities/usuario.dart';
import 'package:biblioteca_flutter/modules/home/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late UsuarioData usuarioData = UsuarioData();

  void submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (usuarioData.email == "") {
        Fluttertoast.showToast(
            msg: 'Por favor, informe o seu e-mail!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            fontSize: 20.0
        );
      } else if (usuarioData.senha == "") {
        Fluttertoast.showToast(
            msg: 'Por favor, informe a sua senha!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            fontSize: 20.0
        );
      } else {
        login();
      }
    }
  }

  void login() async {
    const url = '$baseURL/authenticate';
    var body = json.encode({'username': usuarioData.email, 'password': usuarioData.senha});
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
        Fluttertoast.showToast(
            msg: 'E-mail e/ou senha incorretos!',
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
      appBar: AppBar(title: const Text('Login'), automaticallyImplyLeading: false),
      body: Container(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
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
                Container(
                  width: screenSize.width,
                  child: ElevatedButton(
                    child: const Text('Login', style: TextStyle(color: Colors.white)),
                    onPressed: submit,
                  ),
                  margin: const EdgeInsets.only(top: 20.0),
                ),
                Container(
                  width: screenSize.width,
                  child: ElevatedButton(
                    child: const Text('Criar Conta', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SingInPage(),),
                      );
                    },
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

