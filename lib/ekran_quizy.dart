import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Pytanie {
  final String id;
  final String tresc;
  final List<String> odpowiedzi;
  final int poprawnaOdpowiedz;
  final String kategoria;
  int liczbaPoprawnychOdpowiedzi;
  int liczbaProb;

  Pytanie({
    required this.id,
    required this.tresc,
    required this.odpowiedzi,
    required this.poprawnaOdpowiedz,
    required this.kategoria,
    this.liczbaPoprawnychOdpowiedzi = 0,
    this.liczbaProb = 0,
  });

  Map<String, dynamic> doMapy() {
    return {
      'id': id,
      'tresc': tresc,
      'odpowiedzi': odpowiedzi,
      'poprawnaOdpowiedz': poprawnaOdpowiedz,
      'kategoria': kategoria,
      'liczbaPoprawnychOdpowiedzi': liczbaPoprawnychOdpowiedzi,
      'liczbaProb': liczbaProb,
    };
  }

  factory Pytanie.zMapy(Map<String, dynamic> mapa) {
    return Pytanie(
      id: mapa['id'],
      tresc: mapa['tresc'],
      odpowiedzi: List<String>.from(mapa['odpowiedzi']),
      poprawnaOdpowiedz: mapa['poprawnaOdpowiedz'],
      kategoria: mapa['kategoria'],
      liczbaPoprawnychOdpowiedzi: mapa['liczbaPoprawnychOdpowiedzi'] ?? 0,
      liczbaProb: mapa['liczbaProb'] ?? 0,
    );
  }
}

class EkranQuizow extends StatefulWidget {
  @override
  _EkranQuizowState createState() => _EkranQuizowState();
}

class _EkranQuizowState extends State<EkranQuizow> {
  List<Pytanie> pytania = [];
  Set<String> kategorie = {};

  @override
  void initState() {
    super.initState();
    _wczytajPytania();
  }

  Future<void> _wczytajPytania() async {
    final pref = await SharedPreferences.getInstance();
    final listaJson = pref.getStringList('pytania') ?? [];
    setState(() {
      pytania = listaJson
          .map((json) => Pytanie.zMapy(jsonDecode(json)))
          .toList();
      kategorie = pytania.map((p) => p.kategoria).toSet();
    });
  }

  Future<void> _zapiszPytania() async {
    final pref = await SharedPreferences.getInstance();
    final listaJson = pytania.map((p) => jsonEncode(p.doMapy())).toList();
    await pref.setStringList('pytania', listaJson);
  }

  void _usunKategorie(String kategoria) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Usuń kategorię'),
        content: Text('Czy na pewno chcesz usunąć kategorię "$kategoria" wraz ze wszystkimi pytaniami?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                pytania.removeWhere((pytanie) => pytanie.kategoria == kategoria);
                kategorie.remove(kategoria);
              });
              _zapiszPytania();
              Navigator.pop(context);
            },
            child: Text('Usuń'),
          ),
        ],
      ),
    );
  }

  void _pokazFormularzDodawania() {
    final formKlucz = GlobalKey<FormState>();
    String kategoria = '';
    List<Pytanie> tymczasowePytania = [];

    void dodajPytanie(BuildContext context) {
      final pytanieFormKlucz = GlobalKey<FormState>();
      String trescPytania = '';
      List<String> odpowiedzi = ['', '', '', ''];
      int wybranaOdpowiedz = 0;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Container(
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.all(16),
              child: Text(
                'Nowe pytanie',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            titlePadding: EdgeInsets.zero,
            content: Form(
              key: pytanieFormKlucz,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Treść pytania',
                        prefixIcon: Icon(Icons.help_outline, color: Colors.purple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.purple, width: 2),
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                      value?.isEmpty ?? true ? 'Wprowadź treść pytania' : null,
                      onSaved: (value) => trescPytania = value ?? '',
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Zaznacz poprawną odpowiedź',
                      style: TextStyle(
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    ...List.generate(4, (index) => Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Radio<int>(
                            value: index,
                            groupValue: wybranaOdpowiedz,
                            activeColor: Colors.purple,
                            onChanged: (value) => setState(() {
                              wybranaOdpowiedz = value ?? 0;
                            }),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Odpowiedź ${index + 1}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: Colors.purple, width: 2),
                                ),
                              ),
                              validator: (value) =>
                              value?.isEmpty ?? true ? 'Wprowadź odpowiedź' : null,
                              onSaved: (value) => odpowiedzi[index] = value ?? '',
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
                child: Text('Anuluj'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (pytanieFormKlucz.currentState?.validate() ?? false) {
                    pytanieFormKlucz.currentState?.save();
                    final nowePytanie = Pytanie(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      tresc: trescPytania,
                      odpowiedzi: odpowiedzi,
                      poprawnaOdpowiedz: wybranaOdpowiedz,
                      kategoria: kategoria,
                    );
                    tymczasowePytania.add(nowePytanie);
                    Navigator.pop(context);
                    dodajPytanie(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text('Dodaj'),
              ),
              ElevatedButton(
                onPressed: () {
                  final czyWszystkiePytaniaDodane =
                      pytanieFormKlucz.currentState?.validate() ?? false;

                  if (czyWszystkiePytaniaDodane) {
                    pytanieFormKlucz.currentState?.save();
                    final nowePytanie = Pytanie(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      tresc: trescPytania,
                      odpowiedzi: odpowiedzi,
                      poprawnaOdpowiedz: wybranaOdpowiedz,
                      kategoria: kategoria,
                    );
                    tymczasowePytania.add(nowePytanie);
                  }

                  Navigator.pop(context);
                  _zapiszQuiz(tymczasowePytania);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text('Zakończ'),
              ),
            ],
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nowy quiz'),
        content: Form(
          key: formKlucz,
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Kategoria quizu',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
            value?.isEmpty ?? true ? 'Wprowadź kategorię' : null,
            onSaved: (value) => kategoria = value ?? '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKlucz.currentState?.validate() ?? false) {
                formKlucz.currentState?.save();
                Navigator.pop(context);
                dodajPytanie(context);
              }
            },
            child: Text('Dalej'),
          ),
        ],
      ),
    );
  }

  void _zapiszQuiz(List<Pytanie> nowePytania) {
    setState(() {
      pytania.addAll(nowePytania);
      kategorie.add(nowePytania.first.kategoria);
    });
    _zapiszPytania();
  }

  void _rozpocznijQuiz(String kategoria) {
    final pytaniaKategorii = pytania
        .where((p) => p.kategoria == kategoria)
        .toList()
      ..shuffle();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EkranQuizu(
          pytania: pytaniaKategorii,
          onZakonczenie: () {
            _zapiszPytania();
            _wczytajPytania();
          },
        ),
      ),
    );
  }

  void _pokazStatystyki(String kategoria) {
    final pytaniaKategorii = pytania.where((p) => p.kategoria == kategoria);
    final sredniaPoprawnych = pytaniaKategorii.isEmpty ? 0.0 :
    pytaniaKategorii
        .map((p) => p.liczbaProb == 0 ? 0.0 :
    p.liczbaPoprawnychOdpowiedzi / p.liczbaProb * 100)
        .reduce((a, b) => a + b) / pytaniaKategorii.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Statystyki - $kategoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Liczba pytań: ${pytaniaKategorii.length}'),
            Text('Średni wynik: ${sredniaPoprawnych.toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Zamknij'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quizy'),
        backgroundColor: Colors.purple,
      ),
      body: kategorie.isEmpty
          ? Center(
        child: Text(
          'Brak quizów',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: kategorie.length,
        itemBuilder: (context, index) {
          final kategoria = kategorie.elementAt(index);
          final liczbaPytan = pytania
              .where((p) => p.kategoria == kategoria)
              .length;

          return Card(
            child: ListTile(
              title: Text(kategoria),
              subtitle: Text('Liczba pytań: $liczbaPytan'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.bar_chart),
                    onPressed: () => _pokazStatystyki(kategoria),
                  ),
                  IconButton(
                    icon: Icon(Icons.play_arrow),
                    onPressed: () => _rozpocznijQuiz(kategoria),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _usunKategorie(kategoria),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pokazFormularzDodawania,
        label: Text('Dodaj pytanie'),
        icon: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }
}

class EkranQuizu extends StatefulWidget {
  final List<Pytanie> pytania;
  final VoidCallback onZakonczenie;

  EkranQuizu({
    required this.pytania,
    required this.onZakonczenie,
  });

  @override
  _EkranQuizuState createState() => _EkranQuizuState();
}

class _EkranQuizuState extends State<EkranQuizu> {
  int aktualnePytanie = 0;
  int? wybranaOdpowiedz;
  bool czySprawdzone = false;
  int poprawneOdpowiedzi = 0;
  bool czyOdpowiedzPoprawna = false;

  void _sprawdzOdpowiedz() {
    if (wybranaOdpowiedz == null) return;

    setState(() {
      czySprawdzone = true;
      czyOdpowiedzPoprawna = wybranaOdpowiedz == widget.pytania[aktualnePytanie].poprawnaOdpowiedz;

      if (czyOdpowiedzPoprawna) {
        poprawneOdpowiedzi++;
        widget.pytania[aktualnePytanie].liczbaPoprawnychOdpowiedzi++;
      }
      widget.pytania[aktualnePytanie].liczbaProb++;
    });
  }

  void _nastepnePytanie() {
    if (aktualnePytanie < widget.pytania.length - 1) {
      setState(() {
        aktualnePytanie++;
        wybranaOdpowiedz = null;
        czySprawdzone = false;
        czyOdpowiedzPoprawna = false;
      });
    } else {
      _zakonczQuiz();
    }
  }

  void _zakonczQuiz() {
    widget.onZakonczenie();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Quiz zakończony', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Twój wynik: $poprawneOdpowiedzi/${widget.pytania.length}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '(${(poprawneOdpowiedzi / widget.pytania.length * 100).toStringAsFixed(1)}%)',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: Text('Zakończ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pytanie = widget.pytania[aktualnePytanie];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz - ${pytanie.kategoria}'),
        backgroundColor: Colors.purple,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${aktualnePytanie + 1}/${widget.pytania.length}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (aktualnePytanie + 1) / widget.pytania.length,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  pytanie.tresc,
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 16),
            ...List.generate(
              pytanie.odpowiedzi.length,
                  (index) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: czySprawdzone
                        ? index == pytanie.poprawnaOdpowiedz
                        ? Colors.green
                        : index == wybranaOdpowiedz
                        ? Colors.red
                        : Colors.grey[200]
                        : wybranaOdpowiedz == index
                        ? Colors.purple
                        : Colors.grey[200],
                    foregroundColor: czySprawdzone
                        ? index == pytanie.poprawnaOdpowiedz ||
                        index == wybranaOdpowiedz
                        ? Colors.white
                        : Colors.black
                        : wybranaOdpowiedz == index
                        ? Colors.white
                        : Colors.black,
                  ),
                  onPressed: czySprawdzone
                      ? null
                      : () => setState(() => wybranaOdpowiedz = index),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(pytanie.odpowiedzi[index]),
                  ),
                ),
              ),
            ),
            if (czySprawdzone) Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    czyOdpowiedzPoprawna ? Icons.check_circle : Icons.cancel,
                    color: czyOdpowiedzPoprawna ? Colors.green : Colors.red,
                    size: 30,
                  ),
                  SizedBox(width: 8),
                  Text(
                    czyOdpowiedzPoprawna
                        ? 'Poprawna odpowiedź!'
                        : 'Niepoprawna odpowiedź',
                    style: TextStyle(
                      color: czyOdpowiedzPoprawna ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: czySprawdzone
                    ? (aktualnePytanie == widget.pytania.length - 1
                    ? Colors.purple
                    : Colors.blue)
                    : Colors.purple,
                padding: EdgeInsets.all(16),
              ),
              onPressed: wybranaOdpowiedz == null
                  ? null
                  : czySprawdzone
                  ? (aktualnePytanie == widget.pytania.length - 1
                  ? _zakonczQuiz
                  : _nastepnePytanie)
                  : _sprawdzOdpowiedz,
              child: Text(
                czySprawdzone
                    ? (aktualnePytanie == widget.pytania.length - 1
                    ? 'Zakończ quiz'
                    : 'Następne pytanie')
                    : 'Sprawdź odpowiedź',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}