import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class RejestracjaViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _blad = "";
  bool _oczekujeNaPotwierdzenie = false;
  Timer? _timer;

  String get blad => _blad;
  bool get oczekujeNaPotwierdzenie => _oczekujeNaPotwierdzenie;

  Future<bool> rejestracja(String email, String haslo, String powtorzHaslo) async {
    if (email.isEmpty || haslo.isEmpty || powtorzHaslo.isEmpty) {
      _blad = "Wypełnij wszystkie pola.";
      return false;
    }

    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      _blad = "Niepoprawny format e-maila.";
      return false;
    }

    if (haslo.length < 6) {
      _blad = "Hasło musi mieć co najmniej 6 znaków.";
      return false;
    }

    if (haslo != powtorzHaslo) {
      _blad = "Hasła się nie zgadzają.";
      return false;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: haslo,
      );

      await userCredential.user?.sendEmailVerification();
      await _auth.signOut();

      _blad = "Wysłano link aktywacyjny. Sprawdź pocztę.";
      _oczekujeNaPotwierdzenie = true;
      return true;
    } on FirebaseAuthException catch (e) {
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
      return false;
    }
  }

  void monitorujWeryfikacje(String email, String haslo, Function onVerified) {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      try {
        await _auth.signInWithEmailAndPassword(email: email, password: haslo);
        await _auth.currentUser?.reload();

        if (_auth.currentUser?.emailVerified ?? false) {
          _timer?.cancel();
          onVerified();
        }
      } catch (_) {}
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}