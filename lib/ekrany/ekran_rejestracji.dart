import 'package:flutter/material.dart';
import '../../viewmodels/rejestracja_view_model.dart';

class EkranRejestracji extends StatefulWidget {
  @override
  _EkranRejestracjiState createState() => _EkranRejestracjiState();
}

class _EkranRejestracjiState extends State<EkranRejestracji> {
  final RejestracjaViewModel _viewModel = RejestracjaViewModel();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _hasloController = TextEditingController();
  final TextEditingController _powtorzHasloController = TextEditingController();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _rejestracja() async {
    final sukces = await _viewModel.rejestracja(
      _emailController.text.trim(),
      _hasloController.text.trim(),
      _powtorzHasloController.text.trim(),
    );

    if (sukces) {
      _viewModel.monitorujWeryfikacje(
        _emailController.text.trim(),
        _hasloController.text.trim(),
            () => Navigator.pushReplacementNamed(context, "/glowny"),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_add, size: 100, color: Colors.green),
              SizedBox(height: 20),
              Text("Rejestracja", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "E-mail", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _hasloController,
                decoration: InputDecoration(labelText: "Hasło", border: OutlineInputBorder()),
                obscureText: true,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _powtorzHasloController,
                decoration: InputDecoration(labelText: "Powtórz hasło", border: OutlineInputBorder()),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _viewModel.oczekujeNaPotwierdzenie ? null : _rejestracja,
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                child: Text(_viewModel.oczekujeNaPotwierdzenie ? "Oczekiwanie na potwierdzenie..." : "Zarejestruj się"),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/logowanie"),
                child: Text("Masz już konto? Zaloguj się"),
              ),
              SizedBox(height: 10),
              Text(_viewModel.blad, style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}