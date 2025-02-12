import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/terminy_view_model.dart';
import '../../models/termin_model.dart';
import 'package:permission_handler/permission_handler.dart';

class EkranTerminow extends StatefulWidget {
  @override
  _EkranTerminowState createState() => _EkranTerminowState();
}

class _EkranTerminowState extends State<EkranTerminow> {
  final TerminViewModel _viewModel = TerminViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.inicjalizuj().then((_) => setState(() {}));
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
                          setState(() {});
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
                await _viewModel.dodajTermin(nowyTermin);
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: Text('Zapisz'),
          ),
        ],
      ),
    );
  }

  void _pokazDialogUprawnien() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terminy'),
        backgroundColor: Colors.green,
      ),
      body: _viewModel.terminy.isEmpty
          ? Center(
        child: Text(
          'Brak terminów',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _viewModel.terminy.length,
        itemBuilder: (context, index) {
          final termin = _viewModel.terminy[index];
          final jestPilne = _viewModel.czyTerminPilny(termin.data);

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
                        onPressed: () async {
                          await _viewModel.usunTermin(termin.id);
                          setState(() {});
                        },
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
                        _viewModel.formatujPozostalyCzas(termin.data),
                        style: TextStyle(
                          color: jestPilne ? Colors.red : Colors.grey[600],
                          fontWeight: jestPilne ? FontWeight.bold : FontWeight.normal,
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