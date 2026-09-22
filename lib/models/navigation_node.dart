import 'dart:ui';

class NavigationNode {
  String id;

  Offset position;

  // A single node can belong to multiple rooms.
  //
  // Example:
  // N3 -> Room 101, Room 102, Room 103
  List<String> roomIds;

  NavigationNode({
    required this.id,
    required this.position,
    this.roomIds = const [],
  });

  double get x => position.dx;

  double get y => position.dy;

  void updatePosition({
    required double x,
    required double y,
  }) {
    position = Offset(x, y);
  }
}