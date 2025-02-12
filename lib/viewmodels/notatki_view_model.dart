import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../models/notatka_model.dart';

class NotatkiViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Notatka> _notatki = [];

  List<Notatka> get notatki => _notatki;

  Future<void> zaladujNotatki() async {
    try {
      final uzytkownik = _auth.currentUser;
      if (uzytkownik != null) {
        final odczyt = await _firestore
            .collection('notatki')
            .where('userId', isEqualTo: uzytkownik.uid)
            .orderBy('timestamp', descending: true)
            .get();

        _notatki = odczyt.docs
            .map((dok) => Notatka(
          id: dok.id,
          tytul: dok['tytul'] as String,
          tresc: dok['tresc'] as String,
        ))
            .toList();
      }
    } catch (blad) {
      throw Exception('Błąd podczas ładowania notatek');
    }
  }

  Future<void> zapiszNotatke(String tytul, String tresc) async {
    try {
      final uzytkownik = _auth.currentUser;
      if (tytul.isEmpty || tresc.isEmpty || uzytkownik == null) {
        throw Exception('Wypełnij wszystkie pola');
      }

      await _firestore.collection('notatki').add({
        'userId': uzytkownik.uid,
        'tytul': tytul,
        'tresc': tresc,
        'timestamp': FieldValue.serverTimestamp()
      });

      await zaladujNotatki();
    } catch (blad) {
      throw Exception('Błąd podczas zapisu notatki');
    }
  }

  Future<void> edytujNotatke(String id, String tytul, String tresc) async {
    try {
      if (tytul.isEmpty || tresc.isEmpty) {
        throw Exception('Wypełnij wszystkie pola');
      }

      await _firestore.collection('notatki').doc(id).update({
        'tytul': tytul,
        'tresc': tresc,
      });

      await zaladujNotatki();
    } catch (blad) {
      throw Exception('Błąd podczas edycji notatki');
    }
  }

  Future<void> usunNotatke(String id) async {
    try {
      await _firestore.collection('notatki').doc(id).delete();
      await zaladujNotatki();
    } catch (blad) {
      throw Exception('Błąd podczas usuwania notatki');
    }
  }

  Future<void> zapiszNotatkeDoPlikuTxt(Notatka notatka) async {
    if (await sprawdzUprawnienia()) {
      try {
        Directory? katalogPobranych = Directory('/storage/emulated/0/Download');
        if (!await katalogPobranych.exists()) {
          katalogPobranych = Directory('/storage/emulated/0/Downloads');
        }

        final nazwaPliku = 'notatka_${notatka.id}.txt';
        final plik = File('${katalogPobranych.path}/$nazwaPliku');

        String zawartosc = 'Tytuł: ${notatka.tytul}\nTreść: ${notatka.tresc}';
        await plik.writeAsString(zawartosc);
      } catch (blad) {
        throw Exception('Błąd podczas zapisu do pliku');
      }
    } else {
      throw Exception('Brak uprawnień do zapisu');
    }
  }

  Future<bool> sprawdzUprawnienia() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }
}