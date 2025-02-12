import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlownyViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _imieUzytkownika = "Cześć, Studencie!";
  String _zdjecieProfilowe = "assets/avatar.jpg";

  String get imieUzytkownika => _imieUzytkownika;
  String get zdjecieProfilowe => _zdjecieProfilowe;

  Future<void> zaladujDaneUzytkownika() async {
    final user = _auth.currentUser;
    final prefs = await SharedPreferences.getInstance();
    String? zapisaneImie = prefs.getString("imieUzytkownika");

    if (zapisaneImie != null && zapisaneImie.isNotEmpty) {
      _imieUzytkownika = "Cześć, $zapisaneImie!";
    } else if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      _imieUzytkownika = "Cześć, ${user.displayName!.split(" ")[0]}!";
    } else {
      _imieUzytkownika = "Cześć, Studencie!";
    }
  }

  Future<void> ustawImie(String noweImie) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("imieUzytkownika", noweImie);
    _imieUzytkownika = "Cześć, $noweImie!";
  }

  Future<void> wyloguj() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("imieUzytkownika");
    await _auth.signOut();
  }
}