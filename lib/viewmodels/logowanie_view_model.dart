import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LogowanieViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String _blad = "";
  String _infoResetHasla = "";

  String get blad => _blad;
  String get infoResetHasla => _infoResetHasla;

  Future<bool> logowanie(String email, String haslo) async {
    if (email.isEmpty || haslo.isEmpty) {
      _blad = "Wypełnij wszystkie pola.";
      return false;
    }

    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      _blad = "Niepoprawny format e-maila.";
      return false;
    }

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: haslo);

      if (!userCredential.user!.emailVerified) {
        _blad = "Potwierdź e-mail przed zalogowaniem.";
        return false;
      }

      return true;
    } on FirebaseAuthException catch (e) {
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
      return false;
    }
  }

  Future<bool> logowanieGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      _blad = "Błąd logowania Google.";
      return false;
    }
  }

  Future<bool> resetujHaslo(String email) async {
    if (email.isEmpty) {
      _infoResetHasla = "Wpisz e-mail przed resetem hasła.";
      return false;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _infoResetHasla = "Wysłano link do resetowania hasła.";
      return true;
    } catch (e) {
      _infoResetHasla = "Błąd resetowania hasła.";
      return false;
    }
  }
}