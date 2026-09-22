import 'package:flutter/material.dart';

import '../../models/room.dart';

class DestinationService extends ChangeNotifier {
  static final DestinationService instance =
      DestinationService();

  DestinationService();

  Room? _selectedRoom;

  Room? get selectedRoom => _selectedRoom;

  void select(Room room) {
    _selectedRoom = room;
    notifyListeners();
  }

  void clear() {
    _selectedRoom = null;
    notifyListeners();
  }
}