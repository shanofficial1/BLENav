import 'beacon.dart';
import 'corridor.dart';
import 'navigation_graph.dart';

class Building {
  final String id;

  final String name;

  final Corridor corridor;

  final List<Beacon> beacons;

  final NavigationGraph graph;

  const Building({
    required this.id,
    required this.name,
    required this.corridor,
    required this.beacons,
    required this.graph,
  });
}