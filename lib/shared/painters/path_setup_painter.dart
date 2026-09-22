import 'package:flutter/material.dart';

import '../../models/navigation_node.dart';
import '../../models/navigation_edge.dart';

class PathSetupPainter extends CustomPainter {
  final List<NavigationNode> nodes;
  final List<NavigationEdge> edges;

  PathSetupPainter({
    required this.nodes,
    required this.edges,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    for (final edge in edges) {
      final from = nodes.firstWhere(
        (node) => node.id == edge.from,
      );

      final to = nodes.firstWhere(
        (node) => node.id == edge.to,
      );
      final distance =
    (from.position - to.position).distance / 100.0;

      canvas.drawLine(
        from.position,
        to.position,
        linePaint,
      );

      // -----------------------------
      // Distance label
      // -----------------------------

      final middle = Offset(
        (from.position.dx + to.position.dx) / 2,
        (from.position.dy + to.position.dy) / 2,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: "${distance.toStringAsFixed(2)} m",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        middle -
            Offset(
              textPainter.width / 2,
              textPainter.height / 2,
            ),
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant PathSetupPainter oldDelegate,
  ) {
    return true;
  }
}