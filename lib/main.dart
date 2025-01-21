import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'ekran_logowania.dart';
import 'ekran_rejestracji.dart';
import 'ekran_glowny.dart';
import 'ekran_splash.dart';
import 'ekran_ustawienia.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  String dzisiaj = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final ustawienia = await SharedPreferences.getInstance();
  int poczatkowyCzas = DateTime.now().millisecondsSinceEpoch;

  Timer.periodic(Duration(minutes: 1), (timer) async {
    int obecnyCzas = DateTime.now().millisecondsSinceEpoch;
    int roznicaCzasu = (obecnyCzas - poczatkowyCzas) ~/ 1000;
    await ustawienia.setInt("czas_$dzisiaj", roznicaCzasu);
  });

  runApp(Aplikacja());
}

class Aplikacja extends StatefulWidget {
  @override
  _AplikacjaState createState() => _AplikacjaState();
}

class _AplikacjaState extends State<Aplikacja> {
  bool trybCiemny = false;

  @override
  void initState() {
    super.initState();
    _wczytajUstawienia();
  }

  Future<void> _wczytajUstawienia() async {
    final ustawienia = await SharedPreferences.getInstance();
    setState(() {
      trybCiemny = ustawienia.getBool('tryb_ciemny') ?? false;
    });
  }

  void zmienMotyw(bool nowyTryb) {
    setState(() {
      trybCiemny = nowyTryb;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartStudent',
      themeMode: trybCiemny ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.orange,
          secondary: Colors.orangeAccent,
        ),
      ),
      home: EkranSplash(),
      routes: {
        "/splash": (context) => EkranSplash(),
        "/autoryzacja": (context) => AutoryzacjaUzytkownika(),
        "/logowanie": (context) => EkranLogowania(),
        "/rejestracja": (context) => EkranRejestracji(),
        "/glowny": (context) => EkranGlowny(),
        "/ustawienia": (context) => EkranUstawienia(zmienMotyw: zmienMotyw),
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