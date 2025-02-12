import 'package:flutter/material.dart';
import '../../viewmodels/statystyki_view_model.dart';

class EkranStatystyki extends StatefulWidget {
  @override
  _EkranStatystykiState createState() => _EkranStatystykiState();
}

class _EkranStatystykiState extends State<EkranStatystyki> {
  final StatystykiViewModel _viewModel = StatystykiViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.wczytajDane().then((_) => setState(() {}));
    _viewModel.rozpocznijAutomatyczneOdswiezanie(() => setState(() {}));
  }

  @override
  void dispose() {
    _viewModel.zatrzymajAutomatyczneOdswiezanie();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final czasOkresu = _viewModel.obliczCzasOkresu();

    return Scaffold(
      appBar: AppBar(
        title: Text("Statystyki Użytkowania"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _viewModel.wczytajDane().then((_) => setState(() {}));
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _viewModel.wyczyscDane().then((_) => setState(() {}));
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
              selected: {_viewModel.wybranyOkres},
              onSelectionChanged: (Set<String> nowyWybor) {
                _viewModel.zmienOkres(nowyWybor.first);
                setState(() {});
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
                itemCount: _viewModel.czasUzytkowania.length,
                itemBuilder: (context, index) {
                  final data = _viewModel.czasUzytkowania.keys.elementAt(index);
                  final czas = _viewModel.czasUzytkowania[data]! / 3600;
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