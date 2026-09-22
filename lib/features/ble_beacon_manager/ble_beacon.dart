class BleBeacon {
  final String macAddress;
  String name;

  BleBeacon({
    required this.macAddress,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'macAddress': macAddress,
      'name': name,
    };
  }

  factory BleBeacon.fromJson(Map<String, dynamic> json) {
    return BleBeacon(
      macAddress: json['macAddress'] ?? '',
      name: json['name'] ?? 'BLE Beacon',
    );
  }
}