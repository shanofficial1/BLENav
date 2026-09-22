import 'package:flutter/material.dart';

import '../../features/navigation/navigation_controller.dart';
import '../../features/navigation/navigation_service.dart';
import '../../features/navigation/navigation_state.dart';
import '../../features/indoor_map/movement_service.dart';

class NavigationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (!NavigationState.instance.navigating) return;

    final destination =
        NavigationController.instance.destinationNode;

    if (destination == null) return;

    final progress =
        NavigationService.instance.getRouteProgress(
      MovementService.instance.meter,
      destination,
    );

    final graph = NavigationService.instance.graph;

    final destinationIndex = graph.nodes.indexWhere(
      (n) => n.id == destination.id,
    );

    final greenPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final orangePaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < destinationIndex; i++) {
      final start = graph.nodes[i];
      final end = graph.nodes[i + 1];

      if (end.meter < progress.currentMeter) {
        canvas.drawLine(
          start.position,
          end.position,
          greenPaint,
        );
      } else if (progress.previousNode.id == start.id &&
          progress.nextNode.id == end.id) {
        canvas.drawLine(
          start.position,
          progress.currentPosition,
          greenPaint,
        );

        canvas.drawLine(
          progress.currentPosition,
          end.position,
          orangePaint,
        );
      } else if (start.meter >= progress.currentMeter) {
        canvas.drawLine(
          start.position,
          end.position,
          orangePaint,
        );
      }
    }

    final textPainter = TextPainter(
      text: const TextSpan(
        text: "🏁",
        style: TextStyle(fontSize: 28),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      destination.position + const Offset(-14, -40),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}