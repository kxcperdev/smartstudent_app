import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EkranRejestracji extends StatefulWidget {
  @override
  _EkranRejestracjiState createState() => _EkranRejestracjiState();
}

class _EkranRejestracjiState extends State<EkranRejestracji> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _hasloController = TextEditingController();
  final TextEditingController _powtorzHasloController = TextEditingController();
  String _blad = "";
  bool _oczekujeNaPotwierdzenie = false;
  Timer? _timer;

  Future<void> rejestracja() async {
    final email = _emailController.text.trim();
    final haslo = _hasloController.text.trim();
    final powtorzHaslo = _powtorzHasloController.text.trim();

    if (email.isEmpty || haslo.isEmpty || powtorzHaslo.isEmpty) {
      setState(() => _blad = "Wypełnij wszystkie pola.");
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      setState(() => _blad = "Niepoprawny format e-maila.");
      return;
    }

    if (haslo.length < 6) {
      setState(() => _blad = "Hasło musi mieć co najmniej 6 znaków.");
      return;
    }

    if (haslo != powtorzHaslo) {
      setState(() => _blad = "Hasła się nie zgadzają.");
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: haslo,
      );

      await userCredential.user?.sendEmailVerification();
      await FirebaseAuth.instance.signOut();

      setState(() {
        _blad = "Wysłano link aktywacyjny. Sprawdź pocztę.";
        _oczekujeNaPotwierdzenie = true;
      });

      _monitorujWeryfikacje(email, haslo);
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case "invalid-email":
            _blad = "E-mail jest w złym formacie.";
            break;
          case "email-already-in-use":
            _blad = "Ten e-mail jest już używany.";
            break;
          case "weak-password":
            _blad = "Hasło jest za słabe.";
            break;
          default:
            _blad = "Błąd rejestracji.";
        }
      });
    }
  }

  void _monitorujWeryfikacje(String email, String haslo) {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: haslo);
        await FirebaseAuth.instance.currentUser?.reload();

        if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
          _timer?.cancel();
          Navigator.pushReplacementNamed(context, "/glowny");
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_add, size: 100, color: Colors.green),
              SizedBox(height: 20),
              Text("Rejestracja", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "E-mail", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _hasloController,
                decoration: InputDecoration(labelText: "Hasło", border: OutlineInputBorder()),
                obscureText: true,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _powtorzHasloController,
                decoration: InputDecoration(labelText: "Powtórz hasło", border: OutlineInputBorder()),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _oczekujeNaPotwierdzenie ? null : rejestracja,
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                child: Text(_oczekujeNaPotwierdzenie ? "Oczekiwanie na potwierdzenie..." : "Zarejestruj się"),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/logowanie");
                },
                child: Text("Masz już konto? Zaloguj się"),
              ),
              SizedBox(height: 10),
              Text(_blad, style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
