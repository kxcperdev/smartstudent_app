import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';
import '../models/termin_model.dart';

class TerminViewModel {
  final FlutterLocalNotificationsPlugin _powiadomienia = FlutterLocalNotificationsPlugin();
  final DeviceCalendarPlugin _kalendarz = DeviceCalendarPlugin();
  List<Termin> _terminy = [];

  List<Termin> get terminy => _terminy;

  Future<void> inicjalizuj() async {
    tz.initializeTimeZones();
    await _inicjalizujPowiadomienia();
    await wczytajTerminy();
  }

  Future<bool> sprawdzUprawnienia() async {
    var statusKalendarza = await Permission.calendar.status;
    if (statusKalendarza.isDenied) {
      statusKalendarza = await Permission.calendar.request();
    }
    return !statusKalendarza.isPermanentlyDenied;
  }

  Future<void> _inicjalizujPowiadomienia() async {
    const AndroidInitializationSettings androidUstawienia =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings ustawienia =
    InitializationSettings(android: androidUstawienia);
    await _powiadomienia.initialize(ustawienia);
  }

  Future<bool> dodajDoKalendarza(Termin termin) async {
    try {
      final permissionStatus = await Permission.calendar.status;
      if (!permissionStatus.isGranted) {
        final result = await Permission.calendar.request();
        if (!result.isGranted) return false;
      }

      final wynikKalendarzy = await _kalendarz.retrieveCalendars();
      if (!wynikKalendarzy.isSuccess || wynikKalendarzy.data == null) return false;

      Calendar? kalendarz;
      for (var k in wynikKalendarzy.data!) {
        if (k.isReadOnly == false) {
          kalendarz = k;
          break;
        }
      }

      if (kalendarz == null) return false;

      final dataPoczatek = tz.TZDateTime.from(termin.data, tz.local);
      final dataKoniec = tz.TZDateTime.from(termin.data.add(Duration(hours: 1)), tz.local);

      final wydarzenie = Event(
          kalendarz.id,
          title: termin.tytul,
          description: termin.opis,
          start: dataPoczatek,
          end: dataKoniec,
          allDay: false
      );

      final wynik = await _kalendarz.createOrUpdateEvent(wydarzenie);
      return wynik?.isSuccess ?? false;
    } catch (e) {
      print('Błąd podczas dodawania do kalendarza: $e');
      return false;
    }
  }

  Future<void> wczytajTerminy() async {
    final pref = await SharedPreferences.getInstance();
    final listaJson = pref.getStringList('terminy') ?? [];
    _terminy = listaJson.map((json) {
      try {
        return Termin.zMapy(jsonDecode(json) as Map<String, dynamic>);
      } catch (e) {
        print('Błąd podczas parsowania terminu: $e');
        return null;
      }
    })
        .where((termin) => termin != null)
        .cast<Termin>()
        .toList();
    _terminy.sort((a, b) => a.data.compareTo(b.data));
  }

  Future<void> zapiszTerminy() async {
    final pref = await SharedPreferences.getInstance();
    final listaJson = _terminy.map((t) => jsonEncode(t.doMapy())).toList();
    await pref.setStringList('terminy', listaJson);
  }

  Future<void> dodajPowiadomienie(Termin termin) async {
    final AndroidNotificationDetails androidSzczegoly = AndroidNotificationDetails(
      'terminy_kanal',
      'Przypomnienia o terminach',
      importance: Importance.max,
      priority: Priority.high,
    );

    final teraz = DateTime.now();
    final czasPowiadomienia = termin.data.subtract(Duration(days: 1));

    if (czasPowiadomienia.isAfter(teraz)) {
      final terminPowiadomienia = tz.TZDateTime.from(czasPowiadomienia, tz.local);

      await _powiadomienia.zonedSchedule(
        termin.hashCode,
        'Przypomnienie: ${termin.tytul}',
        'Zbliża się termin: ${termin.opis}',
        terminPowiadomienia,
        NotificationDetails(android: androidSzczegoly),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<bool> dodajTermin(Termin nowyTermin) async {
    _terminy.add(nowyTermin);
    _terminy.sort((a, b) => a.data.compareTo(b.data));
    await zapiszTerminy();
    final dodanoDoKalendarza = await dodajDoKalendarza(nowyTermin);
    await dodajPowiadomienie(nowyTermin);
    return dodanoDoKalendarza;
  }

  Future<void> usunTermin(String id) async {
    _terminy.removeWhere((termin) => termin.id == id);
    await zapiszTerminy();
  }

  bool czyTerminPilny(DateTime data) {
    return data.difference(DateTime.now()).inDays <= 3;
  }

  String formatujPozostalyCzas(DateTime data) {
    final pozostalyCzas = data.difference(DateTime.now());
    if (pozostalyCzas.inDays > 0) {
      return 'Pozostało: ${pozostalyCzas.inDays} dni';
    } else if (pozostalyCzas.inHours > 0) {
      return 'Pozostało: ${pozostalyCzas.inHours} godzin';
    } else {
      return 'Pozostało: ${pozostalyCzas.inMinutes} minut';
    }
  }
}