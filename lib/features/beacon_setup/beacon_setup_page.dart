import 'package:flutter/material.dart';

import '../../models/editor_beacon.dart';
import '../../models/navigation_node.dart';
import '../../models/navigation_edge.dart';

import '../path_setup/path_store.dart';
import 'beacon_store.dart';

import '../../shared/painters/path_setup_painter.dart';

import '../ble_beacon_manager/ble_beacon_store.dart';

class BeaconSetupPage extends StatefulWidget {
  const BeaconSetupPage({super.key});

  @override
  State<BeaconSetupPage> createState() =>
      _BeaconSetupPageState();
}

class _BeaconSetupPageState
    extends State<BeaconSetupPage> {
  final TransformationController
      transformationController =
      TransformationController();

  // ============================================================
  // PATH
  // ============================================================

  List<NavigationNode> pathNodes = [];
  List<NavigationEdge> pathEdges = [];

  // ============================================================
  // BEACONS
  // ============================================================

  List<EditorBeacon> beacons = [];

  bool addBeaconMode = false;

  static const double pixelsPerMeter = 100.0;

  @override
  void initState() {
    super.initState();

    _loadPath();
    _loadBeacons();
  }

  // ============================================================
  // LOAD SAVED PATH
  // ============================================================

  void _loadPath() {
    pathNodes = PathStore.instance.nodes
        .map(
          (node) => NavigationNode(
            id: node.id,
            position: node.position,
          ),
        )
        .toList();

    pathEdges = PathStore.instance.edges
        .map(
          (edge) => NavigationEdge(
            from: edge.from,
            to: edge.to,
          ),
        )
        .toList();
  }

  // ============================================================
  // LOAD SAVED BEACONS
  // ============================================================

  void _loadBeacons() {
    beacons = BeaconStore.instance.beacons
        .map(
          (beacon) => EditorBeacon(
            id: beacon.id,
            name: beacon.name,
            macAddress: beacon.macAddress,
            position: beacon.position,
            range: beacon.range,
            nodeId: beacon.nodeId,
          ),
        )
        .toList();
  }

  // ============================================================
  // SAVE
  // ============================================================

  void _saveBeacons() {
    BeaconStore.instance.saveBeacons(beacons);

    debugPrint('');
    debugPrint(
      '========== BEACONS SAVED ==========',
    );

    for (final beacon in beacons) {
      debugPrint(
        '${beacon.id} | '
        'Name: ${beacon.name} | '
        'MAC: ${beacon.macAddress} | '
        'Range: ${beacon.range.toStringAsFixed(1)} m | '
        'Node: ${beacon.nodeId ?? "-"}',
      );
    }

    debugPrint(
      '===================================',
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult:
          (didPop, result) {
        if (didPop) {
          _saveBeacons();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Beacon Setup',
          ),
          actions: [
            IconButton(
              tooltip: 'Reload saved path',
              icon: const Icon(
                Icons.refresh,
              ),
              onPressed: () {
                setState(() {
                  _loadPath();
                });
              },
            ),
          ],
        ),

        floatingActionButton:
            FloatingActionButton(
          onPressed: () {
            setState(() {
              addBeaconMode =
                  !addBeaconMode;
            });
          },
          child: Icon(
            addBeaconMode
                ? Icons.close
                : Icons.bluetooth,
          ),
        ),

        body: SafeArea(
          child: GestureDetector(
            onTapDown: (details) {
              if (!addBeaconMode) {
                return;
              }

              final matrix =
                  transformationController.value;

              final mapPosition =
                  MatrixUtils
                      .transformPoint(
                matrix.clone()..invert(),
                details.localPosition,
              );

              final beacon =
                  EditorBeacon(
                id:
                    'B${beacons.length + 1}',
                name:
                    'Beacon ${beacons.length + 1}',
                position:
                    mapPosition,
              );

              setState(() {
                beacons.add(beacon);
              });

              _saveBeacons();

              // Immediately open configuration.
              _editBeacon(beacon);
            },

            child: InteractiveViewer(
              transformationController:
                  transformationController,
              boundaryMargin:
                  const EdgeInsets.all(5000),
              constrained: false,
              minScale: 0.2,
              maxScale: 8,

              child: SizedBox(
                width: 3000,
                height: 3000,

                child: Stack(
                  children: [
                    // ==================================================
                    // FLOOR PLAN
                    // ==================================================

                    Positioned.fill(
                      child: Image.asset(
                        'assets/maps/floor1.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    // ==================================================
                    // SAVED PATH
                    // ==================================================

                    if (pathNodes.isNotEmpty)
                      Positioned.fill(
                        child: CustomPaint(
                          size:
                              const Size(
                            3000,
                            3000,
                          ),
                          painter:
                              PathSetupPainter(
                            nodes: pathNodes,
                            edges: pathEdges,
                          ),
                        ),
                      ),

                    // ==================================================
                    // PATH NODES
                    // ==================================================

                    ...pathNodes.map(
                      (node) {
                        return Positioned(
                          left:
                              node.position.dx -
                                  10,
                          top:
                              node.position.dy -
                                  10,
                          child:
                              IgnorePointer(
                            child:
                                Column(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration:
                                      const BoxDecoration(
                                    color:
                                        Colors.orange,
                                    shape:
                                        BoxShape
                                            .circle,
                                  ),
                                ),
                                Text(
                                  node.id,
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.orange,
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // ==================================================
                    // BEACONS
                    // ==================================================

                    ...beacons.map(
                      (beacon) {
                        final radius =
                            beacon.range *
                                pixelsPerMeter;

                        return Positioned(
                          left:
                              beacon.position.dx -
                                  radius,
                          top:
                              beacon.position.dy -
                                  radius,

                          child: SizedBox(
                            width:
                                radius * 2,
                            height:
                                radius * 2,

                            child: GestureDetector(
                              onTap: () {
                                _editBeacon(
                                  beacon,
                                );
                              },

                              onPanUpdate:
                                  (details) {
                                if (addBeaconMode) {
                                  return;
                                }

                                setState(() {
                                  beacon.position +=
                                      details.delta;
                                });

                                _saveBeacons();
                              },

                              child: Stack(
                                alignment:
                                    Alignment.center,
                                children: [
                                  // ------------------------------------
                                  // Coverage
                                  // ------------------------------------

                                  Container(
                                    width:
                                        radius * 2,
                                    height:
                                        radius * 2,
                                    decoration:
                                        BoxDecoration(
                                      shape:
                                          BoxShape
                                              .circle,
                                      color: Colors
                                          .blue
                                          .withOpacity(
                                        .12,
                                      ),
                                      border:
                                          Border.all(
                                        color: Colors
                                            .blue
                                            .withOpacity(
                                          .45,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                  ),

                                  // ------------------------------------
                                  // Beacon point
                                  // ------------------------------------

                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration:
                                        const BoxDecoration(
                                      color:
                                          Colors.blue,
                                      shape:
                                          BoxShape
                                              .circle,
                                    ),
                                  ),

                                  // ------------------------------------
                                  // Beacon name
                                  // ------------------------------------

                                  Positioned(
                                    top:
                                        radius + 6,
                                    child:
                                        Container(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      color:
                                          Colors.white,
                                      child:
                                          Text(
                                        beacon.name
                                                .isEmpty
                                            ? beacon.id
                                            : beacon
                                                .name,
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.blue,
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize:
                                              12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ============================================================
        // BOTTOM INFO
        // ============================================================

        bottomSheet: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(12),
          color: Colors.white,
          child: SafeArea(
            child: Row(
              children: [
                const Icon(
                  Icons.route,
                  color: Colors.orange,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    '${pathNodes.length} nodes • '
                    '${pathEdges.length} paths • '
                    '${beacons.length} beacons',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EDIT BEACON
  // ============================================================

  void _editBeacon(
    EditorBeacon beacon,
  ) {
    final nameController =
        TextEditingController(
      text: beacon.name,
    );

   String selectedMac =
    beacon.macAddress;

    double selectedRange =
        beacon.range;

    String? selectedNodeId =
        beacon.nodeId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: Text(
                '${beacon.id} Configuration',
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    // ------------------------------------------
                    // NAME
                    // ------------------------------------------

                    TextField(
                      controller:
                          nameController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Beacon Name',
                        hintText:
                            'Example: Corridor Beacon',
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ------------------------------------------
                    // MAC
                    // ------------------------------------------

                   DropdownButtonFormField<String>(
  value: selectedMac.isEmpty ? null : selectedMac,
  decoration: const InputDecoration(
    labelText: 'BLE MAC Address',
    prefixIcon: Icon(Icons.bluetooth),
  ),
  items: BleBeaconStore.instance.beacons.map((device) {
    return DropdownMenuItem<String>(
      value: device.macAddress,
      child: Text(
        '${device.name} • ${device.macAddress}',
        overflow: TextOverflow.ellipsis,
      ),
    );
  }).toList(),
  onChanged: (value) {
    setDialogState(() {
      selectedMac = value ?? '';
    });
  },
),

                    const SizedBox(
                      height: 12,
                    ),

                    // ------------------------------------------
                    // RANGE
                    // ------------------------------------------

                    Text(
                      'Range: '
                      '${selectedRange.toStringAsFixed(1)} m',
                    ),

                    Slider(
                      min: 2,
                      max: 16,
                      divisions: 28,
                      value:
                          selectedRange
                              .clamp(
                            2.0,
                            16.0,
                          ),
                      onChanged:
                          (value) {
                        setDialogState(() {
                          selectedRange =
                              value;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ------------------------------------------
                    // NODE
                    // ------------------------------------------

                    DropdownButtonFormField<
                        String>(
                      value:
                          selectedNodeId,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Associated Path Node',
                      ),
                      items:
                          pathNodes.map(
                        (node) {
                          return DropdownMenuItem<
                              String>(
                            value:
                                node.id,
                            child:
                                Text(
                              node.id,
                            ),
                          );
                        },
                      ).toList(),
                      onChanged:
                          (value) {
                        setDialogState(() {
                          selectedNodeId =
                              value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  child:
                      const Text(
                    'Cancel',
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      beacon.name =
                          nameController
                              .text
                              .trim()
                              .isEmpty
                          ? beacon.id
                          : nameController
                              .text
                              .trim();

                     beacon.macAddress =
    selectedMac;

                      beacon.range =
                          selectedRange;

                      beacon.nodeId =
                          selectedNodeId;
                    });

                    _saveBeacons();

                    Navigator.pop(
                      context,
                    );
                  },
                  child:
                      const Text(
                    'Save',
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
  nameController.dispose();
});
  }

  @override
  void dispose() {
    transformationController
        .dispose();

    super.dispose();
  }
}