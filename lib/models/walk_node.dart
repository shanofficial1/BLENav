import 'package:flutter/material.dart';

enum NodeType {
  entrance,
  corridor,
  intersection,
  destination,
  stairs,
  lift,
}

class WalkNode {
  final String id;

  final Offset position;

  final double meter;

  final NodeType type;

  /// Room served by this node
  final String? roomId;

  /// Nearest beacon
  final String? beaconId;

  /// Connected nodes
  final List<String> connections;

  const WalkNode({
    required this.id,
    required this.position,
    required this.meter,
    required this.type,
    required this.connections,
    this.roomId,
    this.beaconId,
  });
}