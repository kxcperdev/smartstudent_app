import 'package:flutter/material.dart';
import '../../viewmodels/ustawienia_view_model.dart';

class EkranUstawienia extends StatefulWidget {
  final Function(bool) zmienMotyw;

  EkranUstawienia({required this.zmienMotyw});

  @override
  _EkranUstawieniaState createState() => _EkranUstawieniaState();
}

class _EkranUstawieniaState extends State<EkranUstawienia> {
  late final UstawieniaViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = UstawieniaViewModel(zmienMotyw: widget.zmienMotyw);
    _wczytajUstawienia();
  }

  Future<void> _wczytajUstawienia() async {
    await _viewModel.wczytajUstawienia();
    setState(() {});
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
            value: _viewModel.trybCiemny,
            activeColor: Colors.grey,
            onChanged: (nowaWartosc) async {
              await _viewModel.zmienTrybCiemny(nowaWartosc);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}