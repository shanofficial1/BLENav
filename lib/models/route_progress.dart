import 'package:flutter/material.dart';

import 'walk_node.dart';

class RouteProgress {
  final WalkNode previousNode;

  final WalkNode nextNode;

  final Offset currentPosition;

  final double currentMeter;

  /// 0.0 → previous node
  /// 1.0 → next node
  final double edgeProgress;

  final double remainingDistance;

  const RouteProgress({
    required this.previousNode,
    required this.nextNode,
    required this.currentPosition,
    required this.currentMeter,
    required this.edgeProgress,
    required this.remainingDistance,
  });
}