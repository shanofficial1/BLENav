import 'package:flutter/material.dart';

import '../../models/navigation_node.dart';
import '../../models/navigation_edge.dart';

import '../path_setup/path_store.dart';

class PathNavigationResult {
  final NavigationNode destination;

  final List<NavigationNode> routeNodes;

  final double distanceMeters;

  const PathNavigationResult({
    required this.destination,
    required this.routeNodes,
    required this.distanceMeters,
  });
}

class PathNavigationService {
  PathNavigationService._();

  static final PathNavigationService
      instance =
      PathNavigationService._();

  // Your map currently uses
  // approximately 100 pixels = 1 meter.
  static const double pixelsPerMeter =
      100.0;

  // ============================================================
  // FIND DESTINATION NODE
  // ============================================================

  NavigationNode? findDestinationNode(
    String roomId,
  ) {
    final nodes =
        PathStore.instance.nodes;

    for (final node in nodes) {
      if (node.roomIds.contains(
        roomId,
      )) {
        return node;
      }
    }

    return null;
  }

  // ============================================================
  // FIND ROUTE
  // ============================================================

  PathNavigationResult? findRoute({
    required Offset userPosition,
    required String roomId,
  }) {
    final nodes =
        PathStore.instance.nodes;

    final edges =
        PathStore.instance.edges;

    if (nodes.isEmpty) {
      return null;
    }

    final destination =
        findDestinationNode(
      roomId,
    );

    if (destination == null) {
      return null;
    }

    // Find the path node closest
    // to the user's current position.
    final start =
        _nearestNode(
      nodes,
      userPosition,
    );

    if (start == null) {
      return null;
    }

    // Calculate shortest route.
    final route =
        _shortestRoute(
      nodes: nodes,
      edges: edges,
      startId: start.id,
      destinationId:
          destination.id,
    );

    if (route.isEmpty) {
      return null;
    }

    // User -> first path node.
    double distancePixels =
        (userPosition -
                start.position)
            .distance;

    // Path nodes.
    for (int i = 0;
        i < route.length - 1;
        i++) {
      distancePixels +=
          (route[i].position -
                  route[i + 1].position)
              .distance;
    }

    final distanceMeters =
        distancePixels /
            pixelsPerMeter;

    return PathNavigationResult(
      destination:
          destination,
      routeNodes: route,
      distanceMeters:
          distanceMeters,
    );
  }

  // ============================================================
  // NEAREST NODE
  // ============================================================

  NavigationNode? _nearestNode(
    List<NavigationNode> nodes,
    Offset position,
  ) {
    NavigationNode? nearest;

    double smallestDistance =
        double.infinity;

    for (final node in nodes) {
      final distance =
          (position -
                  node.position)
              .distance;

      if (distance <
          smallestDistance) {
        smallestDistance =
            distance;

        nearest = node;
      }
    }

    return nearest;
  }

  // ============================================================
  // SHORTEST ROUTE
  // Dijkstra
  // ============================================================

  List<NavigationNode> _shortestRoute({
    required List<NavigationNode> nodes,
    required List<NavigationEdge> edges,
    required String startId,
    required String destinationId,
  }) {
    final distances =
        <String, double>{};

    final previous =
        <String, String?>{};

    final unvisited =
        <String>{};

    for (final node in nodes) {
      distances[node.id] =
          double.infinity;

      previous[node.id] = null;

      unvisited.add(
        node.id,
      );
    }

    distances[startId] = 0;

    while (unvisited.isNotEmpty) {
      String? currentId;

      double currentDistance =
          double.infinity;

      for (final id in unvisited) {
        final distance =
            distances[id] ??
                double.infinity;

        if (distance <
            currentDistance) {
          currentDistance =
              distance;

          currentId = id;
        }
      }

      if (currentId == null) {
        break;
      }

      if (currentId ==
          destinationId) {
        break;
      }

      unvisited.remove(
        currentId,
      );

      // --------------------------------------
      // Find neighbors
      // --------------------------------------

      for (final edge in edges) {
        String? neighborId;

        // Treat edges as
        // bidirectional.
        if (edge.from ==
            currentId) {
          neighborId =
              edge.to;
        } else if (edge.to ==
            currentId) {
          neighborId =
              edge.from;
        }

        if (neighborId == null) {
          continue;
        }

        if (!unvisited
            .contains(
          neighborId,
        )) {
          continue;
        }

        final currentNode =
            nodes.firstWhere(
          (node) =>
              node.id ==
              currentId,
        );

        final neighborNode =
            nodes.firstWhere(
          (node) =>
              node.id ==
              neighborId,
        );

        final edgeDistance =
            (currentNode.position -
                    neighborNode.position)
                .distance;

        final candidateDistance =
            currentDistance +
                edgeDistance;

        final oldDistance =
            distances[
                    neighborId] ??
                double.infinity;

        if (candidateDistance <
            oldDistance) {
          distances[
                  neighborId] =
              candidateDistance;

          previous[
                  neighborId] =
              currentId;
        }
      }
    }

    // No route.
    if ((distances[
                destinationId] ??
            double.infinity) ==
        double.infinity) {
      return [];
    }

    // --------------------------------------
    // Reconstruct route
    // --------------------------------------

    final ids = <String>[];

    String? current =
        destinationId;

    while (current != null) {
      ids.add(current);

      if (current == startId) {
        break;
      }

      current =
          previous[current];
    }

    if (ids.isEmpty ||
        ids.last != startId) {
      return [];
    }

    final orderedIds =
        ids.reversed.toList();

    return orderedIds
        .map(
          (id) => nodes.firstWhere(
            (node) =>
                node.id == id,
          ),
        )
        .toList();
  }
}