import 'package:flutter/material.dart';
import '../../viewmodels/quiz_view_model.dart';
import '../../models/pytanie_model.dart';

class EkranQuizow extends StatefulWidget {
  @override
  _EkranQuizowState createState() => _EkranQuizowState();
}

class _EkranQuizowState extends State<EkranQuizow> {
  final QuizViewModel _viewModel = QuizViewModel();

  @override
  void initState() {
    super.initState();
    _wczytajPytania();
  }

  Future<void> _wczytajPytania() async {
    await _viewModel.wczytajPytania();
    setState(() {});
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
            onPressed: () async {
              await _viewModel.usunKategorie(kategoria);
              setState(() {});
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
                onPressed: () async {
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
                  }
                  Navigator.pop(context);
                  await _viewModel.dodajPytania(tymczasowePytania);
                  setState(() {});
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

  void _rozpocznijQuiz(String kategoria) {
    final pytaniaKategorii = _viewModel.getPytaniaKategorii(kategoria);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EkranQuizu(
          pytania: pytaniaKategorii,
          onZakonczenie: () {
            _viewModel.zapiszPytania();
            _wczytajPytania();
          },
        ),
      ),
    );
  }

  void _pokazStatystyki(String kategoria) {
    final statystyki = _viewModel.getStatystykiKategorii(kategoria);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Statystyki - $kategoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Liczba pytań: ${statystyki['liczbaPytan']}'),
            Text('Średni wynik: ${statystyki['sredniaPoprawnych'].toStringAsFixed(1)}%'),
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
      body: _viewModel.kategorie.isEmpty
          ? Center(
        child: Text(
          'Brak quizów',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _viewModel.kategorie.length,
        itemBuilder: (context, index) {
          final kategoria = _viewModel.kategorie.elementAt(index);
          final liczbaPytan = _viewModel.getLiczbaPytanKategorii(kategoria);

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
  late QuizSessionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = QuizSessionViewModel(widget.pytania);
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
              'Twój wynik: ${_viewModel.poprawneOdpowiedzi}/${widget.pytania.length}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '(${_viewModel.obliczWynikProcentowy().toStringAsFixed(1)}%)',
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
    final pytanie = widget.pytania[_viewModel.aktualnePytanie];

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
                '${_viewModel.aktualnePytanie + 1}/${widget.pytania.length}',
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
              value: _viewModel.postep,
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
                    backgroundColor: _viewModel.czySprawdzone
                        ? index == pytanie.poprawnaOdpowiedz
                        ? Colors.green
                        : index == _viewModel.wybranaOdpowiedz
                        ? Colors.red
                        : Colors.grey[200]
                        : _viewModel.wybranaOdpowiedz == index
                        ? Colors.purple
                        : Colors.grey[200],
                    foregroundColor: _viewModel.czySprawdzone
                        ? index == pytanie.poprawnaOdpowiedz ||
                        index == _viewModel.wybranaOdpowiedz
                        ? Colors.white
                        : Colors.black
                        : _viewModel.wybranaOdpowiedz == index
                        ? Colors.white
                        : Colors.black,
                  ),
                  onPressed: _viewModel.czySprawdzone
                      ? null
                      : () {
                    _viewModel.wybierzOdpowiedz(index);
                    setState(() {});
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(pytanie.odpowiedzi[index]),
                  ),
                ),
              ),
            ),
            if (_viewModel.czySprawdzone)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _viewModel.czyOdpowiedzPoprawna
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: _viewModel.czyOdpowiedzPoprawna
                          ? Colors.green
                          : Colors.red,
                      size: 30,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _viewModel.czyOdpowiedzPoprawna
                          ? 'Poprawna odpowiedź!'
                          : 'Niepoprawna odpowiedź',
                      style: TextStyle(
                        color: _viewModel.czyOdpowiedzPoprawna
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _viewModel.czySprawdzone
                    ? (_viewModel.czyOstatniePytanie ? Colors.purple : Colors.blue)
                    : Colors.purple,
                padding: EdgeInsets.all(16),
              ),
              onPressed: _viewModel.wybranaOdpowiedz == null
                  ? null
                  : _viewModel.czySprawdzone
                  ? (_viewModel.czyOstatniePytanie
                  ? _zakonczQuiz
                  : () {
                _viewModel.przejdzDoNastepnegoPytania();
                setState(() {});
              })
                  : () {
                _viewModel.sprawdzOdpowiedz();
                setState(() {});
              },
              child: Text(
                _viewModel.czySprawdzone
                    ? (_viewModel.czyOstatniePytanie
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