import '../../models/editor_beacon.dart';

class BeaconStore {
  BeaconStore._();

  static final BeaconStore instance = BeaconStore._();

  final List<EditorBeacon> _beacons = [];

  List<EditorBeacon> get beacons =>
      List.unmodifiable(_beacons);

  bool get hasBeacons => _beacons.isNotEmpty;

  void saveBeacons(List<EditorBeacon> beacons) {
    _beacons
      ..clear()
      ..addAll(
        beacons.map(
          (beacon) => EditorBeacon(
            id: beacon.id,
            name: beacon.name,
            macAddress: beacon.macAddress,
            position: beacon.position,
            range: beacon.range,
            nodeId: beacon.nodeId,
          ),
        ),
      );
  }

  EditorBeacon? getById(String id) {
    for (final beacon in _beacons) {
      if (beacon.id == id) {
        return beacon;
      }
    }

    return null;
  }

  void remove(String id) {
    _beacons.removeWhere(
      (beacon) => beacon.id == id,
    );
  }

  void clear() {
    _beacons.clear();
  }
}