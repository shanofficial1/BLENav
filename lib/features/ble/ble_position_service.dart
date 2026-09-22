import 'package:flutter/material.dart';

import '../indoor_map/movement_service.dart';

class BlePositionService extends ChangeNotifier {
  static final BlePositionService instance = BlePositionService();

  BlePositionService();

  double _meter = 0;

  double get meter => _meter;

  /// Called whenever BLE calculates a new position
  void updatePosition(double meter) {
    _meter = meter;

    // Update the navigation engine
    MovementService.instance.updateMeter(meter);

    notifyListeners();
  }
}