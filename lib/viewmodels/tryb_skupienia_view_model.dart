import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/aplikacja_info_model.dart';

class TrybSkupieniaViewModel {
  static const platform = MethodChannel('tryb_skupienia');
  List<AplikacjaInfo> _aplikacje = [];
  List<String> _zablokowanePlikacje = [];
  bool _trybSkupieniaAktywny = false;
  Timer? _czasomierz;
  int _licznik = 0;

  List<AplikacjaInfo> get aplikacje => _aplikacje;
  List<String> get zablokowanePlikacje => _zablokowanePlikacje;
  bool get trybSkupieniaAktywny => _trybSkupieniaAktywny;
  int get licznik => _licznik;

  void wczytajListeAplikacji() {
    _aplikacje = [
      AplikacjaInfo(
        nazwa: 'Facebook',
        pakiet: 'com.facebook.katana',
        ikona: Icons.facebook,
      ),
      AplikacjaInfo(
        nazwa: 'Instagram',
        pakiet: 'com.instagram.android',
        ikona: Icons.camera_alt,
      ),
      AplikacjaInfo(
        nazwa: 'TikTok',
        pakiet: 'com.zhiliaoapp.musically',
        ikona: Icons.horizontal_split_rounded,
      ),
      AplikacjaInfo(
        nazwa: 'YouTube',
        pakiet: 'com.google.android.youtube',
        ikona: Icons.play_circle_outline,
      ),
      AplikacjaInfo(
        nazwa: 'Twitter/X',
        pakiet: 'com.twitter.android',
        ikona: Icons.share,
      ),
      AplikacjaInfo(
        nazwa: 'Messenger',
        pakiet: 'com.facebook.orca',
        ikona: Icons.message,
      ),
    ];
  }

  Future<void> wczytajZablokowanePlikacje() async {
    final ustawienia = await SharedPreferences.getInstance();
    _zablokowanePlikacje = ustawienia.getStringList('zablokowanePlikacje') ?? [];
  }

  Future<void> zapiszZablokowanePlikacje() async {
    final ustawienia = await SharedPreferences.getInstance();
    await ustawienia.setStringList('zablokowanePlikacje', _zablokowanePlikacje);
  }

  void przelaczBlokade(String pakiet) {
    if (_zablokowanePlikacje.contains(pakiet)) {
      _zablokowanePlikacje.remove(pakiet);
    } else {
      _zablokowanePlikacje.add(pakiet);
    }
    zapiszZablokowanePlikacje();
  }

  Future<void> przelaczTrybSkupienia(bool value) async {
    _trybSkupieniaAktywny = value;
    try {
      if (_trybSkupieniaAktywny) {
        await platform.invokeMethod('wlaczTrybSkupienia');
      } else {
        await platform.invokeMethod('wylaczTrybSkupienia');
      }
    } catch (e) {
      print('Błąd podczas przełączania trybu skupienia: $e');
    }
  }

  void wlaczLicznik(Function onTick) {
    _licznik = 0;
    _czasomierz = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      _licznik++;
      onTick();
    });
  }

  void zwiekszLicznik() {
    _licznik++;
  }

  void zatrzymajLicznik() {
    _czasomierz?.cancel();
  }
}