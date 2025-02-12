import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/pytanie_model.dart';

class QuizViewModel {
  List<Pytanie> _pytania = [];
  Set<String> _kategorie = {};

  List<Pytanie> get pytania => _pytania;
  Set<String> get kategorie => _kategorie;

  Future<void> wczytajPytania() async {
    final pref = await SharedPreferences.getInstance();
    final listaJson = pref.getStringList('pytania') ?? [];
    _pytania = listaJson
        .map((json) => Pytanie.zMapy(jsonDecode(json)))
        .toList();
    _kategorie = _pytania.map((p) => p.kategoria).toSet();
  }

  Future<void> zapiszPytania() async {
    final pref = await SharedPreferences.getInstance();
    final listaJson = _pytania.map((p) => jsonEncode(p.doMapy())).toList();
    await pref.setStringList('pytania', listaJson);
  }

  Future<void> usunKategorie(String kategoria) async {
    _pytania.removeWhere((pytanie) => pytanie.kategoria == kategoria);
    _kategorie.remove(kategoria);
    await zapiszPytania();
  }

  Future<void> dodajPytania(List<Pytanie> nowePytania) async {
    _pytania.addAll(nowePytania);
    _kategorie.add(nowePytania.first.kategoria);
    await zapiszPytania();
  }

  List<Pytanie> getPytaniaKategorii(String kategoria) {
    return _pytania
        .where((p) => p.kategoria == kategoria)
        .toList()
      ..shuffle();
  }

  Map<String, dynamic> getStatystykiKategorii(String kategoria) {
    final pytaniaKategorii = _pytania.where((p) => p.kategoria == kategoria);
    final sredniaPoprawnych = pytaniaKategorii.isEmpty ? 0.0 :
    pytaniaKategorii
        .map((p) => p.liczbaProb == 0 ? 0.0 :
    p.liczbaPoprawnychOdpowiedzi / p.liczbaProb * 100)
        .reduce((a, b) => a + b) / pytaniaKategorii.length;

    return {
      'liczbaPytan': pytaniaKategorii.length,
      'sredniaPoprawnych': sredniaPoprawnych,
    };
  }

  int getLiczbaPytanKategorii(String kategoria) {
    return _pytania.where((p) => p.kategoria == kategoria).length;
  }
}

class QuizSessionViewModel {
  final List<Pytanie> pytania;
  int _aktualnePytanie = 0;
  int? _wybranaOdpowiedz;
  bool _czySprawdzone = false;
  int _poprawneOdpowiedzi = 0;
  bool _czyOdpowiedzPoprawna = false;

  QuizSessionViewModel(this.pytania);

  int get aktualnePytanie => _aktualnePytanie;
  int? get wybranaOdpowiedz => _wybranaOdpowiedz;
  bool get czySprawdzone => _czySprawdzone;
  int get poprawneOdpowiedzi => _poprawneOdpowiedzi;
  bool get czyOdpowiedzPoprawna => _czyOdpowiedzPoprawna;
  bool get czyOstatniePytanie => _aktualnePytanie == pytania.length - 1;
  double get postep => (aktualnePytanie + 1) / pytania.length;

  void wybierzOdpowiedz(int odpowiedz) {
    if (!_czySprawdzone) {
      _wybranaOdpowiedz = odpowiedz;
    }
  }

  void sprawdzOdpowiedz() {
    if (_wybranaOdpowiedz == null) return;

    _czySprawdzone = true;
    _czyOdpowiedzPoprawna = _wybranaOdpowiedz == pytania[_aktualnePytanie].poprawnaOdpowiedz;

    if (_czyOdpowiedzPoprawna) {
      _poprawneOdpowiedzi++;
      pytania[_aktualnePytanie].liczbaPoprawnychOdpowiedzi++;
    }
    pytania[_aktualnePytanie].liczbaProb++;
  }

  bool przejdzDoNastepnegoPytania() {
    if (_aktualnePytanie < pytania.length - 1) {
      _aktualnePytanie++;
      _wybranaOdpowiedz = null;
      _czySprawdzone = false;
      _czyOdpowiedzPoprawna = false;
      return true;
    }
    return false;
  }

  double obliczWynikProcentowy() {
    return _poprawneOdpowiedzi / pytania.length * 100;
  }
}