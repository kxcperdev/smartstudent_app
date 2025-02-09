import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class EkranNotatki extends StatefulWidget {
  @override
  _EkranNotatkiState createState() => _EkranNotatkiState();
}

class _EkranNotatkiState extends State<EkranNotatki> {
  final TextEditingController tytulKontroler = TextEditingController();
  final TextEditingController trescKontroler = TextEditingController();
  List<Map<String, dynamic>> listaNotatek = [];

  @override
  void initState() {
    super.initState();
    zaladujNotatki();
  }

  Future<void> zaladujNotatki() async {
    try {
      final uzytkownik = FirebaseAuth.instance.currentUser;
      if (uzytkownik != null) {
        final odczyt = await FirebaseFirestore.instance
            .collection('notatki')
            .where('userId', isEqualTo: uzytkownik.uid)
            .orderBy('timestamp', descending: true)
            .get();

        setState(() {
          listaNotatek = odczyt.docs.map((dok) => {
            'id': dok.id,
            'tytul': dok['tytul'] as String,
            'tresc': dok['tresc'] as String
          }).toList();
        });
      }
    } catch (blad) {
      pokazKomunikat('Błąd podczas ładowania notatek');
    }
  }

  Future<void> zapiszNotatkeDoPlikuTxt(String tytul, String tresc, String notatkaId) async {
    if (await sprawdzUprawnienia()) {
      try {
        Directory? katalogPobranych = Directory('/storage/emulated/0/Download');
        if (!await katalogPobranych.exists()) {
          katalogPobranych = Directory('/storage/emulated/0/Downloads');
        }

        final nazwaPliku = 'notatka_${notatkaId}.txt';
        final plik = File('${katalogPobranych.path}/$nazwaPliku');

        String zawartosc = 'Tytuł: $tytul\nTreść: $tresc';
        await plik.writeAsString(zawartosc);

        pokazKomunikat('Zapisano notatkę: $nazwaPliku');
      } catch (blad) {
        pokazKomunikat('Błąd podczas zapisu do pliku');
      }
    }
  }

  Future<bool> sprawdzUprawnienia() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  void pokazKomunikat(String tekst) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tekst))
    );
  }

  Future<void> zapiszNotatke() async {
    try {
      final tytul = tytulKontroler.text.trim();
      final tresc = trescKontroler.text.trim();
      final uzytkownik = FirebaseAuth.instance.currentUser;

      if (tytul.isEmpty || tresc.isEmpty || uzytkownik == null) {
        pokazKomunikat('Wypełnij wszystkie pola');
        return;
      }

      await FirebaseFirestore.instance.collection('notatki').add({
        'userId': uzytkownik.uid,
        'tytul': tytul,
        'tresc': tresc,
        'timestamp': FieldValue.serverTimestamp()
      });

      tytulKontroler.clear();
      trescKontroler.clear();
      zaladujNotatki();
    } catch (blad) {
      pokazKomunikat('Błąd podczas zapisu notatki');
    }
  }

  Future<void> edytujNotatke(String id, String tytul, String tresc) async {
    try {
      if (tytul.isEmpty || tresc.isEmpty) {
        pokazKomunikat('Wypełnij wszystkie pola');
        return;
      }

      await FirebaseFirestore.instance.collection('notatki').doc(id).update({
        'tytul': tytul,
        'tresc': tresc,
      });
      zaladujNotatki();
    } catch (blad) {
      pokazKomunikat('Błąd podczas edycji notatki');
    }
  }

  Future<void> usunNotatke(String id) async {
    try {
      await FirebaseFirestore.instance.collection('notatki').doc(id).delete();
      zaladujNotatki();
      pokazKomunikat('Usunięto notatkę');
    } catch (blad) {
      pokazKomunikat('Błąd podczas usuwania notatki');
    }
  }

  void pokazOknoEdycji(String id, String aktualnyTytul, String aktualnaTresc) {
    tytulKontroler.text = aktualnyTytul;
    trescKontroler.text = aktualnaTresc;
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
                onPressed: () {
                  edytujNotatke(id, tytulKontroler.text.trim(), trescKontroler.text.trim());
                  Navigator.pop(kontekst);
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
                onPressed: () {
                  zapiszNotatke();
                  Navigator.pop(kontekst);
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
        child: listaNotatek.isEmpty
            ? Center(child: Text("Brak notatek. Dodaj nową!"))
            : ListView.builder(
          itemCount: listaNotatek.length,
          itemBuilder: (kontekst, indeks) {
            final notatka = listaNotatek[indeks];
            return Card(
              color: Colors.blue[100],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              child: ListTile(
                title: Text(
                  notatka['tytul']!,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(notatka['tresc']!),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.save_alt, color: Colors.blue),
                      onPressed: () => zapiszNotatkeDoPlikuTxt(
                          notatka['tytul']!,
                          notatka['tresc']!,
                          notatka['id']!
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.green),
                      onPressed: () => pokazOknoEdycji(
                          notatka['id']!,
                          notatka['tytul']!,
                          notatka['tresc']!
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => usunNotatke(notatka['id']!),
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