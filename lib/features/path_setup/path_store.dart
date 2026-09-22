import 'package:flutter/material.dart';

import '../../models/navigation_node.dart';
import '../../models/navigation_edge.dart';

class PathStore {
  PathStore._();

  static final PathStore instance = PathStore._();

  // ============================================================
  // SAVED PATH
  // ============================================================

  List<NavigationNode> _nodes = [];

  List<NavigationEdge> _edges = [];

  // ============================================================
  // GETTERS
  // ============================================================

  List<NavigationNode> get nodes =>
      List.unmodifiable(_nodes);

  List<NavigationEdge> get edges =>
      List.unmodifiable(_edges);

  bool get hasPath =>
      _nodes.isNotEmpty;

  bool get hasEdges =>
      _edges.isNotEmpty;

  // ============================================================
  // SAVE PATH
  // ============================================================

  void savePath({
    required List<NavigationNode> nodes,
    required List<NavigationEdge> edges,
  }) {
    _nodes = nodes
        .map(
          (node) => NavigationNode(
            id: node.id,
            position: node.position,
            roomIds: List<String>.from(
              node.roomIds,
            ),
          ),
        )
        .toList();

    _edges = edges
        .map(
          (edge) => NavigationEdge(
            from: edge.from,
            to: edge.to,
          ),
        )
        .toList();

    debugPrint('');
    debugPrint(
      '======================================',
    );
    debugPrint(
      '             PATH SAVED',
    );
    debugPrint(
      '======================================',
    );

    for (final node in _nodes) {
      debugPrint(
        'NODE ${node.id} '
        '(${node.position.dx.toStringAsFixed(1)}, '
        '${node.position.dy.toStringAsFixed(1)}) '
        'ROOMS: ${node.roomIds}',
      );
    }

    for (final edge in _edges) {
      debugPrint(
        'PATH ${edge.from} -> ${edge.to}',
      );
    }

    debugPrint(
      '======================================',
    );
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clearPath() {
    _nodes = [];
    _edges = [];

    debugPrint(
      'PathStore: path cleared',
    );
  }

  // ============================================================
  // FIND NODE
  // ============================================================

  NavigationNode? getNode(
    String id,
  ) {
    for (final node in _nodes) {
      if (node.id == id) {
        return node;
      }
    }

    return null;
  }

  // ============================================================
  // FIND NODE BY ROOM
  // ============================================================

  NavigationNode? getNodeByRoom(
    String roomId,
  ) {
    for (final node in _nodes) {
      if (node.roomIds.contains(roomId)) {
        return node;
      }
    }

    return null;
  }

  // ============================================================
  // PATH DISTANCE
  // ============================================================

  double get totalPixelDistance {
    double total = 0;

    for (final edge in _edges) {
      final from = getNode(edge.from);
      final to = getNode(edge.to);

      if (from == null || to == null) {
        continue;
      }

      total +=
          (from.position - to.position)
              .distance;
    }

    return total;
  }
}