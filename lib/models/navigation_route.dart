import 'walk_node.dart';

class NavigationRoute {
  final List<WalkNode> nodes;

  final double totalDistance;

  const NavigationRoute({
    required this.nodes,
    required this.totalDistance,
  });
}