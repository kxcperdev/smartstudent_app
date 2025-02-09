import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ekran_logowania.dart';
import 'ekran_rejestracji.dart';
import 'ekran_glowny.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Aplikacja());
}

class Aplikacja extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartStudent',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: AutoryzacjaUzytkownika(),
      routes: {
        "/logowanie": (context) => EkranLogowania(),
        "/rejestracja": (context) => EkranRejestracji(),
        "/glowny": (context) => EkranGlowny(),
      },
    );
  }
}

class AutoryzacjaUzytkownika extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return EkranGlowny();
        }
        return EkranLogowania();
      },
    );
  }
}
