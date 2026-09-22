import 'package:flutter/material.dart';

class NavigationState extends ChangeNotifier {
  static final NavigationState instance = NavigationState();

  String? currentNodeId;

  String? destinationNodeId;

  bool navigating = false;

  void startNavigation({
    required String startNode,
    required String endNode,
  }) {
    currentNodeId = startNode;
    destinationNodeId = endNode;
    navigating = true;

    notifyListeners();
  }

  void stopNavigation() {
    navigating = false;
    destinationNodeId = null;

    notifyListeners();
  }
}