import 'package:flutter/material.dart';

import '../../models/navigation_node.dart';
import '../../models/navigation_edge.dart';

import '../../shared/painters/path_setup_painter.dart';

import 'path_store.dart';

import '../../models/demo_project.dart';

class PathSetupPage extends StatefulWidget {
  const PathSetupPage({
    super.key,
  });

  @override
  State<PathSetupPage> createState() =>
      _PathSetupPageState();
}

class _PathSetupPageState
    extends State<PathSetupPage> {
  final TransformationController
      transformationController =
      TransformationController();

  // ============================================================
  // PATH DATA
  // ============================================================

  List<NavigationNode> nodes = [];

  List<NavigationEdge> edges = [];

  // ============================================================
  // STATE
  // ============================================================

  String? selectedNodeId;

  bool pathMode = false;

  bool addNodeMode = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    nodes = PathStore.instance.nodes
        .map(
          (node) => NavigationNode(
            id: node.id,
            position: node.position,
            roomIds:
                List<String>.from(
              node.roomIds,
            ),
          ),
        )
        .toList();

    edges = PathStore.instance.edges
        .map(
          (edge) => NavigationEdge(
            from: edge.from,
            to: edge.to,
          ),
        )
        .toList();
  }

  // ============================================================
  // SAVE PATH
  // ============================================================

  void _savePath() {
    PathStore.instance.savePath(
      nodes: nodes,
      edges: edges,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult:
          (didPop, result) {
        if (didPop) {
          _savePath();
        }
      },
      child: Scaffold(
        // ======================================================
        // ADD NODE
        // ======================================================

        floatingActionButton:
            FloatingActionButton(
          onPressed: () {
            setState(() {
              addNodeMode =
                  !addNodeMode;

              if (addNodeMode) {
                pathMode = false;
                selectedNodeId = null;
              }
            });
          },
          child: Icon(
            addNodeMode
                ? Icons.close
                : Icons.add,
          ),
        ),

        // ======================================================
        // APP BAR
        // ======================================================

        appBar: AppBar(
          title: const Text(
            'Path Setup',
          ),
          actions: [
            // --------------------------------------------------
            // PATH MODE
            // --------------------------------------------------

            IconButton(
              icon: Icon(
                pathMode
                    ? Icons.link
                    : Icons.link_off,
              ),
              tooltip: pathMode
                  ? 'Path mode ON'
                  : 'Path mode OFF',
              onPressed: () {
                setState(() {
                  pathMode =
                      !pathMode;

                  addNodeMode = false;

                  selectedNodeId = null;
                });
              },
            ),

            // --------------------------------------------------
            // CLEAR
            // --------------------------------------------------

            IconButton(
              icon: const Icon(
                Icons.delete_outline,
              ),
              tooltip: 'Clear path',
              onPressed:
                  _showClearConfirmation,
            ),
          ],
        ),

        // ======================================================
        // MAP
        // ======================================================

        body: SafeArea(
          child: GestureDetector(
            onTapDown: (details) {
              if (!addNodeMode) {
                return;
              }

              final matrix =
                  transformationController
                      .value;

              final inverted =
                  matrix.clone()..invert();

              final mapPosition =
                  MatrixUtils.transformPoint(
                inverted,
                details.localPosition,
              );

              setState(() {
                final newNode =
                    NavigationNode(
                  id:
                      'N${nodes.length + 1}',
                  position:
                      mapPosition,
                );

                nodes.add(newNode);

                _savePath();
              });

              debugPrint(
                'Node ${nodes.length} '
                '-> $mapPosition',
              );
            },
            child: InteractiveViewer(
              transformationController:
                  transformationController,
              boundaryMargin:
                  const EdgeInsets.all(
                5000,
              ),
              constrained: false,
              minScale: 0.2,
              maxScale: 8,
              child: SizedBox(
                width: 3000,
                height: 3000,
                child: Stack(
                  children: [
                    // =========================================
                    // MAP
                    // =========================================

                    Positioned.fill(
                      child: Image.asset(
                        'assets/maps/floor1.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    // =========================================
                    // PATH
                    // =========================================

                    CustomPaint(
                      size: const Size(
                        3000,
                        3000,
                      ),
                      painter:
                          PathSetupPainter(
                        nodes: nodes,
                        edges: edges,
                      ),
                    ),

                    // =========================================
                    // NODES
                    // =========================================

                    ...nodes.map(
                      (node) {
                        final isSelected =
                            selectedNodeId ==
                                node.id;

                        return Positioned(
                          left:
                              node.position.dx -
                                  14,
                          top:
                              node.position.dy -
                                  14,
                          child:
                              GestureDetector(
                            // ---------------------------------
                            // TAP
                            // ---------------------------------

                            onTap: () {
                              if (pathMode) {
                                _selectPathNode(
                                  node,
                                );
                              } else {
                                _editNode(
                                  node,
                                );
                              }
                            },

                            // ---------------------------------
                            // DRAG
                            // ---------------------------------

                            onPanUpdate:
                                (details) {
                              if (pathMode) {
                                return;
                              }

                              setState(() {
                                node.position +=
                                    details.delta;
                              });

                              _savePath();
                            },

                            child: Column(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                Text(
                                  node.id,
                                  style:
                                      TextStyle(
                                    color:
                                        isSelected
                                            ? Colors
                                                .orange
                                            : Colors
                                                .red,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 2,
                                ),

                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        isSelected
                                            ? Colors
                                                .orange
                                            : Colors
                                                .red,
                                    shape:
                                        BoxShape
                                            .circle,
                                  ),
                                ),

                                // Show number of
                                // assigned rooms.
                                if (node
                                    .roomIds
                                    .isNotEmpty)
                                  Text(
                                    '${node.roomIds.length} room(s)',
                                    style:
                                        const TextStyle(
                                      fontSize: 9,
                                      color:
                                          Colors.black,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                              ],
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
      ),
    );
  }

  // ============================================================
  // PATH NODE SELECTION
  // ============================================================

  void _selectPathNode(
    NavigationNode node,
  ) {
    setState(() {
      if (selectedNodeId == null) {
        selectedNodeId = node.id;

        debugPrint(
          'Path start selected: ${node.id}',
        );

        return;
      }

      if (selectedNodeId ==
          node.id) {
        selectedNodeId = null;
        return;
      }

      final firstNode =
          nodes.firstWhere(
        (n) =>
            n.id ==
            selectedNodeId,
      );

      // Prevent duplicate connection
      final alreadyExists =
          edges.any(
        (edge) =>
            (edge.from ==
                    firstNode.id &&
                edge.to ==
                    node.id) ||
            (edge.from ==
                    node.id &&
                edge.to ==
                    firstNode.id),
      );

      if (!alreadyExists) {
        edges.add(
          NavigationEdge(
            from: firstNode.id,
            to: node.id,
          ),
        );

        debugPrint(
          'Path created: '
          '${firstNode.id} -> ${node.id}',
        );
      }

      selectedNodeId = null;

      _savePath();
    });
  }

  // ============================================================
  // EDIT NODE
  // ============================================================

  void _editNode(
    NavigationNode node,
  ) {
    final xController =
        TextEditingController(
      text: node.position.dx
          .toStringAsFixed(1),
    );

    final yController =
        TextEditingController(
      text: node.position.dy
          .toStringAsFixed(1),
    );

    List<String> selectedRoomIds =
        List<String>.from(
      node.roomIds,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: Text(
                'Edit ${node.id}',
              ),

              content:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    // =========================================
                    // X
                    // =========================================

                    TextField(
                      controller:
                          xController,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText:
                            'X Position',
                        suffixText:
                            'px',
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // =========================================
                    // Y
                    // =========================================

                    TextField(
                      controller:
                          yController,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Y Position',
                        suffixText:
                            'px',
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // =========================================
                    // ROOM SELECTION
                    // =========================================

                    const Text(
                      'Assigned Rooms',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    OutlinedButton.icon(
                      icon: const Icon(
                        Icons.meeting_room,
                      ),
                      label: Text(
                        selectedRoomIds
                                .isEmpty
                            ? 'Select Rooms'
                            : '${selectedRoomIds.length} Room(s) Selected',
                      ),
                      onPressed: () {
                        _showRoomSelector(
                          dialogContext:
                              context,
                          selectedRoomIds:
                              selectedRoomIds,
                          onChanged:
                              (newSelection) {
                            setDialogState(() {
                              selectedRoomIds =
                                  newSelection;
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    // =========================================
                    // SELECTED ROOM CHIPS
                    // =========================================

                    if (selectedRoomIds
                        .isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            DemoProject
                                .data
                                .building
                                .corridor
                                .rooms
                                .where(
                                  (room) =>
                                      selectedRoomIds
                                          .contains(
                                    room.id,
                                  ),
                                )
                                .map(
                                  (room) =>
                                      Chip(
                                    avatar:
                                        const Icon(
                                      Icons
                                          .room,
                                      size: 16,
                                    ),
                                    label:
                                        Text(
                                      room.name,
                                    ),
                                    onDeleted:
                                        () {
                                      setDialogState(
                                        () {
                                          selectedRoomIds
                                              .remove(
                                            room.id,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                )
                                .toList(),
                      ),
                  ],
                ),
              ),

              // =================================================
              // ACTIONS
              // =================================================

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
                    final x =
                        double.tryParse(
                      xController.text,
                    );

                    final y =
                        double.tryParse(
                      yController.text,
                    );

                    if (x == null ||
                        y == null) {
                      return;
                    }

                    setState(() {
                      node.updatePosition(
                        x: x,
                        y: y,
                      );

                      node.roomIds =
                          List<String>.from(
                        selectedRoomIds,
                      );
                    });

                    _savePath();

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
    );
  }

  // ============================================================
  // ROOM SELECTOR
  // ============================================================

  void _showRoomSelector({
    required BuildContext dialogContext,
    required List<String>
        selectedRoomIds,
    required Function(
      List<String>,
    ) onChanged,
  }) {
    final temporarySelection =
        Set<String>.from(
      selectedRoomIds,
    );

    // Rooms assigned to another node
    // cannot be assigned here.
    final usedByOtherNodes =
        <String>{};

    for (final otherNode in nodes) {
      for (final roomId
          in otherNode.roomIds) {
        usedByOtherNodes.add(
          roomId,
        );
      }
    }

    // Remove the current node's rooms
    // from the "used" list.
    usedByOtherNodes.removeAll(
      selectedRoomIds,
    );

    final availableRooms =
        DemoProject
            .data
            .building
            .corridor
            .rooms
            .where(
              (room) =>
                  !usedByOtherNodes
                      .contains(
                    room.id,
                  ),
            )
            .toList();

    showDialog(
      context: dialogContext,
      builder: (roomContext) {
        return StatefulBuilder(
          builder: (
            context,
            setRoomState,
          ) {
            return AlertDialog(
              title: const Text(
                'Select Rooms',
              ),

              content: SizedBox(
                width:
                    double.maxFinite,
                height: 350,
                child: availableRooms
                        .isEmpty
                    ? const Center(
                        child: Text(
                          'No rooms available',
                        ),
                      )
                    : ListView(
                        children:
                            availableRooms
                                .map(
                          (room) {
                            final checked =
                                temporarySelection
                                    .contains(
                              room.id,
                            );

                            return CheckboxListTile(
                              value:
                                  checked,
                              title:
                                  Text(
                                room.name,
                              ),
                              subtitle:
                                  Text(
                                room.id,
                              ),
                              onChanged:
                                  (value) {
                                setRoomState(
                                  () {
                                    if (value ==
                                        true) {
                                      temporarySelection
                                          .add(
                                        room.id,
                                      );
                                    } else {
                                      temporarySelection
                                          .remove(
                                        room.id,
                                      );
                                    }
                                  },
                                );
                              },
                            );
                          },
                        ).toList(),
                      ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      roomContext,
                    );
                  },
                  child:
                      const Text(
                    'Cancel',
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    onChanged(
                      temporarySelection
                          .toList(),
                    );

                    Navigator.pop(
                      roomContext,
                    );
                  },
                  child:
                      const Text(
                    'Done',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // CLEAR CONFIRMATION
  // ============================================================

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Clear Path?',
          ),
          content:
              const Text(
            'This will remove all '
            'nodes and connections.',
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
                  nodes.clear();
                  edges.clear();
                  selectedNodeId =
                      null;
                });

                PathStore.instance
                    .clearPath();

                Navigator.pop(
                  context,
                );
              },
              child:
                  const Text(
                'Clear',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    transformationController
        .dispose();

    super.dispose();
  }
}