import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AplikacjaInfo {
  final String nazwa;
  final String pakiet;
  final IconData ikona;

  AplikacjaInfo({
    required this.nazwa,
    required this.pakiet,
    required this.ikona,
  });
}

class EkranTrybSkupienia extends StatefulWidget {
  @override
  _EkranTrybSkupieniaState createState() => _EkranTrybSkupieniaState();
}

class _EkranTrybSkupieniaState extends State<EkranTrybSkupienia> {
  List<AplikacjaInfo> aplikacje = [];
  List<String> zablokowanePlikacje = [];
  bool trybSkupieniaAktywny = false;

  @override
  void initState() {
    super.initState();
    _wczytajListeAplikacji();
    _wczytajZablokowanePlikacje();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _wczytajListeAplikacji() {
    setState(() {
      aplikacje = [
        AplikacjaInfo(
          nazwa: 'Facebook',
          pakiet: 'com.facebook.katana',
          ikona: Icons.facebook,
        ),
        AplikacjaInfo(
          nazwa: 'Instagram',
          pakiet: 'com.instagram.android',
          ikona: Icons.camera_alt,
        ),
        AplikacjaInfo(
          nazwa: 'TikTok',
          pakiet: 'com.zhiliaoapp.musically',
          ikona: Icons.horizontal_split_rounded,
        ),
        AplikacjaInfo(
          nazwa: 'YouTube',
          pakiet: 'com.google.android.youtube',
          ikona: Icons.play_circle_outline,
        ),
        AplikacjaInfo(
          nazwa: 'Twitter/X',
          pakiet: 'com.twitter.android',
          ikona: Icons.share,
        ),
        AplikacjaInfo(
          nazwa: 'Messenger',
          pakiet: 'com.facebook.orca',
          ikona: Icons.message,
        ),
      ];
    });
  }

  Future<void> _wczytajZablokowanePlikacje() async {
    final ustawienia = await SharedPreferences.getInstance();
    setState(() {
      zablokowanePlikacje = ustawienia.getStringList('zablokowanePlikacje') ?? [];
    });
  }

  Future<void> _zapiszZablokowanePlikacje() async {
    final ustawienia = await SharedPreferences.getInstance();
    await ustawienia.setStringList('zablokowanePlikacje', zablokowanePlikacje);
  }

  void _przelaczBlokade(String nazwaAplikacji, String pakiet) {
    setState(() {
      if (zablokowanePlikacje.contains(pakiet)) {
        zablokowanePlikacje.remove(pakiet);
      } else {
        zablokowanePlikacje.add(pakiet);
      }
    });
    _zapiszZablokowanePlikacje();
  }

  void _przelaczTrybSkupienia(bool value) {
    setState(() {
      trybSkupieniaAktywny = value;
      if (trybSkupieniaAktywny) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EkranSkupienia()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tryb Skupienia'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aktywuj Tryb Skupienia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Switch(
                  value: trybSkupieniaAktywny,
                  onChanged: (value) => _przelaczTrybSkupienia(value),
                  activeColor: Colors.white,
                  activeTrackColor: Colors.teal.shade200,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 16),
              itemCount: aplikacje.length,
              itemBuilder: (context, index) {
                final aplikacja = aplikacje[index];

                return ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      aplikacja.ikona,
                      color: Colors.teal,
                      size: 30,
                    ),
                  ),
                  title: Text(
                    aplikacja.nazwa,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EkranSkupienia extends StatefulWidget {
  @override
  _EkranSkupieniaState createState() => _EkranSkupieniaState();
}

class _EkranSkupieniaState extends State<EkranSkupienia> {
  int licznik = 0;
  Timer? czasomierz;

  @override
  void initState() {
    super.initState();
    _wlaczLicznik();
  }

  @override
  void dispose() {
    czasomierz?.cancel();
    super.dispose();
  }

  void _wlaczLicznik() {
    licznik = 0;
    czasomierz = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      setState(() {
        licznik++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                licznik += 1;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Center(
                child: Text(
                  '$licznik',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}