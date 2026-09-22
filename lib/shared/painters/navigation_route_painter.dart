import 'package:flutter/material.dart';

import '../../models/navigation_node.dart';

class NavigationRoutePainter
    extends CustomPainter {
  final Offset userPosition;

  final List<NavigationNode>
      routeNodes;

  NavigationRoutePainter({
    required this.userPosition,
    required this.routeNodes,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    if (routeNodes.isEmpty) {
      return;
    }

    final paint = Paint()
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap =
          StrokeCap.round
      ..strokeJoin =
          StrokeJoin.round
      ..color = Colors.blue;

    final path = Path();

    // User → first path node.
    path.moveTo(
      userPosition.dx,
      userPosition.dy,
    );

    // Path nodes → destination.
    for (final node
        in routeNodes) {
      path.lineTo(
        node.position.dx,
        node.position.dy,
      );
    }

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant NavigationRoutePainter
        oldDelegate,
  ) {
    return oldDelegate.userPosition !=
            userPosition ||
        oldDelegate.routeNodes !=
            routeNodes;
  }
}