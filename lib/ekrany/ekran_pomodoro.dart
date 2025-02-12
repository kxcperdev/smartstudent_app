import 'package:flutter/material.dart';
import '../../viewmodels/pomodoro_view_model.dart';
// ignore: unused_import
import '../../models/sesja_model.dart';

class EkranPomodoro extends StatefulWidget {
  @override
  _EkranPomodoroState createState() => _EkranPomodoroState();
}

class _EkranPomodoroState extends State<EkranPomodoro> {
  final PomodoroViewModel _viewModel = PomodoroViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.inicjalizuj();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _pokazDialogUsuwaniaHistorii() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Usuń historię sesji'),
          content: Text('Czy na pewno chcesz usunąć całą historię sesji?'),
          actions: <Widget>[
            TextButton(
              child: Text('Anuluj'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Usuń'),
              onPressed: () {
                _viewModel.usunHistorie();
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tryb Pomodoro"),
        backgroundColor: _viewModel.czyPrzerwa ? Colors.green : Colors.red,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: _viewModel.czyPrzerwa ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _viewModel.czyPrzerwa ? "Przerwa" : "Czas nauki",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _viewModel.czyPrzerwa ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      _viewModel.formatujCzas(),
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: _viewModel.czyPrzerwa ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          onPressed: () {
                            if (_viewModel.czyDziala) {
                              _viewModel.stopTimer();
                            } else {
                              _viewModel.startTimer(
                                    () => setState(() {}),
                                    () => setState(() {}),
                              );
                            }
                            setState(() {});
                          },
                          backgroundColor: _viewModel.czyPrzerwa ? Colors.green : Colors.red,
                          child: Icon(_viewModel.czyDziala ? Icons.pause : Icons.play_arrow),
                          heroTag: "start/stop",
                        ),
                        SizedBox(width: 20),
                        FloatingActionButton(
                          onPressed: () {
                            _viewModel.resetujTimer();
                            setState(() {});
                          },
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.refresh),
                          heroTag: "reset",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Historia sesji",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_viewModel.historiaSesji.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: _pokazDialogUsuwaniaHistorii,
                    tooltip: 'Usuń historię sesji',
                  ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: _viewModel.historiaSesji.length,
                  itemBuilder: (context, index) {
                    final sesja = _viewModel.historiaSesji[index];
                    final bool czyNauka = sesja.typ == 'Nauka';
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        leading: Icon(
                          czyNauka ? Icons.school : Icons.coffee,
                          color: czyNauka ? Colors.red : Colors.green,
                        ),
                        title: Text(
                          sesja.typ,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(sesja.data),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}