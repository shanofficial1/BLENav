import 'package:flutter/material.dart';

import 'indoor_map_painter.dart';
import 'user_marker.dart';
import 'movement_service.dart';

import '../../shared/painters/navigation_painter.dart';

import '../navigation/navigation_service.dart';
import '../navigation/search_service.dart';
import '../navigation/destination_service.dart';
import '../navigation/navigation_controller.dart';
import '../navigation/navigation_state.dart';

import '../../models/room.dart';

import '../ble/ble_scanner_service.dart';

import '../../models/demo_project.dart';

import '../../models/navigation_node.dart';
import '../../models/navigation_edge.dart';

import '../path_setup/path_store.dart';
import '../beacon_setup/beacon_store.dart';

import '../../shared/painters/path_setup_painter.dart';
import '../../models/editor_beacon.dart';

import '../navigation/path_navigation_service.dart';

import '../../shared/painters/navigation_route_painter.dart';

class IndoorMapPage extends StatefulWidget {
  const IndoorMapPage({super.key});

  @override
  State<IndoorMapPage> createState() => _IndoorMapPageState();
}

class _IndoorMapPageState extends State<IndoorMapPage> {
  final TextEditingController searchController = TextEditingController();
  NavigationNode? destinationNode;

  List<NavigationNode> navigationRoute = [];

  List<NavigationNode> savedPathNodes = [];
  List<NavigationEdge> savedPathEdges = [];
  List<EditorBeacon> savedBeacons = [];
  List<Room> searchResult = [];
  @override
  void initState() {
    super.initState();

    _loadSavedNavigationData();

    MovementService.instance.initializeFromSavedPath();
  }

  void _loadSavedNavigationData() {
    savedPathNodes = PathStore.instance.nodes
        .map(
          (node) => NavigationNode(
            id: node.id,
            position: node.position,
            roomIds: List<String>.from(node.roomIds),
          ),
        )
        .toList();

    savedPathEdges = PathStore.instance.edges
        .map((edge) => NavigationEdge(from: edge.from, to: edge.to))
        .toList();

    savedBeacons = BeaconStore.instance.beacons
        .map((beacon) => EditorBeacon(id: beacon.id, position: beacon.position))
        .toList();

    for (
      int i = 0;
      i < savedBeacons.length && i < BeaconStore.instance.beacons.length;
      i++
    ) {
      savedBeacons[i].range = BeaconStore.instance.beacons[i].range;
    }

    debugPrint(
      'Indoor Map loaded path: '
      '${savedPathNodes.length} nodes, '
      '${savedPathEdges.length} edges',
    );

    debugPrint(
      'Indoor Map loaded beacons: '
      '${savedBeacons.length}',
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Indoor Map')),
      body: SafeArea(
        child: Stack(
          children: [
            // ==================================================
            // MAP
            // ==================================================
            Positioned.fill(
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(5000),
                constrained: false,
                minScale: 0.2,
                maxScale: 8,
                child: SizedBox(
                  width: 3000,
                  height: 3000,
                  child: AnimatedBuilder(
                    animation: MovementService.instance,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          // --------------------------------------
                          // Building background
                          // --------------------------------------
                          Positioned.fill(
                            child: Image.asset(
                              'assets/maps/floor1.png',
                              fit: BoxFit.contain,
                            ),
                          ),

                          // --------------------------------------
                          // Existing navigation painter
                          // --------------------------------------
                          if (savedPathNodes.isNotEmpty)
                            Positioned.fill(
                              child: CustomPaint(
                                size: const Size(3000, 3000),
                                painter: PathSetupPainter(
                                  nodes: savedPathNodes,
                                  edges: savedPathEdges,
                                ),
                              ),
                            ),

                          ...savedBeacons.map((beacon) {
                            const pixelsPerMeter = 100.0;

                            final radius = beacon.range * pixelsPerMeter;

                            return Positioned(
                              left: beacon.position.dx - radius,
                              top: beacon.position.dy - radius,

                              child: IgnorePointer(
                                child: SizedBox(
                                  width: radius * 2,
                                  height: radius * 2,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: radius * 2,
                                        height: radius * 2,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue.withOpacity(0.10),
                                          border: Border.all(
                                            color: Colors.blue.withOpacity(
                                              0.35,
                                            ),
                                            width: 2,
                                          ),
                                        ),
                                      ),

                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),

                                      Positioned(
                                        top: radius + 8,
                                        child: Text(
                                          '${beacon.id} • '
                                          '${beacon.range.toStringAsFixed(1)} m',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),

                          // ==================================================
                          // ACTIVE NAVIGATION ROUTE
                          // ==================================================
                          if (navigationRoute.isNotEmpty)
                            Positioned.fill(
                              child: CustomPaint(
                                size: const Size(3000, 3000),
                                painter: NavigationRoutePainter(
                                  userPosition:
                                      MovementService.instance.position,
                                  routeNodes: navigationRoute,
                                ),
                              ),
                            ),

                          // --------------------------------------
                          // User
                          // --------------------------------------
                          UserMarker(
                            position: MovementService.instance.position,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // ==================================================
            // SEARCH
            // ==================================================
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(16),
                child: TextField(
                  controller: searchController,

                  onChanged: (value) {
                    setState(() {
                      searchResult = SearchService.instance.search(value);
                    });
                  },

                  decoration: InputDecoration(
                    hintText: 'Search destination...',

                    prefixIcon: const Icon(Icons.search),

                    suffixIcon: const Icon(Icons.mic_none),

                    filled: true,

                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),

                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            // ==================================================
            // SEARCH RESULTS
            // ==================================================
            if (searchResult.isNotEmpty)
              Positioned(
                top: 90,
                left: 16,
                right: 16,
                child: Card(
                  elevation: 6,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: searchResult.length,
                    itemBuilder: (context, index) {
                      final room = searchResult[index];

                      return ListTile(
                        leading: const Icon(Icons.place),
                        title: Text(room.name),
                        onTap: () {
                          searchController.text = room.name;

                          FocusScope.of(context).unfocus();

                          DestinationService.instance.select(room);

                          final result = PathNavigationService.instance
                              .findRoute(
                                userPosition: MovementService.instance.position,
                                roomId: room.id,
                              );

                          if (result == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'No configured path found for ${room.name}',
                                ),
                              ),
                            );

                            setState(() {
                              searchResult = [];
                            });

                            return;
                          }

                          setState(() {
                            destinationNode = result.destination;

                            navigationRoute = result.routeNodes;

                            searchResult = [];
                          });

                          debugPrint('====================================');

                          debugPrint('NAVIGATION STARTED');

                          debugPrint('ROOM: ${room.name}');

                          debugPrint(
                            'DESTINATION NODE: '
                            '${result.destination.id}',
                          );

                          debugPrint(
                            'ROUTE: '
                            '${result.routeNodes.map((n) => n.id).join(' -> ')}',
                          );

                          debugPrint(
                            'DISTANCE: '
                            '${result.distanceMeters.toStringAsFixed(2)} m',
                          );

                          debugPrint('====================================');
                        },
                      );
                    },
                  ),
                ),
              ),

            // ==================================================
            // BOTTOM INFORMATION CARD
            // ==================================================
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedBuilder(
                    animation: MovementService.instance,
                    builder: (context, child) {
                      final movement = MovementService.instance;

                      final destination =
                          NavigationController.instance.destinationNode;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ----------------------------------
                          // Title
                          // ----------------------------------
                          const Text(
                            'Manual Position Test',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // ----------------------------------
                          // Slider
                          // ----------------------------------
                          Text(
                            'Position: '
                            '${movement.meter.toStringAsFixed(1)} m',
                          ),

                          Slider(
                            value: movement.meter.clamp(0.0, _maxMeter()),
                            min: 0,
                            max: _maxMeter(),
                            onChanged: (value) {
                              MovementService.instance.updateMeter(value);
                            },
                          ),

                          // ----------------------------------
                          // Current position
                          // ----------------------------------
                          Text(
                            'Pixel: '
                            '(${movement.position.dx.toStringAsFixed(0)}, '
                            '${movement.position.dy.toStringAsFixed(0)})',
                          ),

                          const SizedBox(height: 8),

                          // ----------------------------------
                          // Current path
                          // ----------------------------------
                          _infoRow(
                            'Current path',
                            movement.previousNode != null &&
                                    movement.nextNode != null
                                ? '${movement.previousNode!.id} → '
                                      '${movement.nextNode!.id}'
                                : '-',
                          ),

                          // ----------------------------------
                          // Path progress
                          // ----------------------------------
                          _infoRow(
                            'Path progress',
                            '${(movement.edgeProgress * 100).toStringAsFixed(1)}%',
                          ),

                          // ----------------------------------
                          // Nearest NODE
                          // ----------------------------------
                          _infoRow(
                            'Nearest node',
                            movement.nearestNode?.id ?? '-',
                          ),

                          _infoRow(
                            'Distance to node',
                            movement.nearestNode == null
                                ? '-'
                                : '${movement.distanceToNearestNode.toStringAsFixed(2)} m',
                          ),

                          const Divider(),

                          // ----------------------------------
                          // Nearest BEACON
                          // ----------------------------------
                          const Text(
                            'Beacon Status',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 6),

                          _infoRow(
                            'Nearest beacon',
                            movement.nearestBeacon?.id ?? '-',
                          ),

                          _infoRow(
                            'Beacon distance',
                            movement.nearestBeacon == null
                                ? '-'
                                : '${movement.distanceToNearestBeacon.toStringAsFixed(2)} m',
                          ),

                          if (movement.nearestBeacon?.macAddress.isNotEmpty ??
                              false)
                            _infoRow('MAC', movement.nearestBeacon!.macAddress),

                          const SizedBox(height: 8),

                          // ----------------------------------
                          // ALL BEACONS
                          // ----------------------------------
                          ...movement.beaconStatuses.map((status) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Expanded(child: Text(status.beacon.id)),
                                  Text(
                                    '${status.distanceMeters.toStringAsFixed(2)} m',
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 8),

                          // ----------------------------------
                          // Destination
                          // ----------------------------------
                          if (destination != null)
                            _infoRow(
                              'Destination',
                              DestinationService.instance.selectedRoom?.name ??
                                  '-',
                            ),

                          // ----------------------------------
                          // Remaining distance
                          // ----------------------------------
                          if (destination != null)
                            _buildRemainingDistance(movement, destination),

                          const SizedBox(height: 8),

                          // ----------------------------------
                          // BLE test button
                          // ----------------------------------
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                BleScannerService.instance.startScan();
                              },
                              icon: const Icon(Icons.bluetooth),
                              label: const Text('Start BLE Scan'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MAX METER
  // ============================================================

  double _maxMeter() {
    final total = MovementService.instance.totalPathMeters;

    return total > 0 ? total : 1.0;
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  // ============================================================
  // REMAINING DISTANCE
  // ============================================================

  Widget _buildRemainingDistance(
    MovementService movement,
    dynamic destination,
  ) {
    final remaining = (destination.meter - movement.meter)
        .clamp(0.0, double.infinity)
        .toDouble();

    return _infoRow('Remaining', '${remaining.toStringAsFixed(1)} m');
  }
}
