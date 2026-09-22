import 'package:flutter/material.dart';

import '../../models/demo_project.dart';
import '../../models/room.dart';

class IndoorMapPainter extends CustomPainter {
  final project = DemoProject.data;

  static const double scale = 50;

  static const double corridorX = 300;

  static const double corridorWidth = 90;

  static const double topY = 200;

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.white,
    );

    final corridor = project.building.corridor;

    //---------------------------------------------------
    // Draw Corridor
    //---------------------------------------------------

    final corridorPaint = Paint()
      ..color = const Color(0xFFDCC8A4);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          corridorX,
          topY,
          corridorWidth,
          corridor.length * scale,
        ),
        const Radius.circular(10),
      ),
      corridorPaint,
    );

    //---------------------------------------------------
    // Draw Rooms
    //---------------------------------------------------

    for (final room in corridor.rooms) {
      final roomTop =
          topY + room.startMeter * scale;

      final roomHeight =
          room.length * scale;

      double left;

      if (room.side == RoomSide.left) {
        left = corridorX - 260;
      } else {
        left = corridorX + corridorWidth + 20;
      }

      final rect = Rect.fromLTWH(
        left,
        roomTop,
        220,
        roomHeight,
      );

      canvas.drawRect(
        rect,
        Paint()..color = room.color,
      );

      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: room.name,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      tp.layout(maxWidth: 180);

      tp.paint(
        canvas,
        Offset(
          rect.left + 12,
          rect.top + 12,
        ),
      );
    }

    //---------------------------------------------------
    // Draw Beacons
    //---------------------------------------------------

    final beaconPaint = Paint()
      ..color = Colors.blue;

    final coveragePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue.withOpacity(.10);

//---------------------------------------------------
// Draw Walk Path
//---------------------------------------------------

final graph = project.building.graph;

final pathPaint = Paint()
  ..color = Colors.green.shade700
  ..strokeWidth = 6
  ..strokeCap = StrokeCap.round;

for (final edge in graph.edges) {
  final from = graph.nodes.firstWhere(
    (n) => n.id == edge.from,
  );

  final to = graph.nodes.firstWhere(
    (n) => n.id == edge.to,
  );

  canvas.drawLine(
    from.position,
    to.position,
    pathPaint,
  );
}



//---------------------------------------------------
// Draw Navigation Nodes
//---------------------------------------------------

final nodePaint = Paint()
  ..color = Colors.green;

for (final node in graph.nodes) {
  canvas.drawCircle(
    node.position,
    8,
    nodePaint,
  );
}



    for (final beacon in project.building.beacons) {
      canvas.drawCircle(
        beacon.position,
        beacon.range * scale,
        coveragePaint,
      );

      canvas.drawCircle(
        beacon.position,
        12,
        beaconPaint,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: beacon.id,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      tp.layout();

      tp.paint(
        canvas,
        beacon.position + const Offset(20, -10),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}