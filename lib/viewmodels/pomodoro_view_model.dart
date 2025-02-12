import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/sesja_model.dart';

class PomodoroViewModel {
  int _czas = 1500;
  bool _czyDziala = false;
  bool _czyPrzerwa = false;
  Timer? _timer;
  List<Sesja> _historiaSesji = [];
  final FlutterLocalNotificationsPlugin _powiadomienia = FlutterLocalNotificationsPlugin();

  int get czas => _czas;
  bool get czyDziala => _czyDziala;
  bool get czyPrzerwa => _czyPrzerwa;
  List<Sesja> get historiaSesji => _historiaSesji;

  Future<void> inicjalizuj() async {
    await _inicjalizujPowiadomienia();
    await _wczytajHistorie();
  }

  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  Future<void> _wczytajHistorie() async {
    final pref = await SharedPreferences.getInstance();
    final historiaKody = pref.getStringList('historiaSesji') ?? [];
    _historiaSesji = historiaKody.map((kod) => Sesja.zKodu(kod)).toList();
  }

  Future<void> _zapiszHistorie(String typ) async {
    final pref = await SharedPreferences.getInstance();
    final teraz = DateFormat('dd.MM.yy HH:mm').format(DateTime.now());

    final nowaSesja = Sesja(data: teraz, typ: typ);
    _historiaSesji.insert(0, nowaSesja);

    final historiaKody = _historiaSesji.map((sesja) => sesja.kodHistorii).toList();
    await pref.setStringList('historiaSesji', historiaKody);
  }

  Future<void> _inicjalizujPowiadomienia() async {
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings = InitializationSettings(android: androidInit);
    await _powiadomienia.initialize(initSettings);
  }

  void startTimer(Function onTick, Function onComplete) {
    if (_czyDziala) return;
    _czyDziala = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_czas > 0) {
        _czas--;
        onTick();
      } else {
        stopTimer();
        wykonajZakonczenieCzasu(onComplete);
      }
    });
  }

  void wykonajZakonczenieCzasu(Function onComplete) async {
    await _pokazPowiadomienie();
    final typ = _czyPrzerwa ? 'Przerwa' : 'Nauka';
    await _zapiszHistorie(typ);

    _czyPrzerwa = !_czyPrzerwa;
    _czas = _czyPrzerwa ? 300 : 1500;
    onComplete();
  }

  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _czyDziala = false;
  }

  void resetujTimer() {
    stopTimer();
    _czas = 1500;
    _czyPrzerwa = false;
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

  Future<void> usunHistorie() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove('historiaSesji');
    _historiaSesji.clear();
  }

  String formatujCzas() {
    int minuty = _czas ~/ 60;
    int sek = _czas % 60;
    return '$minuty:${sek.toString().padLeft(2, '0')}';
  }
}