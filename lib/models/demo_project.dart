import 'package:flutter/material.dart';

import 'project.dart';
import 'building.dart';
import 'corridor.dart';
import 'room.dart';
import 'beacon.dart';
import 'navigation_graph.dart';
import 'walk_node.dart';
import 'walk_edge.dart';

class DemoProject {
  static final Project data = Project(
    name: "IndoorNav Demo",
    building: Building(
      id: "B1",
      name: "Department of Information Technology",

      corridor: Corridor(
        id: "C1",
        name: "Main Corridor",
        length: 22,

       rooms: const [

  // ==========================================
  // UPPER SECTION
  // ==========================================

  Room(
    id: "R1",
    name: "Research Lab 2",
    startMeter: 18,
    endMeter: 22,
    side: RoomSide.right,
  ),

  Room(
    id: "R2",
    name: "PG Diploma",
    startMeter: 14,
    endMeter: 18,
    side: RoomSide.left,
  ),

  Room(
    id: "R3",
    name: "Tutorial Room",
    startMeter: 10,
    endMeter: 14,
    side: RoomSide.left,
  ),

  Room(
    id: "R4",
    name: "Conference Room",
    startMeter: 6,
    endMeter: 10,
    side: RoomSide.left,
  ),

  Room(
    id: "R5",
    name: "Faculty Room",
    startMeter: 2,
    endMeter: 6,
    side: RoomSide.left,
  ),

  // ==========================================
  // CENTRAL / CORRIDOR ROOMS
  // ==========================================

  Room(
    id: "R6",
    name: "Artificial Intelligence Lab",
    startMeter: 8,
    endMeter: 12,
    side: RoomSide.right,
  ),

  Room(
    id: "R7",
    name: "Signal and Image Processing Lab",
    startMeter: 5,
    endMeter: 8,
    side: RoomSide.right,
  ),

  Room(
    id: "R8",
    name: "Data Science Lab",
    startMeter: 0,
    endMeter: 5,
    side: RoomSide.right,
  ),

  // ==========================================
  // LOWER CORRIDOR
  // ==========================================

  Room(
    id: "R9",
    name: "MCA I",
    startMeter: 0,
    endMeter: 4,
    side: RoomSide.left,
  ),

  Room(
    id: "R10",
    name: "MCA II",
    startMeter: 4,
    endMeter: 8,
    side: RoomSide.left,
  ),

  Room(
    id: "R11",
    name: "II M.Sc. Computer Science",
    startMeter: 8,
    endMeter: 13,
    side: RoomSide.right,
  ),

  // ==========================================
  // RIGHT SIDE / END OF PATH
  // ==========================================

  Room(
    id: "R12",
    name: "Facilities Room",
    startMeter: 18,
    endMeter: 20,
    side: RoomSide.right,
  ),

  Room(
    id: "R13",
    name: "Library Department of IT",
    startMeter: 20,
    endMeter: 22,
    side: RoomSide.right,
  ),

  // ==========================================
  // OTHER ROOMS DIRECTLY CONNECTED TO PATH
  // ==========================================

  Room(
    id: "R14",
    name: "Faculty Chamber",
    startMeter: 2,
    endMeter: 6,
    side: RoomSide.left,
  ),

  Room(
    id: "R15",
    name: "Staff Toilet",
    startMeter: 6,
    endMeter: 8,
    side: RoomSide.left,
  ),
],
        
      ),

      beacons: [

        Beacon(
          id: "B1",
          macAddress: "2C:52:C3:35:85:6E",
          meter: 0,
          position: const Offset(345,1200),
        ),

        Beacon(
          id: "B2",
          macAddress: "05:8A:C4:45:97:F2",
          meter: 10,
          position: const Offset(345,1200),
        ),

        Beacon(
          id: "B3",
          macAddress: "00:06:AE:B5:5A:9D",
          meter: 20,
          position: const Offset(1500, 600),
        ),
      ],
   
  graph: NavigationGraph(
 nodes: const [

  WalkNode(
    id: "N1",
    meter: 0,
    type: NodeType.entrance,
    position: Offset(345, 1300),
    beaconId: "B1",
    connections: ["N2"],
  ),

  // Research Lab (bottom)
  WalkNode(
    id: "N2",
    meter: 3,
    type: NodeType.destination,
    position: Offset(345, 1150),
    roomId: "R1",
    beaconId: "B1",
    connections: ["N1", "N3"],
  ),

  // PG Diploma
  WalkNode(
    id: "N3",
    meter: 7,
    type: NodeType.destination,
    position: Offset(345, 950),
    roomId: "R2",
    beaconId: "B2",
    connections: ["N2", "N4"],
  ),

  // Tutorial Room
  WalkNode(
    id: "N4",
    meter: 11,
    type: NodeType.destination,
    position: Offset(345, 750),
    roomId: "R3",
    beaconId: "B2",
    connections: ["N3", "N5"],
  ),

  // Conference Room
  WalkNode(
    id: "N5",
    meter: 15,
    type: NodeType.destination,
    position: Offset(345, 550),
    roomId: "R4",
    beaconId: "B3",
    connections: ["N4", "N6"],
  ),

  // Faculty Room (top)
  WalkNode(
    id: "N6",
    meter: 19,
    type: NodeType.destination,
    position: Offset(345, 350),
    roomId: "R5",
    beaconId: "B3",
    connections: ["N5"],
  ),
],
  edges: const [

    WalkEdge(
      from: "N1",
      to: "N2",
      distance: 3,
    ),

    WalkEdge(
      from: "N2",
      to: "N3",
      distance: 4,
    ),

    WalkEdge(
      from: "N3",
      to: "N4",
      distance: 4,
    ),

    WalkEdge(
      from: "N4",
      to: "N5",
      distance: 4,
    ),

    WalkEdge(
      from: "N5",
      to: "N6",
      distance: 4,
    ),
  ],
),
    ),
 
  );
}