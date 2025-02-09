import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class EkranPomodoro extends StatefulWidget {
  @override
  _EkranPomodoroState createState() => _EkranPomodoroState();
}

class _EkranPomodoroState extends State<EkranPomodoro> {
  int _czas = 1500;
  bool _czyDziala = false;
  bool _czyPrzerwa = false;
  Timer? _timer;
  final FlutterLocalNotificationsPlugin _powiadomienia = FlutterLocalNotificationsPlugin();
  List<String> historiaSesji = [];

  @override
  void initState() {
    super.initState();
    _inicjalizujPowiadomienia();
    _wczytajHistorie();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  Future<void> _wczytajHistorie() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      historiaSesji = pref.getStringList('historiaSesji') ?? [];
    });
  }

  Future<void> _zapiszHistorie(String typ) async {
    final pref = await SharedPreferences.getInstance();
    final teraz = DateFormat('dd.MM.yy HH:mm').format(DateTime.now());

    historiaSesji.insert(0, '$teraz|$typ');

    await pref.setStringList('historiaSesji', historiaSesji);
  }

  Future<void> _inicjalizujPowiadomienia() async {
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings = InitializationSettings(android: androidInit);
    await _powiadomienia.initialize(initSettings);
  }

  void _startTimer() {
    if (_czyDziala) return;
    setState(() {
      _czyDziala = true;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_czas > 0 && mounted) {
        setState(() {
          _czas--;
        });
      } else {
        _stopTimer();
        if (mounted) {
          _wykonajZakonczenieCzasu();
        }
      }
    });
  }

  void _wykonajZakonczenieCzasu() async {
    if (!mounted) return;
    _pokazPowiadomienie();
    final typ = _czyPrzerwa ? 'Przerwa' : 'Nauka';
    await _zapiszHistorie(typ);
    if (!mounted) return;
    setState(() {
      _czyPrzerwa = !_czyPrzerwa;
      _czas = _czyPrzerwa ? 300 : 1500;
      _startTimer();
    });
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    if (mounted) {
      setState(() {
        _czyDziala = false;
      });
    }
  }

  void resetujTimer() {
    _stopTimer();
    setState(() {
      _czas = 1500;
      _czyPrzerwa = false;
    });
  }

  Future<void> _pokazPowiadomienie() async {
    String tytul = _czyPrzerwa ? "Czas wrócić do nauki!" : "Czas na przerwę!";
    String tresc = _czyPrzerwa ? "Koniec przerwy, wracamy do pracy!" : "Zrób krótką przerwę przed kolejną sesją.";

    await _powiadomienia.show(
      0,
      tytul,
      tresc,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro_channel',
          'Pomodoro Timer',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> _usunHistorie() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove('historiaSesji');
    setState(() {
      historiaSesji.clear();
    });
  }

  void _pokazDialogUsuwaniaHistorii() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Usuń historię sesji'),
          content: Text('Czy na pewno chcesz usunąć całą historię sesji?'),
          actions: <Widget>[
            TextButton(
              child: Text('Anuluj'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Usuń'),
              onPressed: () {
                _usunHistorie();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatujCzas(int sekundy) {
    int minuty = sekundy ~/ 60;
    int sek = sekundy % 60;
    return '$minuty:${sek.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tryb Pomodoro"),
        backgroundColor: _czyPrzerwa ? Colors.green : Colors.red,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: _czyPrzerwa ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _czyPrzerwa ? "Przerwa" : "Czas nauki",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _czyPrzerwa ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      _formatujCzas(_czas),
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: _czyPrzerwa ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          onPressed: _czyDziala ? _stopTimer : _startTimer,
                          backgroundColor: _czyPrzerwa ? Colors.green : Colors.red,
                          child: Icon(_czyDziala ? Icons.pause : Icons.play_arrow),
                          heroTag: "start/stop",
                        ),
                        SizedBox(width: 20),
                        FloatingActionButton(
                          onPressed: resetujTimer,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.refresh),
                          heroTag: "reset",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Historia sesji",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (historiaSesji.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: _pokazDialogUsuwaniaHistorii,
                    tooltip: 'Usuń historię sesji',
                  ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: historiaSesji.length,
                  itemBuilder: (context, index) {
                    final wpis = historiaSesji[index].split('|');
                    final bool czyNauka = wpis[1] == 'Nauka';
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        leading: Icon(
                          czyNauka ? Icons.school : Icons.coffee,
                          color: czyNauka ? Colors.red : Colors.green,
                        ),
                        title: Text(
                          wpis[1],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(wpis[0]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}