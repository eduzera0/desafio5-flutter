import 'package:biblioteca_flutter/modules/imovel/pages/imovel.dart';
import 'package:biblioteca_flutter/modules/tipoimovel/pages/tipoimovel.dart';
import 'package:biblioteca_flutter/modules/usuario/pages/usuario_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:biblioteca_flutter/modules/login/pages/login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              child: const Text("Administradores"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UsuarioPage(),),
                );
              },
            ),
            ElevatedButton(
              child: const Text("Imóvel"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ImovelPage(),),
                );
              },
            ),
            ElevatedButton(
              child: const Text("Tipo Imóvel"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TipoImovelPage(),),
                );
              },
            ),
            ElevatedButton(
              child: const Text("Sair"),
              onPressed: () async {
                final preferences = await SharedPreferences.getInstance();
                await preferences.remove('auth_token');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage(),),
                );
              },
          ),
        ]),
      ),
    );
  }
}
