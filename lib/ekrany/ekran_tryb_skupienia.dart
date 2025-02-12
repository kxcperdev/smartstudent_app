import 'package:flutter/material.dart';
import '../../viewmodels/tryb_skupienia_view_model.dart';

class EkranTrybSkupienia extends StatefulWidget {
  @override
  _EkranTrybSkupieniaState createState() => _EkranTrybSkupieniaState();
}

class _EkranTrybSkupieniaState extends State<EkranTrybSkupienia> {
  final TrybSkupieniaViewModel _viewModel = TrybSkupieniaViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.wczytajListeAplikacji();
    _viewModel.wczytajZablokowanePlikacje();
  }

  void _przelaczTrybSkupienia(bool value) {
    setState(() {
      _viewModel.przelaczTrybSkupienia(value);
      if (_viewModel.trybSkupieniaAktywny) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EkranSkupienia(viewModel: _viewModel)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tryb Skupienia'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aktywuj Tryb Skupienia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Switch(
                  value: _viewModel.trybSkupieniaAktywny,
                  onChanged: _przelaczTrybSkupienia,
                  activeColor: Colors.white,
                  activeTrackColor: Colors.teal.shade200,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 16),
              itemCount: _viewModel.aplikacje.length,
              itemBuilder: (context, index) {
                final aplikacja = _viewModel.aplikacje[index];
                return ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      aplikacja.ikona,
                      color: Colors.teal,
                      size: 30,
                    ),
                  ),
                  title: Text(
                    aplikacja.nazwa,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EkranSkupienia extends StatefulWidget {
  final TrybSkupieniaViewModel viewModel;

  EkranSkupienia({required this.viewModel});

  @override
  _EkranSkupieniaState createState() => _EkranSkupieniaState();
}

class _EkranSkupieniaState extends State<EkranSkupienia> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.wlaczLicznik(() => setState(() {}));
  }

  @override
  void dispose() {
    widget.viewModel.zatrzymajLicznik();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: Center(
          child: GestureDetector(
            onTap: () {
              widget.viewModel.zwiekszLicznik();
              setState(() {});
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Center(
                child: Text(
                  '${widget.viewModel.licznik}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}