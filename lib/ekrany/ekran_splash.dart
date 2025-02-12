import 'package:flutter/material.dart';
import '../../viewmodels/splash_view_model.dart';

class EkranSplash extends StatefulWidget {
  @override
  _EkranSplashState createState() => _EkranSplashState();
}

class _EkranSplashState extends State<EkranSplash> with SingleTickerProviderStateMixin {
  final SplashViewModel _viewModel = SplashViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.initAnimation(this);
    _viewModel.ustawPrzejscie((route) {
      Navigator.pushReplacementNamed(context, route);
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: FadeTransition(
          opacity: _viewModel.fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school, size: 100, color: Colors.white),
              SizedBox(height: 20),
              Text(
                "SmartStudent",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}