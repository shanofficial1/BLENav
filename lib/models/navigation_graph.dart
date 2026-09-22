import 'walk_edge.dart';
import 'walk_node.dart';

class NavigationGraph {
  final List<WalkNode> nodes;

  final List<WalkEdge> edges;

  const NavigationGraph({
    required this.nodes,
    required this.edges,
  });
}