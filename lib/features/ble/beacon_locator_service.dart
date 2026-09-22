import '../../models/demo_project.dart';
import '../../models/beacon.dart';

import 'dart:math';

class BeaconLocatorService {
  static final BeaconLocatorService instance =
      BeaconLocatorService();

  BeaconLocatorService();

  /// RSSI -> Distance (Log Distance Path Loss)
  double rssiToDistance(
    int rssi,
    double rssiAt1m,
    double n,
  ) {
    return pow(
      10,
      (rssiAt1m - rssi) / (10 * n),
    ).toDouble();
  }

  Beacon? nearestBeacon(String mac) {

    for (final beacon
        in DemoProject.data.building.beacons) {

      if (beacon.macAddress == mac) {
        return beacon;
      }
    }

    return null;
  }

  /// Estimate current corridor meter
double estimateMeter(
  Beacon beacon,
  double distance,
) {
  double meter;

  if (beacon.id == "B1") {
    // Beginning of corridor
    meter = beacon.meter + distance;
  } else if (beacon.id == "B3") {
    // End of corridor
    meter = beacon.meter - distance;
  } else {
    // Middle beacon (temporary solution)
    meter = beacon.meter;
  }

  final maxMeter =
      DemoProject.data.building.corridor.length.toDouble();

  return meter.clamp(0.0, maxMeter);
}
}