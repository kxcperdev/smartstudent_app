import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class EkranStatystyki extends StatefulWidget {
  @override
  _EkranStatystykiState createState() => _EkranStatystykiState();
}

class _EkranStatystykiState extends State<EkranStatystyki> {
  Map<String, int> czasUzytkowania = {};
  String wybranyOkres = "Dzień";
  Timer? _odswiezacz;

  @override
  void initState() {
    super.initState();
    _wczytajDane();
    _odswiezacz = Timer.periodic(Duration(seconds: 10), (timer) => _wczytajDane());
  }

  @override
  void dispose() {
    _odswiezacz?.cancel();
    super.dispose();
  }

  Future<void> _wczytajDane() async {
    final ustawienia = await SharedPreferences.getInstance();
    String dzisiaj = DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() {
      czasUzytkowania = {
        dzisiaj: ustawienia.getInt("czas_$dzisiaj") ?? 0,
      };
      for(int i = 1; i < 30; i++) {
        String data = DateFormat('yyyy-MM-dd').format(
            DateTime.now().subtract(Duration(days: i))
        );
        czasUzytkowania[data] = ustawienia.getInt("czas_$data") ?? 0;
      }
    });
  }

  int _obliczCzasOkresu() {
    int suma = 0;
    String dzisiaj = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if(wybranyOkres == "Dzień") {
      return czasUzytkowania[dzisiaj] ?? 0;
    }

    int iloscDni = wybranyOkres == "Tydzień" ? 7 : 30;

    for(int i = 0; i < iloscDni; i++) {
      String data = DateFormat('yyyy-MM-dd').format(
          DateTime.now().subtract(Duration(days: i))
      );
      suma += czasUzytkowania[data] ?? 0;
    }
    return suma;
  }

  @override
  Widget build(BuildContext context) {
    final czasOkresu = _obliczCzasOkresu() / 3600;

    return Scaffold(
      appBar: AppBar(
        title: Text("Statystyki Użytkowania"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _wczytajDane,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              final ustawienia = await SharedPreferences.getInstance();
              await ustawienia.clear();
              _wczytajDane();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: "Dzień", label: Text("Dzień")),
                ButtonSegment(value: "Tydzień", label: Text("Tydzień")),
                ButtonSegment(value: "Miesiąc", label: Text("Miesiąc")),
              ],
              selected: {wybranyOkres},
              onSelectionChanged: (Set<String> nowyWybor) {
                setState(() {
                  wybranyOkres = nowyWybor.first;
                });
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) => states.contains(MaterialState.selected)
                      ? Colors.orange
                      : Colors.white,
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              "${czasOkresu.toStringAsFixed(1)} godzin",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            Text(
              "spędzonych w aplikacji",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: czasUzytkowania.length,
                itemBuilder: (context, index) {
                  final data = czasUzytkowania.keys.elementAt(index);
                  final czas = czasUzytkowania[data]! / 3600;
                  return ListTile(
                    title: Text(data),
                    trailing: Text("${czas.toStringAsFixed(1)} h"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}