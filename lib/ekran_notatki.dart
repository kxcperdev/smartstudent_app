import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EkranNotatki extends StatefulWidget {
  @override
  _EkranNotatkiState createState() => _EkranNotatkiState();
}

class _EkranNotatkiState extends State<EkranNotatki> {
  final TextEditingController _tytulController = TextEditingController();
  final TextEditingController _trescController = TextEditingController();
  List<Map<String, dynamic>> _notatki = [];

  @override
  void initState() {
    super.initState();
    _zaladujNotatki();
  }

  Future<void> _zaladujNotatki() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('notatki')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .get();

        setState(() {
          _notatki = snapshot.docs.map((doc) => {
            'id': doc.id,
            'tytul': doc['tytul'] as String,
            'tresc': doc['tresc'] as String
          }).toList();
        });
      }
    } catch (e) {
      print("Błąd ładowania notatek: $e");
    }
  }

  Future<void> _zapiszNotatke() async {
    try {
      String tytul = _tytulController.text.trim();
      String tresc = _trescController.text.trim();
      final user = FirebaseAuth.instance.currentUser;

      if (tytul.isEmpty || tresc.isEmpty || user == null) {
        return;
      }

      await FirebaseFirestore.instance.collection('notatki').add({
        'userId': user.uid,
        'tytul': tytul,
        'tresc': tresc,
        'timestamp': FieldValue.serverTimestamp()
      });

      _tytulController.clear();
      _trescController.clear();
      _zaladujNotatki();
    } catch (e) {
      print("Błąd zapisu notatki: $e");
    }
  }

  Future<void> _edytujNotatke(String id, String tytul, String tresc) async {
    try {
      await FirebaseFirestore.instance.collection('notatki').doc(id).update({
        'tytul': tytul,
        'tresc': tresc,
      });
      _zaladujNotatki();
    } catch (e) {
      print("Błąd edycji notatki: $e");
    }
  }

  Future<void> _usunNotatke(String id) async {
    try {
      await FirebaseFirestore.instance.collection('notatki').doc(id).delete();
      _zaladujNotatki();
    } catch (e) {
      print("Błąd usuwania notatki: $e");
    }
  }

  void _pokazOknoEdycji(String id, String aktualnyTytul, String aktualnaTresc) {
    _tytulController.text = aktualnyTytul;
    _trescController.text = aktualnaTresc;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 16, left: 16, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tytulController,
                decoration: InputDecoration(labelText: "Tytuł"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _trescController,
                decoration: InputDecoration(labelText: "Treść"),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _edytujNotatke(id, _tytulController.text.trim(), _trescController.text.trim());
                  Navigator.pop(context);
                },
                child: Text("Zapisz zmiany"),
              )
            ],
          ),
        );
      },
    );
  }

  void _pokazOknoDodawania() {
    _tytulController.clear();
    _trescController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 16, left: 16, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tytulController,
                decoration: InputDecoration(labelText: "Tytuł"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _trescController,
                decoration: InputDecoration(labelText: "Treść"),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _zapiszNotatke();
                  Navigator.pop(context);
                },
                child: Text("Dodaj Notatkę"),
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
        child: _notatki.isEmpty
            ? Center(child: Text("Brak notatek. Dodaj nową!"))
            : ListView.builder(
          itemCount: _notatki.length,
          itemBuilder: (context, index) {
            final notatka = _notatki[index];
            return Card(
              color: Colors.blue[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                      icon: Icon(Icons.edit, color: Colors.green),
                      onPressed: () => _pokazOknoEdycji(notatka['id']!, notatka['tytul']!, notatka['tresc']!),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _usunNotatke(notatka['id']!),
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
        onPressed: _pokazOknoDodawania,
        child: Icon(Icons.add),
      ),
    );
  }
}
