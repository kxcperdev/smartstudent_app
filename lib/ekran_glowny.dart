import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ekran_notatki.dart';
import 'ekran_pomodoro.dart';
import 'ekran_terminy.dart';
import 'ekran_quizy.dart';
import 'ekran_tryb_skupienia.dart';

class EkranGlowny extends StatefulWidget {
  @override
  _EkranGlownyState createState() => _EkranGlownyState();
}

class _EkranGlownyState extends State<EkranGlowny> {
  String _imieUzytkownika = "Cześć, Studencie!";
  String _zdjecieProfilowe = "assets/avatar.jpg";

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _zaladujDaneUzytkownika());
  }

  Future<void> _zaladujDaneUzytkownika() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    String? zapisaneImie = prefs.getString("imieUzytkownika");

    if (mounted) {
      setState(() {
        if (zapisaneImie != null && zapisaneImie.isNotEmpty) {
          _imieUzytkownika = "Cześć, $zapisaneImie!";
        } else if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
          _imieUzytkownika = "Cześć, ${user.displayName!.split(" ")[0]}!";
        } else {
          _imieUzytkownika = "Cześć, Studencie!";
        }
      });
    }
  }

  Future<void> ustawImie(String noweImie) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("imieUzytkownika", noweImie);
    if (mounted) {
      setState(() {
        _imieUzytkownika = "Cześć, $noweImie!";
      });
    }
  }

  void _wyloguj() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("imieUzytkownika");
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, "/logowanie");
  }

  void _otworzDodawanieNotatki() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EkranNotatki()),
    );
    if (result != null) {
      print("Dodano notatkę: ${result['tytul']} - ${result['tresc']}");
    }
  }

  Widget _stworzKafelek(String tytul, IconData ikona, Color kolor, VoidCallback akcja) {
    return GestureDetector(
      onTap: akcja,
      child: Container(
        decoration: BoxDecoration(
          color: kolor,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikona, size: 55, color: Colors.white),
            SizedBox(height: 20),
            Text(tytul, style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(_zdjecieProfilowe),
                      radius: 32,
                    ),
                    SizedBox(width: 20),
                    Text(
                      _imieUzytkownika,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.settings, size: 30),
                  onPressed: () {
                    Navigator.pushNamed(context, "/ustawienia");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _stworzKafelek("Notatki", Icons.note, Colors.blue, _otworzDodawanieNotatki),
                  _stworzKafelek("Terminy", Icons.calendar_today, Colors.green, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EkranTerminow()),
                    );
                  }),
                  _stworzKafelek("Statystyki", Icons.bar_chart, Colors.orange, () {
                    Navigator.pushNamed(context, "/statystyki");
                  }),
                  _stworzKafelek("Pomodoro", Icons.timer, Colors.red, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EkranPomodoro()),
                    );
                  }),
                  _stworzKafelek("Quizy", Icons.quiz, Colors.purple, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EkranQuizow()),
                    );
                  }),
                  _stworzKafelek("Tryb Skupienia", Icons.block, Colors.teal, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EkranTrybSkupienia()),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: _wyloguj,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Wyloguj", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}