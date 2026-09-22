import '../../models/navigation_node.dart';
import '../../models/room.dart';
import '../path_setup/path_store.dart';

/// Connects searchable rooms to nodes created in Path Setup.
///
/// The Path Setup page should call assignRoomToNode() when the user assigns
/// a room to a node. Indoor Map/Search can then resolve a Room to that node.
class PathDestinationService {
  PathDestinationService._();

  static final PathDestinationService instance =
      PathDestinationService._();

  /// roomId -> path node id
  final Map<String, String> _roomToNode = {};

  Map<String, String> get assignments =>
      Map.unmodifiable(_roomToNode);

  void assignRoomToNode({
    required Room room,
    required NavigationNode node,
  }) {
    // A room can belong to only one path node.
    _roomToNode.removeWhere(
      (roomId, nodeId) =>
          roomId == room.id || nodeId == node.id,
    );

    _roomToNode[room.id] = node.id;
  }

  void removeRoomFromNode(String roomId) {
    _roomToNode.remove(roomId);
  }

  NavigationNode? getNodeForRoom(Room room) {
    final nodeId = _roomToNode[room.id];
    if (nodeId == null) return null;

    return PathStore.instance.getNode(nodeId);
  }

  NavigationNode? getNodeForRoomId(String roomId) {
    final nodeId = _roomToNode[roomId];
    if (nodeId == null) return null;

    return PathStore.instance.getNode(nodeId);
  }

  Room? getRoomForNodeId(String nodeId, List<Room> rooms) {
    for (final entry in _roomToNode.entries) {
      if (entry.value != nodeId) continue;

      for (final room in rooms) {
        if (room.id == entry.key) return room;
      }
    }

    return null;
  }

  void clear() {
    _roomToNode.clear();
  }
}
