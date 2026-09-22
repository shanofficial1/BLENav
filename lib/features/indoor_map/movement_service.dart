import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/beacon.dart';
import '../../models/demo_project.dart';
import '../../models/navigation_edge.dart';
import '../../models/navigation_node.dart';

import '../path_setup/path_store.dart';
import '../beacon_setup/beacon_store.dart';

class BeaconStatus {
  final Beacon beacon;
  final double distanceMeters;

  const BeaconStatus({
    required this.beacon,
    required this.distanceMeters,
  });
}

class MovementService extends ChangeNotifier {
  static final MovementService instance =
      MovementService();

  MovementService();

  // ============================================================
  // TEMPORARY SCALE
  // ============================================================
  //
  // PathSetupPainter currently calculates:
  //
  // pixels / 100 = meters
  //
  // So for the current prototype:
  //
  // 100 pixels = 1 meter
  //
  // Later, after your real building measurement,
  // change this calibration.
  //
  static const double pixelsPerMeter = 100.0;

  // ============================================================
  // USER
  // ============================================================

  double _meter = 0.0;

  double get meter => _meter;

  Offset _position = Offset.zero;

  Offset get position => _position;

  // ============================================================
  // CURRENT PATH SEGMENT
  // ============================================================

  NavigationNode? _previousNode;

  NavigationNode? get previousNode =>
      _previousNode;

  NavigationNode? _nextNode;

  NavigationNode? get nextNode =>
      _nextNode;

  double _edgeProgress = 0.0;

  double get edgeProgress =>
      _edgeProgress;

  // ============================================================
  // NEAREST NAVIGATION NODE
  // ============================================================

  NavigationNode? _nearestNode;

  NavigationNode? get nearestNode =>
      _nearestNode;

  double _distanceToNearestNode = 0.0;

  double get distanceToNearestNode =>
      _distanceToNearestNode;

  // ============================================================
  // BEACON
  // ============================================================

  Beacon? _nearestBeacon;

  Beacon? get nearestBeacon =>
      _nearestBeacon;

  double _distanceToNearestBeacon = 0.0;

  double get distanceToNearestBeacon =>
      _distanceToNearestBeacon;

  List<BeaconStatus> _beaconStatuses = [];

  List<BeaconStatus> get beaconStatuses =>
      List.unmodifiable(_beaconStatuses);

  // ============================================================
  // SAVED PATH DISTANCE
  // ============================================================

  double _totalPathMeters = 0.0;

  double get totalPathMeters =>
      _totalPathMeters;

  // ============================================================
  // INITIALIZE FROM SAVED DATA
  // ============================================================

  void initializeFromSavedPath() {
    _calculateTotalPathDistance();

    if (PathStore.instance.nodes.isEmpty) {
      _position = Offset.zero;
      _meter = 0;
      _previousNode = null;
      _nextNode = null;
      _nearestNode = null;
      _nearestBeacon = null;
      _beaconStatuses = [];

      notifyListeners();
      return;
    }

    updateMeter(
      _meter.clamp(
        0.0,
        _totalPathMeters > 0
            ? _totalPathMeters
            : 1.0,
      ),
    );
  }

  // ============================================================
  // TOTAL PATH DISTANCE
  // ============================================================

  void _calculateTotalPathDistance() {
    final nodes = PathStore.instance.nodes;
    final edges = PathStore.instance.edges;

    _totalPathMeters = 0.0;

    for (final edge in edges) {
      final from = _findNode(nodes, edge.from);
      final to = _findNode(nodes, edge.to);

      if (from == null || to == null) {
        continue;
      }

      final pixelDistance =
          (from.position - to.position).distance;

      _totalPathMeters +=
          pixelDistance / pixelsPerMeter;
    }
  }

  // ============================================================
  // UPDATE USER METER
  // ============================================================

  void updateMeter(double value) {
    final nodes = PathStore.instance.nodes;
    final edges = PathStore.instance.edges;

    if (nodes.isEmpty || edges.isEmpty) {
      return;
    }

    _calculateTotalPathDistance();

    if (_totalPathMeters <= 0) {
      return;
    }

    _meter = value
        .clamp(0.0, _totalPathMeters)
        .toDouble();

    _calculatePosition();

    _calculateCurrentSegment();

    _calculateNearestNode();

    _calculateBeaconDistances();

    _printDebug();

    notifyListeners();
  }

  // ============================================================
  // USER POSITION ALONG SAVED PATH
  // ============================================================

  void _calculatePosition() {
    final nodes = PathStore.instance.nodes;
    final edges = PathStore.instance.edges;

    double remainingMeters = _meter;

    for (final edge in edges) {
      final from =
          _findNode(nodes, edge.from);

      final to =
          _findNode(nodes, edge.to);

      if (from == null || to == null) {
        continue;
      }

      final segmentMeters =
          (from.position - to.position)
                  .distance /
              pixelsPerMeter;

      if (segmentMeters <= 0) {
        continue;
      }

      if (remainingMeters <=
          segmentMeters) {
        final t =
            (remainingMeters /
                    segmentMeters)
                .clamp(0.0, 1.0)
                .toDouble();

        _position = Offset.lerp(
          from.position,
          to.position,
          t,
        )!;

        return;
      }

      remainingMeters -=
          segmentMeters;
    }

    // At the end of the path.
    final lastEdge = edges.last;

    final lastNode =
        _findNode(nodes, lastEdge.to);

    if (lastNode != null) {
      _position = lastNode.position;
    }
  }

  // ============================================================
  // CURRENT SEGMENT
  // ============================================================

  void _calculateCurrentSegment() {
    final nodes = PathStore.instance.nodes;
    final edges = PathStore.instance.edges;

    _previousNode = null;
    _nextNode = null;
    _edgeProgress = 0.0;

    double travelled = 0.0;

    for (final edge in edges) {
      final from =
          _findNode(nodes, edge.from);

      final to =
          _findNode(nodes, edge.to);

      if (from == null || to == null) {
        continue;
      }

      final segmentMeters =
          (from.position - to.position)
                  .distance /
              pixelsPerMeter;

      if (_meter <=
          travelled + segmentMeters) {
        _previousNode = from;
        _nextNode = to;

        if (segmentMeters > 0) {
          _edgeProgress =
              ((_meter - travelled) /
                      segmentMeters)
                  .clamp(0.0, 1.0)
                  .toDouble();
        }

        return;
      }

      travelled += segmentMeters;
    }

    // At final node.
    if (edges.isNotEmpty) {
      final lastEdge = edges.last;

      _previousNode =
          _findNode(
        nodes,
        lastEdge.from,
      );

      _nextNode =
          _findNode(
        nodes,
        lastEdge.to,
      );

      _edgeProgress = 1.0;
    }
  }

  // ============================================================
  // NEAREST NODE
  // ============================================================

  void _calculateNearestNode() {
    final nodes = PathStore.instance.nodes;

    if (nodes.isEmpty) {
      _nearestNode = null;
      _distanceToNearestNode = 0.0;
      return;
    }

    NavigationNode? closest;

    double smallestPixelDistance =
        double.infinity;

    for (final node in nodes) {
      final pixelDistance =
          (_position - node.position).distance;

      if (pixelDistance <
          smallestPixelDistance) {
        smallestPixelDistance =
            pixelDistance;

        closest = node;
      }
    }

    _nearestNode = closest;

    _distanceToNearestNode =
        smallestPixelDistance /
            pixelsPerMeter;
  }

  // ============================================================
  // BEACON DISTANCES
  // ============================================================

  void _calculateBeaconDistances() {
    final savedBeacons =
        BeaconStore.instance.beacons;

    if (savedBeacons.isEmpty) {
      _beaconStatuses = [];
      _nearestBeacon = null;
      _distanceToNearestBeacon = 0.0;
      return;
    }

    final statuses =
        <BeaconStatus>[];

    for (final editorBeacon
        in savedBeacons) {
      final pixelDistance =
          (_position -
                  editorBeacon.position)
              .distance;

      final meterDistance =
          pixelDistance /
              pixelsPerMeter;

      // Convert EditorBeacon to your existing
      // Beacon model so the current IndoorMap UI
      // can continue using nearestBeacon.id
      // and nearestBeacon.macAddress.
      final beacon = Beacon(
        id: editorBeacon.id,
        macAddress: '',
        meter: meterDistance,
        position: editorBeacon.position,
        range: editorBeacon.range,
      );

      statuses.add(
        BeaconStatus(
          beacon: beacon,
          distanceMeters:
              meterDistance,
        ),
      );
    }

    statuses.sort(
      (a, b) => a.distanceMeters.compareTo(
        b.distanceMeters,
      ),
    );

    _beaconStatuses = statuses;

    if (statuses.isNotEmpty) {
      _nearestBeacon =
          statuses.first.beacon;

      _distanceToNearestBeacon =
          statuses.first.distanceMeters;
    }
  }

  // ============================================================
  // FIND NODE
  // ============================================================

  NavigationNode? _findNode(
    List<NavigationNode> nodes,
    String id,
  ) {
    for (final node in nodes) {
      if (node.id == id) {
        return node;
      }
    }

    return null;
  }

  // ============================================================
  // DEBUG
  // ============================================================

  void _printDebug() {
    debugPrint('');
    debugPrint(
      '==============================================',
    );
    debugPrint(
      '           INDOOR NAVIGATION',
    );
    debugPrint(
      '==============================================',
    );

    debugPrint(
      'User meter      : '
      '${_meter.toStringAsFixed(2)} m',
    );

    debugPrint(
      'Total path      : '
      '${_totalPathMeters.toStringAsFixed(2)} m',
    );

    debugPrint(
      'User position   : '
      '(${_position.dx.toStringAsFixed(1)}, '
      '${_position.dy.toStringAsFixed(1)}) px',
    );

    if (_previousNode != null &&
        _nextNode != null) {
      debugPrint(
        'Current path    : '
        '${_previousNode!.id} → '
        '${_nextNode!.id}',
      );

      debugPrint(
        'Segment progress: '
        '${(_edgeProgress * 100).toStringAsFixed(1)}%',
      );
    }

    if (_nearestNode != null) {
      debugPrint(
        'Nearest node    : '
        '${_nearestNode!.id}',
      );

      debugPrint(
        'Node distance   : '
        '${_distanceToNearestNode.toStringAsFixed(2)} m',
      );
    }

    debugPrint('');
    debugPrint('Beacon distances:');

    for (final status
        in _beaconStatuses) {
      debugPrint(
        '  ${status.beacon.id} '
        '| ${status.distanceMeters.toStringAsFixed(2)} m',
      );
    }

    if (_nearestBeacon != null) {
      debugPrint('');
      debugPrint(
        'Nearest beacon  : '
        '${_nearestBeacon!.id}',
      );

      debugPrint(
        'Beacon distance : '
        '${_distanceToNearestBeacon.toStringAsFixed(2)} m',
      );
    }

    debugPrint(
      '==============================================',
    );
  }
}