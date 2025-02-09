import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class EkranLogowania extends StatefulWidget {
  @override
  _EkranLogowaniaState createState() => _EkranLogowaniaState();
}

class _EkranLogowaniaState extends State<EkranLogowania> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _hasloController = TextEditingController();
  String _blad = "";
  String _infoResetHasla = "";

  Future<void> logowanie() async {
    final email = _emailController.text.trim();
    final haslo = _hasloController.text.trim();

    if (email.isEmpty || haslo.isEmpty) {
      setState(() => _blad = "Wypełnij wszystkie pola.");
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      setState(() => _blad = "Niepoprawny format e-maila.");
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: haslo);

      if (!userCredential.user!.emailVerified) {
        setState(() => _blad = "Potwierdź e-mail przed zalogowaniem.");
        return;
      }

      Navigator.pushReplacementNamed(context, "/glowny");
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case "invalid-email":
            _blad = "E-mail jest w złym formacie.";
            break;
          case "user-not-found":
            _blad = "Nie znaleziono konta z tym e-mailem.";
            break;
          case "wrong-password":
          case "invalid-credential":
            _blad = "Niepoprawne hasło.";
            break;
          case "too-many-requests":
            _blad = "Za dużo nieudanych prób logowania. Spróbuj później.";
            break;
          default:
            _blad = "Błąd logowania.";
        }
      });
    }
  }

  Future<void> logowanieGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacementNamed(context, "/glowny");
    } catch (e) {
      setState(() => _blad = "Błąd logowania Google.");
    }
  }

  Future<void> resetujHaslo() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _infoResetHasla = "Wpisz e-mail przed resetem hasła.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() => _infoResetHasla = "Wysłano link do resetowania hasła.");
    } catch (e) {
      setState(() => _infoResetHasla = "Błąd resetowania hasła.");
    }
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
              Icon(Icons.school, size: 100, color: Colors.green),
              SizedBox(height: 20),
              Text("Zaloguj się", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: resetujHaslo,
                  child: Text("Zapomniałeś hasła?"),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: logowanie,
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                child: Text("Zaloguj się"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: logowanieGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text("Zaloguj przez Google"),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/rejestracja");
                },
                child: Text("Nie masz konta? Zarejestruj się"),
              ),
              SizedBox(height: 10),
              Text(_infoResetHasla, style: TextStyle(color: Colors.green)),
              SizedBox(height: 10),
              Text(_blad, style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
