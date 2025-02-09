// lib/termin.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:device_calendar/device_calendar.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class Termin {
  final String tytul;
  final String opis;
  final DateTime data;
  final String typ;
  final String id;
  final int trudnosc;

  Termin({
    required this.tytul,
    required this.opis,
    required this.data,
    required this.typ,
    required this.id,
    required this.trudnosc,
  });

  Map<String, dynamic> doMapy() {
    return {
      'tytul': tytul,
      'opis': opis,
      'data': data.toIso8601String(),
      'typ': typ,
      'id': id,
      'trudnosc': trudnosc,
    };
  }

  factory Termin.zMapy(Map<String, dynamic> mapa) {
    return Termin(
      tytul: mapa['tytul'],
      opis: mapa['opis'],
      data: DateTime.parse(mapa['data']),
      typ: mapa['typ'],
      id: mapa['id'],
      trudnosc: mapa['trudnosc'] ?? 1,
    );
  }
}

class EkranTerminow extends StatefulWidget {
  @override
  _EkranTerminowState createState() => _EkranTerminowState();
}

class _EkranTerminowState extends State<EkranTerminow> {
  final FlutterLocalNotificationsPlugin _powiadomienia = FlutterLocalNotificationsPlugin();
  final DeviceCalendarPlugin _kalendarz = DeviceCalendarPlugin();
  List<Termin> terminy = [];

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _inicjalizujPowiadomienia();
    _wczytajTerminy();
    _sprawdzUprawnienia();
  }

  Future<void> _sprawdzUprawnienia() async {
    var statusKalendarza = await Permission.calendar.status;
    if (statusKalendarza.isDenied) {
      await Permission.calendar.request();
    }

    // Sprawdź ponownie po prośbie o uprawnienia
    statusKalendarza = await Permission.calendar.status;
    if (statusKalendarza.isPermanentlyDenied) {
      // Możesz tutaj pokazać dialog informujący użytkownika
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Wymagane uprawnienia'),
          content: Text('Aby dodawać wydarzenia do kalendarza, potrzebne są odpowiednie uprawnienia. Przejdź do ustawień aplikacji, aby je włączyć.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () => openAppSettings(),
              child: Text('Otwórz ustawienia'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _inicjalizujPowiadomienia() async {
    const AndroidInitializationSettings androidUstawienia =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings ustawienia =
    InitializationSettings(android: androidUstawienia);
    await _powiadomienia.initialize(ustawienia);
  }

  Future<void> _dodajDoKalendarza(Termin termin) async {
    try {
      final permissionStatus = await Permission.calendar.status;

      if (!permissionStatus.isGranted) {
        final result = await Permission.calendar.request();
        if (!result.isGranted) {
          return;
        }
      }

      final wynikKalendarzy = await _kalendarz.retrieveCalendars();

      if (!wynikKalendarzy.isSuccess || wynikKalendarzy.data == null) {
        return;
      }

      Calendar? kalendarz;
      for (var k in wynikKalendarzy.data!) {
        if (k.isReadOnly == false) {
          kalendarz = k;
          break;
        }
      }

      if (kalendarz == null) {
        return;
      }

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

      await _kalendarz.createOrUpdateEvent(wydarzenie);
    } catch (e, stack) {
      print('Błąd podczas dodawania do kalendarza: $e');
    }
  }

  Future<void> _wczytajTerminy() async {
    final pref = await SharedPreferences.getInstance();
    final listaJson = pref.getStringList('terminy') ?? [];
    setState(() {
      terminy = listaJson.map((json) {
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
      terminy.sort((a, b) => a.data.compareTo(b.data));
    });
  }

  Future<void> _zapiszTerminy() async {
    final pref = await SharedPreferences.getInstance();
    final listaJson = terminy.map((t) => jsonEncode(t.doMapy())).toList();
    await pref.setStringList('terminy', listaJson);
  }

  Future<void> _dodajPowiadomienie(Termin termin) async {
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

  Widget _wyswietlGwiazdki(int liczba) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < liczba ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  void _pokazFormularzDodawania() {
    final formularza = GlobalKey<FormState>();
    String tytul = '';
    String opis = '';
    DateTime wybranaData = DateTime.now();
    String typ = 'Egzamin';
    int trudnosc = 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nowy termin'),
        content: Container(
          width: double.maxFinite,
          child: Form(
            key: formularza,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tytuł',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    onSaved: (wartosc) => tytul = wartosc ?? '',
                    validator: (wartosc) =>
                    wartosc?.isEmpty ?? true ? 'Wymagane pole' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Opis',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    maxLines: 3,
                    onSaved: (wartosc) => opis = wartosc ?? '',
                    validator: (wartosc) =>
                    wartosc?.isEmpty ?? true ? 'Wymagane pole' : null,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Typ',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    value: typ,
                    items: ['Egzamin', 'Kolokwium', 'Praca domowa']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (wartosc) => typ = wartosc ?? 'Egzamin',
                  ),
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Poziom trudności:'),
                      Row(
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < trudnosc ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () {
                              trudnosc = index + 1;
                              // Wymuszamy odświeżenie widoku
                              (context as Element).markNeedsBuild();
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    title: Text('Data i godzina'),
                    subtitle: Text(
                      DateFormat('dd.MM.yyyy HH:mm').format(wybranaData),
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final data = await showDatePicker(
                        context: context,
                        initialDate: wybranaData,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (data != null) {
                        final czas = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(wybranaData),
                        );
                        if (czas != null) {
                          wybranaData = DateTime(
                            data.year,
                            data.month,
                            data.day,
                            czas.hour,
                            czas.minute,
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Anuluj'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () async {
              if (formularza.currentState?.validate() ?? false) {
                formularza.currentState?.save();
                final nowyTermin = Termin(
                  tytul: tytul,
                  opis: opis,
                  data: wybranaData,
                  typ: typ,
                  trudnosc: trudnosc,
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                );
                setState(() {
                  terminy.add(nowyTermin);
                  terminy.sort((a, b) => a.data.compareTo(b.data));
                });
                await _zapiszTerminy();
                await _dodajDoKalendarza(nowyTermin);
                await _dodajPowiadomienie(nowyTermin);
                Navigator.pop(context);
              }
            },
            child: Text('Zapisz'),
          ),
        ],
      ),
    );
  }

  void _usunTermin(String id) async {
    setState(() {
      terminy.removeWhere((termin) => termin.id == id);
    });
    await _zapiszTerminy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terminy'),
        backgroundColor: Colors.green,
      ),
      body: terminy.isEmpty
          ? Center(
        child: Text(
          'Brak terminów',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: terminy.length,
        itemBuilder: (context, index) {
          final termin = terminy[index];
          final pozostalyCzas = termin.data.difference(DateTime.now());
          final jestPilne = pozostalyCzas.inDays <= 3;

          return Card(
            elevation: 4,
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            termin.typ == 'Egzamin'
                                ? Icons.school
                                : termin.typ == 'Kolokwium'
                                ? Icons.assignment
                                : Icons.home_work,
                            color: jestPilne ? Colors.red : Colors.green,
                            size: 28,
                          ),
                          SizedBox(width: 8),
                          Text(
                            termin.typ,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _usunTermin(termin.id),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    termin.tytul,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    termin.opis,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  _wyswietlGwiazdki(termin.trudnosc),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd.MM.yyyy HH:mm').format(termin.data),
                        style: TextStyle(
                          color: jestPilne ? Colors.red : Colors.grey[600],
                          fontWeight: jestPilne ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      Text(
                        pozostalyCzas.inDays > 0
                            ? 'Pozostało: ${pozostalyCzas.inDays} dni'
                            : pozostalyCzas.inHours > 0
                            ? 'Pozostało: ${pozostalyCzas.inHours} godzin'
                            : 'Pozostało: ${pozostalyCzas.inMinutes} minut',
                        style: TextStyle(
                          color: jestPilne ? Colors.red : Colors.grey[600],
                          fontWeight: jestPilne ? FontWeight.bold : FontWeight
                              .normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pokazFormularzDodawania,
        icon: Icon(Icons.add),
        label: Text('Dodaj termin'),
        backgroundColor: Colors.green,
      ),
    );
  }
  }

