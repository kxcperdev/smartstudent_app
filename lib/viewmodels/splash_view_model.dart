import 'package:flutter/material.dart';
import 'dart:async';

class SplashViewModel {
  late AnimationController controller;
  late Animation<double> fadeAnimation;

  void initAnimation(TickerProvider vsync) {
    controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: vsync,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
    controller.forward();
  }

  void dispose() {
    controller.dispose();
  }

  Timer ustawPrzejscie(Function(String) onNavigate) {
    return Timer(Duration(seconds: 3), () {
      onNavigate("/autoryzacja");
    });
  }
}