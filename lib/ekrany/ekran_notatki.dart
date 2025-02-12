import 'package:flutter/material.dart';
import '../../viewmodels/notatki_view_model.dart';
import '../../models/notatka_model.dart';

class EkranNotatki extends StatefulWidget {
  @override
  _EkranNotatkiState createState() => _EkranNotatkiState();
}

class _EkranNotatkiState extends State<EkranNotatki> {
  final NotatkiViewModel _viewModel = NotatkiViewModel();
  final TextEditingController tytulKontroler = TextEditingController();
  final TextEditingController trescKontroler = TextEditingController();

  @override
  void initState() {
    super.initState();
    _zaladujNotatki();
  }

  Future<void> _zaladujNotatki() async {
    try {
      await _viewModel.zaladujNotatki();
      setState(() {});
    } catch (blad) {
      pokazKomunikat(blad.toString());
    }
  }

  void pokazKomunikat(String tekst) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tekst))
    );
  }

  void pokazOknoEdycji(Notatka notatka) {
    tytulKontroler.text = notatka.tytul;
    trescKontroler.text = notatka.tresc;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (kontekst) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(kontekst).viewInsets.bottom,
              top: 16,
              left: 16,
              right: 16
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tytulKontroler,
                decoration: InputDecoration(labelText: "Tytuł"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: trescKontroler,
                decoration: InputDecoration(labelText: "Treść"),
                maxLines: 5,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _viewModel.edytujNotatke(
                        notatka.id,
                        tytulKontroler.text.trim(),
                        trescKontroler.text.trim()
                    );
                    setState(() {});
                    Navigator.pop(kontekst);
                  } catch (blad) {
                    pokazKomunikat(blad.toString());
                  }
                },
                child: Text("Zapisz zmiany"),
              )
            ],
          ),
        );
      },
    );
  }

  void pokazOknoDodawania() {
    tytulKontroler.clear();
    trescKontroler.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (kontekst) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(kontekst).viewInsets.bottom,
              top: 16,
              left: 16,
              right: 16
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tytulKontroler,
                decoration: InputDecoration(labelText: "Tytuł"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: trescKontroler,
                decoration: InputDecoration(labelText: "Treść"),
                maxLines: 5,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _viewModel.zapiszNotatke(
                        tytulKontroler.text.trim(),
                        trescKontroler.text.trim()
                    );
                    setState(() {});
                    Navigator.pop(kontekst);
                  } catch (blad) {
                    pokazKomunikat(blad.toString());
                  }
                },
                child: Text("Dodaj notatkę"),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Twoje Notatki"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: _viewModel.notatki.isEmpty
            ? Center(child: Text("Brak notatek. Dodaj nową!"))
            : ListView.builder(
          itemCount: _viewModel.notatki.length,
          itemBuilder: (kontekst, indeks) {
            final notatka = _viewModel.notatki[indeks];
            return Card(
              color: Colors.blue[100],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              child: ListTile(
                title: Text(
                  notatka.tytul,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(notatka.tresc),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.save_alt, color: Colors.blue),
                      onPressed: () async {
                        try {
                          await _viewModel.zapiszNotatkeDoPlikuTxt(notatka);
                          pokazKomunikat('Zapisano notatkę');
                        } catch (blad) {
                          pokazKomunikat(blad.toString());
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.green),
                      onPressed: () => pokazOknoEdycji(notatka),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        try {
                          await _viewModel.usunNotatke(notatka.id);
                          setState(() {});
                          pokazKomunikat('Usunięto notatkę');
                        } catch (blad) {
                          pokazKomunikat(blad.toString());
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: pokazOknoDodawania,
        child: Icon(Icons.add),
      ),
    );
  }
}