import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'ble_beacon.dart';

class BleBeaconStore {
  BleBeaconStore._();

  static final BleBeaconStore instance =
      BleBeaconStore._();

  static const String _storageKey =
      'registered_ble_beacons';

  final List<BleBeacon> _beacons = [];

  List<BleBeacon> get beacons =>
      List.unmodifiable(_beacons);

  Future<void> load() async {
    final prefs =
        await SharedPreferences.getInstance();

    final data = prefs.getString(_storageKey);

    if (data == null || data.isEmpty) {
      return;
    }

    final List<dynamic> decoded =
        jsonDecode(data);

    _beacons
      ..clear()
      ..addAll(
        decoded.map(
          (item) => BleBeacon.fromJson(
            Map<String, dynamic>.from(item),
          ),
        ),
      );
  }

  Future<void> save() async {
    final prefs =
        await SharedPreferences.getInstance();

    final data = jsonEncode(
      _beacons
          .map((beacon) => beacon.toJson())
          .toList(),
    );

    await prefs.setString(
      _storageKey,
      data,
    );
  }

String normalizeMac(String mac) {
  return mac
      .trim()
      .toUpperCase()
      .replaceAll(':', '')
      .replaceAll('-', '')
      .replaceAll(' ', '');
}

bool isRegistered(String macAddress) {
  final mac = normalizeMac(macAddress);

  return _beacons.any(
    (beacon) => normalizeMac(beacon.macAddress) == mac,
  );
}

BleBeacon? getByMac(String macAddress) {
  final mac = normalizeMac(macAddress);

  for (final beacon in _beacons) {
    if (normalizeMac(beacon.macAddress) == mac) {
      return beacon;
    }
  }

  return null;
}

  Future<bool> addBeacon({
    required String macAddress,
    required String name,
  }) async {
final rawMac = macAddress.trim().toUpperCase();

final mac = rawMac
    .replaceAll('-', ':')
    .replaceAll(' ', '');
      
    if (mac.isEmpty) {
      return false;
    }

    if (isRegistered(mac)) {
      return false;
    }

    _beacons.add(
      BleBeacon(
        macAddress: mac,
        name: name.trim().isEmpty
            ? 'BLE Beacon'
            : name.trim(),
      ),
    );

    await save();

    return true;
  }

  Future<void> updateBeacon(
    String oldMac,
    String newMac,
    String name,
  ) async {
    final oldValue =
        oldMac.trim().toUpperCase();

    final newValue =
        newMac.trim().toUpperCase();

    final index = _beacons.indexWhere(
      (beacon) =>
          beacon.macAddress.toUpperCase() ==
          oldValue,
    );

    if (index == -1) {
      return;
    }

    if (oldValue != newValue &&
        isRegistered(newValue)) {
      return;
    }

    _beacons[index] = BleBeacon(
      macAddress: newValue,
      name: name.trim().isEmpty
          ? 'BLE Beacon'
          : name.trim(),
    );

    await save();
  }

  Future<void> removeBeacon(
    String macAddress,
  ) async {
    final mac =
        macAddress.trim().toUpperCase();

    _beacons.removeWhere(
      (beacon) =>
          beacon.macAddress.toUpperCase() == mac,
    );

    await save();
  }

  Future<void> clear() async {
    _beacons.clear();
    await save();
  }
}