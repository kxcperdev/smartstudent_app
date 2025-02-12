import 'package:shared_preferences/shared_preferences.dart';

class UstawieniaViewModel {
  bool _trybCiemny = false;
  final Function(bool) _zmienMotyw;

  bool get trybCiemny => _trybCiemny;

  UstawieniaViewModel({required Function(bool) zmienMotyw}) : _zmienMotyw = zmienMotyw;

  Future<void> wczytajUstawienia() async {
    final ustawienia = await SharedPreferences.getInstance();
    _trybCiemny = ustawienia.getBool('tryb_ciemny') ?? false;
  }

  Future<void> zmienTrybCiemny(bool nowaWartosc) async {
    final ustawienia = await SharedPreferences.getInstance();
    await ustawienia.setBool('tryb_ciemny', nowaWartosc);
    _trybCiemny = nowaWartosc;
    _zmienMotyw(nowaWartosc);
  }
}