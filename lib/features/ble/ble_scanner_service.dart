import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'beacon_locator_service.dart';
import 'ble_position_service.dart';

class BleScannerService extends ChangeNotifier {
  static final BleScannerService instance =
      BleScannerService();

  StreamSubscription<List<ScanResult>>? _subscription;

  bool scanning = false;

  List<ScanResult> scanResults = [];

  Future<void> startScan() async {
    if (scanning) return;

    scanning = true;

    notifyListeners();

    await FlutterBluePlus.startScan();

   _subscription =
    FlutterBluePlus.onScanResults.listen((results) {

  scanResults = results;

for (final result in results) {
  final beacon = BeaconLocatorService.instance.nearestBeacon(
    result.device.remoteId.str,
  );

  if (beacon == null) {
    continue;
  }

  final distance =
      BeaconLocatorService.instance.rssiToDistance(
    result.rssi,
    -85, // RSSI at 1 meter (adjust after calibration)
    2.0, // Path-loss exponent
  );

  final meter =
      BeaconLocatorService.instance.estimateMeter(
    beacon,
    distance,
  );

  BlePositionService.instance.updatePosition(meter);

  debugPrint("==============");
  debugPrint("Beacon : ${beacon.id}");
  debugPrint("RSSI : ${result.rssi}");
  debugPrint("Distance : ${distance.toStringAsFixed(2)} m");
  debugPrint("Meter : ${meter.toStringAsFixed(2)}");
}
  notifyListeners();

});
  }

  Future<void> stopScan() async {
    scanning = false;

    await FlutterBluePlus.stopScan();

    await _subscription?.cancel();

    notifyListeners();
  }
}