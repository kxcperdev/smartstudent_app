import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../models/statystyka_model.dart';

class StatystykiViewModel {
  Map<String, int> _czasUzytkowania = {};
  Timer? _odswiezacz;
  String _wybranyOkres = "Dzień";

  Map<String, int> get czasUzytkowania => _czasUzytkowania;
  String get wybranyOkres => _wybranyOkres;

  void rozpocznijAutomatyczneOdswiezanie(Function onOdswiez) {
    _odswiezacz = Timer.periodic(Duration(seconds: 10), (timer) => wczytajDane().then((_) => onOdswiez()));
  }

  void zatrzymajAutomatyczneOdswiezanie() {
    _odswiezacz?.cancel();
  }

  void zmienOkres(String nowyOkres) {
    _wybranyOkres = nowyOkres;
  }

  Future<void> wczytajDane() async {
    final ustawienia = await SharedPreferences.getInstance();
    String dzisiaj = DateFormat('yyyy-MM-dd').format(DateTime.now());

    _czasUzytkowania = {
      dzisiaj: ustawienia.getInt("czas_$dzisiaj") ?? 0,
    };

    for(int i = 1; i < 30; i++) {
      String data = DateFormat('yyyy-MM-dd').format(
          DateTime.now().subtract(Duration(days: i))
      );
      _czasUzytkowania[data] = ustawienia.getInt("czas_$data") ?? 0;
    }
  }

  Future<void> wyczyscDane() async {
    final ustawienia = await SharedPreferences.getInstance();
    await ustawienia.clear();
    await wczytajDane();
  }

  double obliczCzasOkresu() {
    int suma = 0;
    String dzisiaj = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if(_wybranyOkres == "Dzień") {
      return (_czasUzytkowania[dzisiaj] ?? 0) / 3600;
    }

    int iloscDni = _wybranyOkres == "Tydzień" ? 7 : 30;

    for(int i = 0; i < iloscDni; i++) {
      String data = DateFormat('yyyy-MM-dd').format(
          DateTime.now().subtract(Duration(days: i))
      );
      suma += _czasUzytkowania[data] ?? 0;
    }
    return suma / 3600;
  }

  String formatujCzas(int sekundy) {
    return (sekundy / 3600).toStringAsFixed(1);
  }
}