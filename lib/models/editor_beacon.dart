import 'package:flutter/material.dart';

class EditorBeacon {
  String id;

  String name;

  String macAddress;

  Offset position;

  // BLE coverage radius in meters
  double range;

  // Navigation path node associated with this beacon
  String? nodeId;

  EditorBeacon({
    required this.id,
    String? name,
    this.macAddress = '',
    required this.position,
    this.range = 6.0,
    this.nodeId,
  }) : name = name ?? id;
}