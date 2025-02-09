import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Autoryzacja {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> logowanie(String email, String haslo) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: haslo);
    } catch (e) {
      print("Błąd logowania: $e");
    }
  }

  static Future<void> logowanieGoogle() async {
    try {
      final GoogleSignInAccount? konto = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? auth = await konto?.authentication;

      if (konto != null && auth != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: auth.accessToken,
          idToken: auth.idToken,
        );
        await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      print("Błąd logowania Google: $e");
    }
  }
}
