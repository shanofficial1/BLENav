import '../../models/room.dart';
import '../../models/demo_project.dart';

class SearchService {
  static final SearchService instance = SearchService();

  SearchService();

  List<Room> search(String query) {
    final rooms =
        DemoProject.data.building.corridor.rooms;

    if (query.trim().isEmpty) {
      return rooms;
    }

    final q = query.toLowerCase();

    return rooms.where((room) {
      return room.name
          .toLowerCase()
          .contains(q);
    }).toList();
  }
}