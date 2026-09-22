import '../../models/demo_project.dart';
import '../../models/walk_node.dart';

import '../../models/navigation_route.dart';

import '../../models/route_progress.dart';

import 'package:flutter/material.dart';

import 'path_destination_service.dart';


class NavigationService {
  static final NavigationService instance = NavigationService();

  final graph = DemoProject.data.building.graph;

  WalkNode? getNode(String id) {
    for (final node in graph.nodes) {
      if (node.id == id) return node;
    }
    return null;
  }

  WalkNode? getNodeByRoom(String roomId) {
    for (final node in graph.nodes) {
      if (node.roomId == roomId) return node;
    }
    return null;
  }

  WalkNode? getNodeByBeacon(String beaconId) {
    for (final node in graph.nodes) {
      if (node.beaconId == beaconId) return node;
    }
    return null;
  }

  WalkNode? getNearestNode(double meter) {
    WalkNode? nearest;
    double minDistance = double.infinity;

    for (final node in graph.nodes) {
      final d = (node.meter - meter).abs();

      if (d < minDistance) {
        minDistance = d;
        nearest = node;
      }
    }

    return nearest;
  }

  NavigationRoute findRoute(
  WalkNode start,
  WalkNode destination,
) {
  final routeNodes = <WalkNode>[];

  final startIndex =
      graph.nodes.indexWhere((n) => n.id == start.id);

  final endIndex =
      graph.nodes.indexWhere((n) => n.id == destination.id);

  if (startIndex == -1 || endIndex == -1) {
    return const NavigationRoute(
      nodes: [],
      totalDistance: 0,
    );
  }

  double distance = 0;

  if (startIndex <= endIndex) {
    for (int i = startIndex; i <= endIndex; i++) {
      routeNodes.add(graph.nodes[i]);

      if (i < endIndex) {
        distance += graph.edges[i].distance;
      }
    }
  } else {
    for (int i = startIndex; i >= endIndex; i--) {
      routeNodes.add(graph.nodes[i]);

      if (i > endIndex) {
        distance += graph.edges[i - 1].distance;
      }
    }
  }

  return NavigationRoute(
    nodes: routeNodes,
    totalDistance: distance,
  );
}


RouteProgress getRouteProgress(
  double currentMeter,
  WalkNode destination,
) {
  final nodes = graph.nodes;

  WalkNode previous = nodes.first;
  WalkNode next = nodes.last;

  double progress = 0;

  Offset position = nodes.first.position;

  for (int i = 0; i < nodes.length - 1; i++) {

    final start = nodes[i].meter;
    final end = nodes[i + 1].meter;

    if (currentMeter >= start &&
        currentMeter <= end) {

      previous = nodes[i];
      next = nodes[i + 1];

      progress =
          (currentMeter - start) /
          (end - start);

      position = Offset.lerp(
        previous.position,
        next.position,
        progress,
      )!;

      break;
    }
  }

  return RouteProgress(
    previousNode: previous,
    nextNode: next,
    currentPosition: position,
    currentMeter: currentMeter,
    edgeProgress: progress,
    remainingDistance:
        (destination.meter - currentMeter)
            .clamp(0, double.infinity),
  );
}

}