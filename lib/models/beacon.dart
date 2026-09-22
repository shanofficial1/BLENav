import 'package:flutter/material.dart';

class Beacon {
  final String id;

  final String macAddress;

  double meter;

  Offset position;

  double range;

  Beacon({
    required this.id,
    required this.macAddress,
    required this.meter,
    required this.position,
    this.range = 4,
  });
}