import 'package:flutter/material.dart';

enum RoomSide {
  left,
  right,
  center,
}

class Room {
  final String id;
  final String name;

  final double startMeter;
  final double endMeter;

  final RoomSide side;

  final Color color;

  const Room({
    required this.id,
    required this.name,
    required this.startMeter,
    required this.endMeter,
    required this.side,
    this.color = const Color(0xFFD6C19C),
  });

  double get length => endMeter - startMeter;
}