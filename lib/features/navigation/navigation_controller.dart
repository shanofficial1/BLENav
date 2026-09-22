import 'package:flutter/material.dart';

import '../../models/walk_node.dart';
import 'destination_service.dart';
import 'navigation_service.dart';

class NavigationController extends ChangeNotifier {
  static final NavigationController instance =
      NavigationController();

  NavigationController();

  WalkNode? _destinationNode;

  WalkNode? get destinationNode => _destinationNode;

  void updateDestination() {

    final room =
        DestinationService.instance.selectedRoom;

    if (room == null) {
      _destinationNode = null;
      notifyListeners();
      return;
    }

    _destinationNode =
        NavigationService.instance.getNodeByRoom(
      room.id,
    );

    notifyListeners();
  }

  bool get hasDestination =>
      _destinationNode != null;
}