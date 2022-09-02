import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'package:biblioteca_flutter/modules/home/pages/home_page.dart';
import 'package:biblioteca_flutter/modules/login/pages/login_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () async {
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
      final preferences = await SharedPreferences.getInstance();
      final token = preferences.getString('auth_token');
      if (token != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage(),),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage(),),
        );
      }
    });
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Wrap(
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Image.asset(
                  'assets/imagens/logo_splash.png',
                  height: 90,
                ),
                const Padding(padding: EdgeInsets.only(top: 32)),
                const CircularProgressIndicator(color: Colors.white70),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
