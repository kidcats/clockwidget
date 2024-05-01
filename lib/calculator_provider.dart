// calculator_provider.dart
import 'package:flutter/material.dart';

class CalculatorProvider extends ChangeNotifier {
  double _xValue = 0.0;
  int _contactorAmperage = 9;
  double _minThermalRelayCurrentRange = 0.0;
  double _maxThermalRelayCurrentRange = 0.0;

  final _notifier = ValueNotifier<int>(9);
  ValueNotifier<int> get contactorAmperageNotifier => _notifier;

  double get xValue => _xValue;
  int get contactorAmperage => _contactorAmperage;
  double get minThermalRelayCurrentRange => _minThermalRelayCurrentRange;
  double get maxThermalRelayCurrentRange => _maxThermalRelayCurrentRange;

  void updateXValue(double value) {
    _xValue = value;
    _calculateThermalRelayCurrentRange();
    notifyListeners();
  }

  void updateContactorAmperage(int value) {
    _contactorAmperage = value;
    _notifier.value = value; // Notify the notifier about the value change
    _calculateThermalRelayCurrentRange();
    notifyListeners();
  }

void _calculateThermalRelayCurrentRange() {
  if (_xValue <= 0.37) {
    _contactorAmperage = 9;
    _minThermalRelayCurrentRange = 0.8;
    _maxThermalRelayCurrentRange = 1.2;
  } else if (_xValue <= 0.55) {
    _contactorAmperage = 9;
    _minThermalRelayCurrentRange = 1.2;
    _maxThermalRelayCurrentRange = 1.8;
  } else if (_xValue <= 0.75) {
    _contactorAmperage = 9;
    _minThermalRelayCurrentRange = 1.8;
    _maxThermalRelayCurrentRange = 2.6;
  } else if (_xValue <= 1.1) {
    _contactorAmperage = 12;
    _minThermalRelayCurrentRange = 2.6;
    _maxThermalRelayCurrentRange = 3.8;
  } else if (_xValue <= 1.5) {
    _contactorAmperage = 18;
    _minThermalRelayCurrentRange = 3.2;
    _maxThermalRelayCurrentRange = 4.8;
  } else if (_xValue <= 2.2) {
    _contactorAmperage = 25;
    _minThermalRelayCurrentRange = 4.0;
    _maxThermalRelayCurrentRange = 6.0;
  } else if (_xValue <= 3.0) {
    _contactorAmperage = 32;
    _minThermalRelayCurrentRange = 5.0;
    _maxThermalRelayCurrentRange = 7.0;
  } else if (_xValue <= 4.0) {
    _contactorAmperage = 32;
    _minThermalRelayCurrentRange = 7.0;
    _maxThermalRelayCurrentRange = 10.0;
  } else if (_xValue <= 5.5) {
    _contactorAmperage = 38;
    _minThermalRelayCurrentRange = 10.0;
    _maxThermalRelayCurrentRange = 14.0;
  } else if (_xValue <= 7.5) {
    _contactorAmperage = 38;
    _minThermalRelayCurrentRange = 14.0;
    _maxThermalRelayCurrentRange = 18.0;
  } else if (_xValue <= 11.0) {
    _contactorAmperage = 40;
    _minThermalRelayCurrentRange = 21.0;
    _maxThermalRelayCurrentRange = 29.0;
  } else if (_xValue <= 15.0) {
    _contactorAmperage = 40;
    _minThermalRelayCurrentRange = 24.0;
    _maxThermalRelayCurrentRange = 36.0;
  } else if (_xValue <= 18.5) {
    _contactorAmperage = 50;
    _minThermalRelayCurrentRange = 33.0;
    _maxThermalRelayCurrentRange = 47.0;
  } else if (_xValue <= 22.0) {
    _contactorAmperage = 65;
    _minThermalRelayCurrentRange = 34.0;
    _maxThermalRelayCurrentRange = 55.0;
  } else if (_xValue <= 30.0) {
    _contactorAmperage = 80;
    _minThermalRelayCurrentRange = 55.0;
    _maxThermalRelayCurrentRange = 71.0;
  } else if (_xValue <= 37.0) {
    _contactorAmperage = 95;
    _minThermalRelayCurrentRange = 63.0;
    _maxThermalRelayCurrentRange = 84.0;
  } else if (_xValue <= 45.0) {
    _contactorAmperage = 110;
    _minThermalRelayCurrentRange = 80.0;
    _maxThermalRelayCurrentRange = 110.0;
  } else if (_xValue <= 55.0) {
    _contactorAmperage = 150;
    _minThermalRelayCurrentRange = 90.0;
    _maxThermalRelayCurrentRange = 130.0;
  } else if (_xValue <= 75.0) {
    _contactorAmperage = 185;
    _minThermalRelayCurrentRange = 130.0;
    _maxThermalRelayCurrentRange = 170.0;
  } else if (_xValue <= 90.0) {
    _contactorAmperage = 225;
    _minThermalRelayCurrentRange = 130.0;
    _maxThermalRelayCurrentRange = 195.0;
  } else if (_xValue <= 110.0) {
    _contactorAmperage = 265;
    _minThermalRelayCurrentRange = 167.0;
    _maxThermalRelayCurrentRange = 250.0;
  } else if (_xValue <= 132.0) {
    _contactorAmperage = 265;
    _minThermalRelayCurrentRange = 200.0;
    _maxThermalRelayCurrentRange = 330.0;
  } else if (_xValue <= 160.0) {
    _contactorAmperage = 330;
    _minThermalRelayCurrentRange = 250.0;
    _maxThermalRelayCurrentRange = 350.0;
  } else if (_xValue <= 200.0) {
    _contactorAmperage = 400;
    _minThermalRelayCurrentRange = 320.0;
    _maxThermalRelayCurrentRange = 480.0;
  }
}
}