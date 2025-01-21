import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EkranUstawienia extends StatefulWidget {
  final Function(bool) zmienMotyw;

  EkranUstawienia({required this.zmienMotyw});

  @override
  _EkranUstawieniaState createState() => _EkranUstawieniaState();
}

class _EkranUstawieniaState extends State<EkranUstawienia> {
  bool trybCiemny = false;

  @override
  void initState() {
    super.initState();
    _wczytajUstawienia();
  }

  Future<void> _wczytajUstawienia() async {
    final ustawienia = await SharedPreferences.getInstance();
    setState(() {
      trybCiemny = ustawienia.getBool('tryb_ciemny') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ustawienia'),
        backgroundColor: Colors.grey,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Tryb ciemny'),
            value: trybCiemny,
            activeColor: Colors.grey,
            onChanged: (nowaWartosc) async {
              final ustawienia = await SharedPreferences.getInstance();
              await ustawienia.setBool('tryb_ciemny', nowaWartosc);
              setState(() {
                trybCiemny = nowaWartosc;
              });
              widget.zmienMotyw(nowaWartosc);
            },
          ),
        ],
      ),
    );
  }
}