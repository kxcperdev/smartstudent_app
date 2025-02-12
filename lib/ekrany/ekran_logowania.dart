import 'package:flutter/material.dart';
import '../../viewmodels/logowanie_view_model.dart';

class EkranLogowania extends StatefulWidget {
  @override
  _EkranLogowaniaState createState() => _EkranLogowaniaState();
}

class _EkranLogowaniaState extends State<EkranLogowania> {
  final LogowanieViewModel _viewModel = LogowanieViewModel();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _hasloController = TextEditingController();

  Future<void> _logowanie() async {
    final sukces = await _viewModel.logowanie(
      _emailController.text.trim(),
      _hasloController.text.trim(),
    );
    if (sukces) {
      Navigator.pushReplacementNamed(context, "/glowny");
    }
    setState(() {});
  }

  Future<void> _logowanieGoogle() async {
    final sukces = await _viewModel.logowanieGoogle();
    if (sukces) {
      Navigator.pushReplacementNamed(context, "/glowny");
    }
    setState(() {});
  }

  Future<void> _resetujHaslo() async {
    await _viewModel.resetujHaslo(_emailController.text.trim());
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
              Icon(Icons.school, size: 100, color: Colors.green),
              SizedBox(height: 20),
              Text("Zaloguj się", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _resetujHaslo,
                  child: Text("Zapomniałeś hasła?"),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _logowanie,
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                child: Text("Zaloguj się"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _logowanieGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text("Zaloguj przez Google"),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/rejestracja"),
                child: Text("Nie masz konta? Zarejestruj się"),
              ),
              SizedBox(height: 10),
              Text(_viewModel.infoResetHasla, style: TextStyle(color: Colors.green)),
              SizedBox(height: 10),
              Text(_viewModel.blad, style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}